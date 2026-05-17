const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

exports.getEgresos = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'Se requiere usuario_id' });

  try {
    const [rows] = await pool.query(
      'SELECT id, usuario_id, monto, fecha, descripcion, categoria, recurrente FROM egresos WHERE usuario_id = ? ORDER BY fecha DESC',
      [usuario_id]
    );
    // Convertir recurrente (0/1) a booleano
    const egresos = rows.map(row => ({ ...row, recurrente: row.recurrente === 1 }));
    res.json(egresos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createEgreso = async (req, res) => {
  try {
    const { usuario_id, monto, fecha, descripcion, categoria, recurrente } = req.body;
    if (!usuario_id || monto === undefined || !fecha || !categoria) {
      return res.status(400).json({ error: 'Faltan campos requeridos' });
    }
    const id = uuidv4();
    await pool.query(
      'INSERT INTO egresos (id, usuario_id, monto, fecha, descripcion, categoria, recurrente) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, usuario_id, monto, fecha, descripcion || null, categoria, recurrente ? 1 : 0]
    );
    res.status(201).json({ id, usuario_id, monto, fecha, descripcion, categoria, recurrente: recurrente ? true : false });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteEgreso = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM egresos WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Egreso no encontrado' });
    res.json({ message: 'Egreso eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};