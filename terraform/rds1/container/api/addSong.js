// /api/addSong.js
const express = require('express');
const router = express.Router();
const { getConnection } = require('./getConnection');

router.post('/addSong', async (req, res) => {
  const { song, album, artist } = req.body;
  
  // Validate input
  if (!song || !album || !artist) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  try {
    // Get a connection from the pool
    const connection = await getConnection();
    
    // Execute the query with prepared statement to prevent SQL injection
    const [result] = await connection.query(
      'INSERT INTO amit_table (song, album, artist) VALUES (?, ?, ?)', 
      [song, album, artist]
    );
    
    // Release the connection back to the pool
    connection.release();
    
    res.status(201).json({ 
      success: true, 
      id: result.insertId
    });
  } catch (err) {
    console.error('Error adding song:', err);
    res.status(500).json({ 
      error: 'Database error occurred', 
      details: process.env.NODE_ENV === 'development' ? err.message : undefined 
    });
  }
});

module.exports = router;