import os
from flask import Flask, request, jsonify

app = Flask(__name__)

# Simple in-memory store (reset on every restart)
ITEMS: list[dict] = []

@app.get("/")
def index():
    return jsonify({
        "app": "simple-test-app",
        "version": "1.0",
        "endpoints": ["/health", "/echo (GET/POST)", "/items (GET/POST/DELETE)"]
    })

@app.get("/health")
def health():
    return jsonify({"status": "ok"})

@app.get("/echo")
def echo_get():
    msg = request.args.get("msg", "")
    return jsonify({"echo": msg})

@app.post("/echo")
def echo_post():
    data = request.get_json(silent=True) or {}
    msg = data.get("msg") or data.get("message") or ""
    return jsonify({"echo": msg})

@app.get("/items")
def get_items():
    return jsonify(ITEMS)

@app.post("/items")
def add_item():
    data = request.get_json(silent=True) or {}
    # accept {"name": "..."} or {"item": "..."} or any JSON value
    if isinstance(data, dict) and "name" in data:
        name = data["name"]
    elif isinstance(data, dict) and "item" in data:
        name = data["item"]
    else:
        name = data
    item = {"id": len(ITEMS) + 1, "name": name}
    ITEMS.append(item)
    return jsonify(item), 201

@app.delete("/items/<int:item_id>")
def delete_item(item_id: int):
    global ITEMS
    before = len(ITEMS)
    ITEMS = [i for i in ITEMS if i["id"] != item_id]
    return jsonify({"delete": len(ITEMS) != before})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
