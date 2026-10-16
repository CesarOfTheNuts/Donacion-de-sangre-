require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (_req, res) => res.json({ ok: true, app: 'Blood Donation API' }));
app.use('/api/auth', require('./routes/auth'));
app.use('/api/donantes', require('./routes/donantes'));
app.use('/api/solicitudes', require('./routes/solicitudes'));

const port = process.env.PORT || 3000;
app.listen(port, '0.0.0.0', () => console.log(`API escuchando en http://localhost:${port}`));
