const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Rutas
app.use('/api/usuarios', require('./routes/usuarios'));
app.use('/api/ingresos', require('./routes/ingresos'));
app.use('/api/egresos', require('./routes/egresos'));
app.use('/api/metas', require('./routes/metas'));

// Ruta de prueba
app.get('/', (req, res) => res.send('API FinUp corriendo'));

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});