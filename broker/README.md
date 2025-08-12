# Broker Service

This service coordinates host registration and client connections, relaying WebRTC/SSH offers between peers.

## Endpoints

### REST
- `POST /register` – register a host. Body: `{ "hostId": "optional" }`.
- `POST /connect` – check if a host is available. Body: `{ "hostId": "id" }`.
- `POST /keepalive` – refresh host presence. Body: `{ "hostId": "id" }`.

### WebSocket
- `ws://<host>:<port>/connect?hostId=<id>&role=host|client` – forwards messages between host and client.

## Running locally
1. Install dependencies: `npm install`.
2. Start the server: `npm start`.
3. Set `PORT` to choose the listening port (default `3000`).
4. Optionally set `REDIS_URL` to persist host presence in Redis.

## Self-hosted deployment
1. Ensure Node.js 18+ is installed on the host.
2. Clone the repository and run `npm install` inside the `broker` directory.
3. Run `npm start` (or manage with a process manager like `pm2` or `systemd`).
4. Optionally run a Redis instance and provide `REDIS_URL` to the service.

## Cloud deployment
1. Build a container image:
   ```Dockerfile
   FROM node:18-alpine
   WORKDIR /app
   COPY broker/package*.json ./
   RUN npm install --only=production
   COPY broker/ .
   CMD ["node", "server.js"]
   ```
2. Push the image to your registry.
3. Deploy to your preferred platform (Kubernetes, ECS, Cloud Run, etc.) exposing the desired port.
4. Configure environment variables (`PORT`, `REDIS_URL`) via your platform.
