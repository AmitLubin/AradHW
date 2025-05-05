// /api/getSongs.js
const express = require('express');
const router = express.Router();

const { getConnection } = require('./getConnection');
const db = getConnection();
if (db == null) {
    console.log("db is null in getSongs");
}

router.get('/getSongs', async (req, res) => {
    const db = await getConnection();
    if (!db) return res.status(500).json({ error: 'DB connection failed' });

    db.query('SELECT song, album, artist FROM amit_table', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

db.end();

module.exports = router;
