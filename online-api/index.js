const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

const API_KEYS = new Set([
    "KEY-123",
    "KEY-456"
]);

const users = {};

function validKey(key) {
    return API_KEYS.has(key);
}

function page(content, title = "Сайт") {
    return `
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>${title}</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 40px;
            background: #000;
            color: #fff;
            font-family: Arial, sans-serif;
        }

        h1, h2, h3 {
            color: #fff;
        }

        p {
            color: #fff;
        }

        a {
            color: #fff;
        }

        button,
        input {
            background: #111;
            color: #fff;
            border: 1px solid #444;
            padding: 10px;
        }
    </style>
</head>

<body>
    ${content}

    <script>
        const titles = [
            "idi",
            "nahui",
            "Не мой сайт",
            "Ладно, мой",
            "a i idi nahui"
        ];

        let i = 0;

        setInterval(() => {
            document.title = titles[i];
            i = (i + 1) % titles.length;
        }, 1000);
    </script>
</body>
</html>
    `;
}

app.get("/", (req, res) => {
    res.send(page(`
        <h1>Моя главная страница</h1>

        <p>Poka!</p>

        <p>
            Здесь ты можешь не написать всё, что хочешь.
        </p>

        <p>
            idi nahui
        </p>
    `, "не Главная"));
});

app.get("/ping", (req, res) => {
    const key = req.query.key;
    const user = req.query.user;

    if (!validKey(key)) {
        return res
            .status(403)
            .send("Invalid API Key or PASOL NAHUI UEBAK");
    }

    if (!user) {
        return res
            .status(400)
            .send("Missing user or PASOL NAHUI UEBAK");
    }

    users[user] = Date.now();

    res.send("pasol nahui at suda");
});

app.get("/online", (req, res) => {
    const now = Date.now();

    let online = 0;

    for (const id in users) {
        if (now - users[id] < 30000) {
            online++;
        }
    }

    res.json({
        online
    });
});

setInterval(() => {
    const now = Date.now();

    for (const id in users) {
        if (now - users[id] > 60000) {
            delete users[id];
        }
    }
}, 30000);

app.listen(PORT, () => {
    console.log("karose pusk w robotait");
});
