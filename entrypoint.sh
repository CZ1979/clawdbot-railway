  #!/usr/bin/env bash
set -euo pipefail

# Persist tool config on the Railway volume
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/data/.config}"
export HOME="${HOME:-/data}"
mkdir -p /data/.openclaw /data/.config

# IMPORTANT:
# OpenClaw calls `tailscale status` without --socket, so it expects the default:
# /var/run/tailscale/tailscaled.sock
# Therefore we must run tailscaled on that socket.
mkdir -p /var/run/tailscale
export TAILSCALE_SOCKET=/var/run/tailscale/tailscaled.sock

# Start tailscaled (userspace networking works on Railway without extra caps)
tailscaled \
--state=/data/.openclaw/tailscaled.state \
--socket=/var/run/tailscale/tailscaled.sock \
--port=0 \
--tun=userspace-networking >/tmp/tailscaled.log 2>&1 &

sleep 1

# Authenticate non-interactively if authkey provided (recommended)
if [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
tailscale up \
--authkey="${TAILSCALE_AUTHKEY}" \
--hostname="ballstories-gateway-1" \
--accept-dns=false --accept-routes=false || true
else
echo "WARN: TAILSCALE_AUTHKEY not set; tailscale will require manual auth after deploy."
fi

# Ensure Gmail watch is started (creates watch state). Safe to re-run.
# Uses the topic you already had in the old setup.
gog gmail watch start \
  --account pete@ballstories.kids \
  --topic "projects/academic-atlas-489918-s1/topics/gmail-events" \
  --label "INBOX" \
  || true
 ⁠

# Start the existing wrapper
exec node /app/src/server.js
 ⁠
