const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Сообщения хранятся только в памяти.
// После перезапуска сервера всё очистится.
let messages = [];
let nextId = 1;

app.get("/ping", (req, res) => {
  res.json({ ok: true, time: Date.now() });
});

app.get("/messages", (req, res) => {
  const after = Number(req.query.after || 0);
  const result = messages.filter(m => m.id > after);
  res.json({ messages: result, lastId: messages.length ? messages[messages.length - 1].id : 0 });
});

app.post("/send", (req, res) => {
  const userId = Number(req.body.userId);
  const username = String(req.body.username || "").trim();
  const text = String(req.body.text || "").trim();

  if (!userId || !username || !text) {
    return res.status(400).json({ ok: false, error: "Missing userId, username or text" });
  }

  if (text.length > 200) {
    return res.status(400).json({ ok: false, error: "Message too long" });
  }

  const message = {
    id: nextId++,
    userId,
    username,
    text,
    time: new Date().toISOString()
  };

  messages.push(message);

  // Можно ограничить память
  if (messages.length > 200) {
    messages.shift();
  }

  res.json({ ok: true, message });
});

app.listen(PORT, () => {
  console.log(`Cucumber Messenger API running on port ${PORT}`);
});
