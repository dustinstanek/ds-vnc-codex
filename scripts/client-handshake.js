import WebSocket from "ws";

const url = process.argv[2];
if (!url) {
  console.error("Usage: node client-handshake.js <ws-url>");
  process.exit(1);
}

const ws = new WebSocket(url);

ws.on("open", () => {
  console.log("Client connected");
});

ws.on("message", (data) => {
  const msg = data.toString();
  console.log("Received:", msg);
  if (msg.includes("host_id")) {
    ws.send("ack");
    ws.close();
  } else {
    console.error("Unexpected message");
    process.exit(1);
  }
});

ws.on("close", () => {
  process.exit(0);
});

ws.on("error", (err) => {
  console.error(err);
  process.exit(1);
});
