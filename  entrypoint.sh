### Inhalt für ⁠ entrypoint.sh ⁠ (komplette Datei)
⁠ bash
#!/usr/bin/env bash
set -euo pipefail

# Persist tool config on the Railway volume
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/data/.config}"
export HOME="${HOME:-/data}"
mkdir -p /data/.openclaw /data/.config

# Start tailscaled (userspace networking works on Railway without extra caps)
tailscaled \
--state=/data/.openclaw/tailscaled.state \
--socket=/data/.openclaw/tailscaled.sock \
--port=0 \
--tun=userspace-networking >/tmp/tailscaled.log 2>&1 &

sleep 1

# Authenticate non-interactively if authkey provided (recommended)
if [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
tailscale --socket=/data/.openclaw/tailscaled.sock up \
--authkey="${TAILSCALE_AUTHKEY}" \
--hostname="ballstories-gateway-1" \
--accept-dns=false --accept-routes=false || true
else
echo "WARN: TAILSCALE_AUTHKEY not set; tailscale will require manual auth after deploy."
fi

# Start the existing wrapper
exec node /app/src/server.js
