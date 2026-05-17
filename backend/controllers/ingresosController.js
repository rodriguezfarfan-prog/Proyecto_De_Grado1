const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

// Obtener ingresos de un usuario (filtrado por usuario_id)
exports.getIngresos = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'Se requiere usuario_id' });

  try {
    const [rows] = await pool.query(
      'SELECT id, usuario_id, monto, fecha, descripcion, tipo FROM ingresos WHERE usuario_id = ? ORDER BY fecha DESC',
      [usuario_id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Crear un ingreso
exports.createIngreso = async (req, res) => {
  try {
    const { usuario_id, monto, fecha, descripcion, tipo } = req.body;
    if (!usuario_id || monto === undefined || !fecha || !tipo) {
      return res.status(400).json({ error: 'Faltan campos requeridos (usuario_id, monto, fecha, tipo)' });
    }
    const id = uuidv4();
    await pool.query(
      'INSERT INTO ingresos (id, usuario_id, monto, fecha, descripcion, tipo) VALUES (?, ?, ?, ?, ?, ?)',
      [id, usuario_id, monto, fecha, descripcion || null, tipo]
    );
    res.status(201).json({ id, usuario_id, monto, fecha, descripcion, tipo });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Eliminar un ingreso
exports.deleteIngreso = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM ingresos WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Ingreso no encontrado' });
    res.json({ message: 'Ingreso eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};