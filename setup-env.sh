#!/usr/bin/env bash
set -euo pipefail

# Creates the credentials file that cwm reads: .env/cloudflare-claude-worker-manager.sh
# It asks for the Cloudflare account ID and API token, checks them against the
# Cloudflare API, and writes the file with owner-only permissions (600).
#
# Usage: ./setup-env.sh
# Set CWM_ENV_FILE to write the file to another place (cwm reads the same variable).
#
# Token permissions (see README.md):
#   Account > Workers Scripts > Edit     (required by cwm)
#   Account > Account Settings > Read    (optional)
#   Account > Workers AI > Edit          (optional)

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="${CWM_ENV_FILE:-$SCRIPT_DIR/.env/cloudflare-claude-worker-manager.sh}"
readonly API="https://api.cloudflare.com/client/v4"

die() {
  echo "error: $*" >&2
  exit 1
}

confirm_overwrite() {
  [[ -e "$ENV_FILE" ]] || return 0
  local answer
  read -r -p "$ENV_FILE already exists. Overwrite it? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || die "cancelled. The file did not change."
}

# prompt_value LABEL SECRET -> prints the value the user typed (not empty).
prompt_value() {
  local label="$1" secret="$2" value=""
  while [[ -z "$value" ]]; do
    if [[ "$secret" == "yes" ]]; then
      read -r -s -p "$label: " value
      echo >&2
    else
      read -r -p "$label: " value
    fi
    value="${value//[[:space:]]/}"
    [[ -n "$value" ]] || echo "The value cannot be empty." >&2
  done
  printf '%s' "$value"
}

# check_credentials ACCOUNT_ID TOKEN -> fails if the token cannot list Workers in the account.
check_credentials() {
  local account_id="$1" token="$2" response
  command -v curl >/dev/null && command -v jq >/dev/null || {
    echo "warning: curl or jq is missing. The values were not checked." >&2
    return 0
  }
  echo "Checking the values with the Cloudflare API..."
  response="$(curl -sS -H "Authorization: Bearer $token" \
    "$API/accounts/$account_id/workers/scripts")" || die "cannot reach the Cloudflare API"
  if [[ "$(jq -r '.success' <<<"$response")" != "true" ]]; then
    echo "Cloudflare rejected the values:" >&2
    jq -r '.errors[] | "  [\(.code)] \(.message)"' <<<"$response" >&2
    die "check the account ID and the token permission 'Workers Scripts: Edit'"
  fi
  echo "OK: the token can manage Workers in this account."
}

write_env_file() {
  local account_id="$1" token="$2"
  umask 077
  mkdir -p "$(dirname "$ENV_FILE")"
  {
    echo '#!/usr/bin/env bash'
    echo '# Cloudflare credentials for cwm. Created by setup-env.sh. Do not commit.'
    printf 'export CLOUDFLARE_ACCOUNT_ID=%q\n' "$account_id"
    printf 'export CLOUDFLARE_API_TOKEN=%q\n' "$token"
  } >"$ENV_FILE"
  chmod 600 "$ENV_FILE"
  echo "Wrote $ENV_FILE"
}

main() {
  confirm_overwrite
  echo "Find both values in the Cloudflare dashboard: Account home > Account ID, and"
  echo "My Profile (or Manage Account) > API Tokens. The token is not shown while you type."
  local account_id token
  account_id="$(prompt_value "Cloudflare account ID" no)"
  token="$(prompt_value "Cloudflare API token" yes)"
  check_credentials "$account_id" "$token"
  write_env_file "$account_id" "$token"
}

main "$@"
