// Fixed /api/getSongs.js
const express = require('express');
const router = express.Router();
const { getConnection } = require('./getConnection');

router.get('/getSongs', async (req, res) => {
  try {
    // Get a connection from the pool
    const connection = await getConnection();
    
    // Execute the query
    const [results] = await connection.query('SELECT song, album, artist FROM amit_table');
    
    // Release the connection back to the pool
    connection.release();
    
    // Return results
    res.json(results);
  } catch (err) {
    console.error('Error getting songs:', err);
    res.status(500).json({ 
      error: 'Database error occurred', 
      details: process.env.NODE_ENV === 'development' ? err.message : undefined 
    });
  }
});

module.exports = router;
