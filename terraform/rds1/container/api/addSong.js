// /api/addSong.js
const mysql = require('mysql2');
const express = require('express');
const router = express.Router();

const { getConnection } = require('./getConnection');

router.post('/addSong', async (req, res) => {
    const db = await getConnection();
    if (!db) return res.status(500).json({ error: 'DB connection failed' });

    const { song, album, artist } = req.body;
    const sql = 'INSERT INTO amit_table (song, album, artist) VALUES (?, ?, ?)';
    db.query(sql, [song, album, artist], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ status: 'OK' });
    });

    db.end();
});

module.exports = router;
