const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

const API_KEYS = new Set([
    "KEY-123",
    "KEY-456"
]);

// userId -> lastSeen
const users = {};

function validKey(key) {
    return API_KEYS.has(key);
}

app.get("/ping", (req, res) => {
    const key = req.query.key;
    const user = req.query.user;

    if (!validKey(key))
        return res.status(403).send("Invalid API Key");

    if (!user)
        return res.status(400).send("Missing user");

    users[user] = Date.now();

    res.send("pasol nahui at suda");
});

app.get("/online", (req, res) => {
    const now = Date.now();

    let online = 0;

    for (const id in users) {
        if (now - users[id] < 30000)
            online++;
    }

    res.json({
        online
    });
});

setInterval(() => {
    const now = Date.now();

    for (const id in users) {
        if (now - users[id] > 60000)
            delete users[id];
    }
}, 30000);

app.listen(PORT, () => {
    console.log("karose pusk w robotait");
});
