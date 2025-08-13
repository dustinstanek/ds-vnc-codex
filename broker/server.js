const express = require("express");
const http = require("http");
const { WebSocketServer } = require("ws");
const { v4: uuidv4 } = require("uuid");
const Redis = require("ioredis");

const app = express();
app.use(express.json());

// Presence store: in-memory Map or Redis hash
const redisUrl = process.env.REDIS_URL;
let presenceStore;
if (redisUrl) {
  const redis = new Redis(redisUrl);
  presenceStore = {
    async set(id, data) {
      await redis.hset("hosts", id, JSON.stringify(data));
    },
    async get(id) {
      const res = await redis.hget("hosts", id);
      return res ? JSON.parse(res) : null;
    },
    async delete(id) {
      await redis.hdel("hosts", id);
    },
  };
} else {
  const hosts = new Map();
  presenceStore = {
    async set(id, data) {
      hosts.set(id, data);
    },
    async get(id) {
      return hosts.get(id);
    },
    async delete(id) {
      hosts.delete(id);
    },
  };
}

// Register host
app.post("/register", async (req, res) => {
  let { hostId } = req.body;
  if (!hostId) hostId = uuidv4();
  await presenceStore.set(hostId, { lastSeen: Date.now() });
  res.json({ hostId });
});

// Keep host alive
app.post("/keepalive", async (req, res) => {
  const { hostId } = req.body;
  if (!hostId) return res.status(400).json({ error: "hostId required" });
  const host = await presenceStore.get(hostId);
  if (!host) return res.status(404).json({ error: "host not found" });
  host.lastSeen = Date.now();
  await presenceStore.set(hostId, host);
  res.json({ ok: true });
});

// Basic connect check via REST
app.post("/connect", async (req, res) => {
  const { hostId } = req.body;
  if (!hostId) return res.status(400).json({ error: "hostId required" });
  const host = await presenceStore.get(hostId);
  if (!host) return res.status(404).json({ error: "host not found" });
  res.json({ ok: true });
});

const server = http.createServer(app);

// WebSocket for relaying offers
const wss = new WebSocketServer({ server, path: "/connect" });
const peers = new Map(); // hostId -> {host: ws, client: ws}

wss.on("connection", (ws, req) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const hostId = url.searchParams.get("hostId");
  const role = url.searchParams.get("role");
  if (!hostId || !role) {
    ws.close();
    return;
  }
  let pair = peers.get(hostId) || {};
  pair[role] = ws;
  peers.set(hostId, pair);

  ws.on("message", (msg) => {
    const target = pair[role === "host" ? "client" : "host"];
    if (target && target.readyState === target.OPEN) {
      target.send(msg);
    }
  });

  ws.on("close", () => {
    const current = peers.get(hostId);
    if (!current) return;
    current[role] = null;
    if (!current.host && !current.client) {
      peers.delete(hostId);
    } else {
      peers.set(hostId, current);
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Broker listening on port ${PORT}`);
});
