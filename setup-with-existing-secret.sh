#!/bin/bash

echo "Setting up Cloudflare Tunnel with existing secrets"
echo "=================================================="
echo ""

# Create namespace if it doesn't exist
kubectl create namespace cloudflare-tunnel --dry-run=client -o yaml | kubectl apply -f -

# Copy the API secret from ingress controller namespace
echo "Copying cloudflare-api secret from cloudflare-tunnel-ingress-controller namespace..."
kubectl get secret cloudflare-api -n cloudflare-tunnel-ingress-controller -o yaml | \
  sed 's/namespace: cloudflare-tunnel-ingress-controller/namespace: cloudflare-tunnel/' | \
  sed 's/name: cloudflare-api/name: cloudflare-api-copy/' | \
  kubectl apply -f -

echo ""
echo "Now you need to create the tunnel credentials secret."
echo "There are two ways to do this:"
echo ""
echo "Option 1: Using tunnel token (recommended for new setups):"
echo "  1. Go to Cloudflare dashboard > Zero Trust > Access > Tunnels"
echo "  2. Find your tunnel 'ryuzu-dev-tunnnel'"
echo "  3. Click on it and go to 'Configure' tab"
echo "  4. Copy the tunnel token"
echo "  5. Run: kubectl create secret generic cloudflare-tunnel-token --from-literal=token=<YOUR_TOKEN> -n cloudflare-tunnel"
echo ""
echo "Option 2: Using credentials.json file (if you have it from previous setup):"
echo "  1. Locate your tunnel's credentials.json file"
echo "  2. Run: kubectl create secret generic cloudflare-tunnel-credentials --from-file=credentials.json=<PATH_TO_FILE> -n cloudflare-tunnel"
echo ""
echo "After creating the secret, deploy with:"
echo "  kubectl apply -k overlays/production/"
echo ""
echo "To add services, edit overlays/production/config.yaml"