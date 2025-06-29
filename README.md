# Cloudflare Tunnel for TCP/UDP Services

This configuration sets up a Cloudflare Tunnel that can handle arbitrary TCP/UDP traffic, not just HTTP/HTTPS.

## Prerequisites

1. A Cloudflare account with Argo Tunnel access
2. An existing Cloudflare Tunnel (reusing 'ryuzu-dev-tunnnel' from ingress controller)
3. Access to the existing cloudflare-api secret

## Setup

### Quick Setup (reusing existing secrets)

Run the setup script:
```bash
./setup-with-existing-secret.sh
```

This will:
1. Create the cloudflare-tunnel namespace
2. Copy the cloudflare-api secret from the ingress controller namespace
3. Guide you through creating the tunnel credentials

### Manual Setup

1. Copy existing secret from ingress controller:
   ```bash
   kubectl get secret cloudflare-api -n cloudflare-tunnel-ingress-controller -o yaml | \
     sed 's/namespace: cloudflare-tunnel-ingress-controller/namespace: cloudflare-tunnel/' | \
     kubectl apply -f -
   ```

2. Create tunnel credentials using one of these methods:
   
   **Option A - Using Tunnel Token (Recommended):**
   ```bash
   kubectl create secret generic cloudflare-tunnel-token \
     --from-literal=token=<YOUR_TUNNEL_TOKEN> \
     -n cloudflare-tunnel
   ```
   
   **Option B - Using credentials.json:**
   ```bash
   kubectl create secret generic cloudflare-tunnel-credentials \
     --from-file=credentials.json=/path/to/credentials.json \
     -n cloudflare-tunnel
   ```

3. Configure your services in `overlays/production/config.yaml`

4. Deploy:
   ```bash
   kubectl apply -k overlays/production/
   ```

## Configuration Examples

### TCP Service (e.g., Minecraft, databases, etc.)
```yaml
- hostname: minecraft.example.com
  service: tcp://minecraft-service.minecraft.svc.cluster.local:25565
```

### UDP Service
```yaml
- hostname: game.example.com
  service: udp://game-service.gaming.svc.cluster.local:7777
```

### Multiple Services
```yaml
- hostname: minecraft.example.com
  service: tcp://minecraft-service.minecraft.svc.cluster.local:25565
- hostname: postgres.example.com  
  service: tcp://postgres.database.svc.cluster.local:5432
- hostname: "*"
  service: http_status:404
```

## Deployment

Apply the configuration:
```bash
kubectl apply -k base/
```

Check deployment status:
```bash
kubectl get pods -n cloudflare-tunnel
kubectl logs -n cloudflare-tunnel deployment/cloudflared
```

## Notes

- This tunnel configuration is separate from your HTTP/HTTPS ingress controller
- Each TCP/UDP service needs its own hostname in Cloudflare DNS
- Cloudflare Tunnel supports arbitrary TCP but has some limitations on certain ports
- For production use, consider running multiple replicas for high availability