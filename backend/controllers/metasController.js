const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

exports.getMetas = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'Se requiere usuario_id' });

  try {
    const [rows] = await pool.query(
      'SELECT id, usuario_id, nombre, monto_objetivo, monto_actual, fecha_limite, descripcion FROM metas_ahorro WHERE usuario_id = ? ORDER BY fecha_limite ASC',
      [usuario_id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createMeta = async (req, res) => {
  try {
    const { usuario_id, nombre, monto_objetivo, monto_actual, fecha_limite, descripcion } = req.body;
    if (!usuario_id || !nombre || monto_objetivo === undefined || !fecha_limite) {
      return res.status(400).json({ error: 'Faltan campos requeridos' });
    }
    const id = uuidv4();
    await pool.query(
      'INSERT INTO metas_ahorro (id, usuario_id, nombre, monto_objetivo, monto_actual, fecha_limite, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, usuario_id, nombre, monto_objetivo, monto_actual || 0, fecha_limite, descripcion || null]
    );
    res.status(201).json({ id, usuario_id, nombre, monto_objetivo, monto_actual: monto_actual || 0, fecha_limite, descripcion });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteMeta = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM metas_ahorro WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Meta no encontrada' });
    res.json({ message: 'Meta eliminada' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};