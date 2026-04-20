const express = require('express');
const path = require('path');
const { initDb } = require('./db/database');
const pollsRouter = require('./routes/polls');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());

app.use('/api/polls', pollsRouter);

const CLIENT_BUILD = path.join(__dirname, '../client/dist');
app.use(express.static(CLIENT_BUILD));
app.get('*', (_req, res) => {
  res.sendFile(path.join(CLIENT_BUILD, 'index.html'));
});

app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

initDb();
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
