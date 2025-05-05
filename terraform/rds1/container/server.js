const express = require('express');
const app = express();
const getSongs = require('./api/getSongs');
const addSong = require('./api/addSong');

app.use(express.json());
app.use(express.static(__dirname)); // serve index.html
app.use('/api', getSongs);
app.use('/api', addSong);

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
