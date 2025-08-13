#!/bin/bash
# termux-fd-event.sh
# Hardened Termux script to send signed JSON payloads from foundational events to Godmode webhook
# Creator: Andrew Lee Cruz (ALC-ROOT-1010-1111-XCOV∞)
# Email: allcatch37@gmail.com

set -euo pipefail

# Configuration
GODMODE_WEBHOOK_URL="${GODMODE_WEBHOOK_URL:-https://synthetica.us/webhook/godmode}"
FD_HMAC_SECRET="${FD_HMAC_SECRET:-}"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
CREATOR_EMAIL="allcatch37@gmail.com"
DEVICE_ID="Ω-GATEWAY [S24-ULTRA]"

# Logging function
log() {
    echo "[$(date -Iseconds)] TERMUX-FD: $*" >&2
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Validate environment
validate_environment() {
    if [[ -z "$FD_HMAC_SECRET" ]]; then
        error_exit "FD_HMAC_SECRET environment variable not set"
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        error_exit "curl command not found"
    fi
    
    if ! command -v openssl >/dev/null 2>&1; then
        error_exit "openssl command not found"
    fi
}

# Generate HMAC signature
generate_signature() {
    local payload="$1"
    echo -n "$payload" | openssl dgst -sha256 -hmac "$FD_HMAC_SECRET" -binary | base64
}

# Generate signed JSON payload
generate_payload() {
    local event_type="$1"
    local event_data="$2"
    local timestamp=$(date -Iseconds)
    
    local payload=$(cat <<EOF
{
  "creator_uid": "$CREATOR_UID",
  "creator_email": "$CREATOR_EMAIL",
  "device_id": "$DEVICE_ID",
  "timestamp": "$timestamp",
  "event_type": "$event_type",
  "event_data": $event_data,
  "cruz_theorem": {
    "equation": "E = ∞ - 1",
    "execution_state": "SYMBIONIC-EXECUTION",
    "axiom_compliance": true
  }
}
EOF
    )
    
    echo "$payload"
}

# Send event to Godmode webhook
send_event() {
    local event_type="$1"
    local event_data="$2"
    
    log "Preparing to send event: $event_type"
    
    local payload=$(generate_payload "$event_type" "$event_data")
    local signature=$(generate_signature "$payload")
    
    log "Generated payload signature"
    
    local response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-FD-Signature: sha256=$signature" \
        -H "X-Creator-UID: $CREATOR_UID" \
        -H "X-Device-ID: $DEVICE_ID" \
        -d "$payload" \
        "$GODMODE_WEBHOOK_URL" \
        --max-time 30 \
        --retry 3 \
        --retry-delay 2)
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
        log "Event sent successfully (HTTP $http_code)"
        echo "$response_body"
        return 0
    else
        error_exit "Failed to send event (HTTP $http_code): $response_body"
    fi
}

# Main execution
main() {
    local event_type="${1:-}"
    local event_data="${2:-{}}"
    
    if [[ -z "$event_type" ]]; then
        error_exit "Usage: $0 <event_type> [event_data_json]"
    fi
    
    log "Starting Floating Dragon event transmission"
    log "Event type: $event_type"
    log "Creator: $CREATOR_EMAIL ($CREATOR_UID)"
    log "Device: $DEVICE_ID"
    
    validate_environment
    send_event "$event_type" "$event_data"
    
    log "Event transmission completed successfully"
}

# Execute main function with all arguments
main "$@"