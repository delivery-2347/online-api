const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

// 🔐 API KEYS (сюда добавляешь свои ключи)
const API_KEYS = new Set([
    "KEY-123",
    "KEY-456",
    "YOUR-SECRET-KEY"
]);

// 📊 активные пользователи
const users = {}; // key -> lastSeen

// 🔒 проверка ключа
function isValidKey(key) {
    return API_KEYS.has(key);
}

// 📡 heartbeat (ping)
app.get("/ping", (req, res) => {
    const key = req.query.key;

    if (!key || !isValidKey(key)) {
        return res.status(403).send("Invalid API key");
    }

    users[key] = Date.now();
    res.send("pong");
});

// 📊 онлайн пользователей
app.get("/online", (req, res) => {
    const now = Date.now();
    let count = 0;

    for (const key in users) {
        if (now - users[key] < 30000) {
            count++;
        }
    }

    res.json({
        online: count
    });
});

// 🧹 очистка старых пользователей
setInterval(() => {
    const now = Date.now();

    for (const key in users) {
        if (now - users[key] > 60000) {
            delete users[key];
        }
    }
}, 30000);

// 🚀 запуск сервера
app.listen(PORT, () => {
    console.log("API server running on port " + PORT);
});
