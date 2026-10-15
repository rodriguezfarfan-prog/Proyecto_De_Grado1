const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

const TIPOS_VALIDOS = ['sueldo', 'independiente', 'otros', 'beca', 'trabajo'];

exports.getIngresos = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'usuario_id requerido' });
  try {
    const [rows] = await pool.query(
      'SELECT * FROM ingresos WHERE usuario_id = ? ORDER BY fecha DESC',
      [usuario_id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createIngreso = async (req, res) => {
  try {
    const { usuario_id, monto, fecha, tipo, descripcion } = req.body;
    if (!usuario_id || monto === undefined || !fecha || !tipo) {
      return res.status(400).json({ error: 'Faltan campos: usuario_id, monto, fecha, tipo' });
    }
    if (!TIPOS_VALIDOS.includes(tipo)) {
      return res.status(400).json({ error: `Tipo no válido: ${tipo}` });
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

exports.updateIngreso = async (req, res) => {
  try {
    const { id } = req.params;
    const { monto, fecha, tipo, descripcion } = req.body;
    if (!monto || !fecha || !tipo) {
      return res.status(400).json({ error: 'Faltan campos' });
    }
    await pool.query(
      'UPDATE ingresos SET monto = ?, fecha = ?, descripcion = ?, tipo = ? WHERE id = ?',
      [monto, fecha, descripcion || null, tipo, id]
    );
    res.json({ id, monto, fecha, descripcion, tipo });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteIngreso = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM ingresos WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'No encontrado' });
    res.json({ message: 'Eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};