const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

// Obtener todos los usuarios
exports.getUsuarios = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM usuarios');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener un usuario por ID
exports.getUsuarioById = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM usuarios WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Crear un usuario
exports.createUsuario = async (req, res) => {
  try {
    const { nombre, email, nivel_financiero } = req.body;
    if (!nombre || !email || !nivel_financiero) {
      return res.status(400).json({ error: 'Faltan campos requeridos (nombre, email, nivel_financiero)' });
    }
    const id = uuidv4();
    await pool.query(
      'INSERT INTO usuarios (id, nombre, email, nivel_financiero) VALUES (?, ?, ?, ?)',
      [id, nombre, email, nivel_financiero]
    );
    res.status(201).json({
      id,
      nombre,
      email,
      nivel_financiero,
      fecha_registro: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};