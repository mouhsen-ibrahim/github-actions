import express from "express";
import morgan from "morgan";

const app = express();
const PORT = Number(process.env.PORT) || 3000;

app.use(morgan("dev"));
app.use(express.json());

app.get("/", (_req, res) => res.send("Hello from Node.js + Express 👋"));
app.get("/api/healthz", (_req, res) => res.json({ status: "ok" }));
app.get("/api/time", (_req, res) =>
  res.json({ now: new Date().toISOString() }),
);

const server = app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

// --- graceful shutdown ---
function shutdown(signal: string) {
  console.log(`${signal} received, closing HTTP server...`);
  // force-exit if it hangs
  const force = setTimeout(() => {
    console.error("Forced shutdown.");
    process.exit(1);
  }, 10_000);
  force.unref();

  server.close((err) => {
    if (err) {
      console.error("Error closing server:", err);
      process.exit(1);
    }
    console.log("HTTP server closed cleanly.");
    process.exit(0);
  });
}

process.on("SIGINT", () => shutdown("SIGINT")); // Ctrl+C
process.on("SIGTERM", () => shutdown("SIGTERM")); // docker stop
