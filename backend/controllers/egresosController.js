const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

const GRUPOS_VALIDOS = ['necesidad', 'entretenimiento', 'ocio', 'ahorro_deuda'];

const SUBCATEGORIAS_VALIDAS = {
  necesidad: [
    'arriendo', 'administracion', 'agua', 'luz', 'gas', 'mantenimiento_hogar',
    'mercado', 'ropa', 'plan_celular', 'internet', 'transporte', 'seguros',
    'salud', 'educacion', 'cuidado_personal', 'pago_minimo_deudas', 'hijos', 'vehiculo'
  ],
  entretenimiento: [
    'streaming', 'videojuegos', 'cine', 'conciertos', 'suscripciones', 'deportes', 'hobbies'
  ],
  ocio: [
    'domicilios', 'apuestas', 'bares', 'alcohol', 'cigarrillo', 'restaurantes',
    'gimnasio', 'viajes', 'libros', 'mascotas', 'jardineria', 'museos',
    'cursos', 'clubes', 'compras_online', 'gadgets'
  ],
  ahorro_deuda: ['ahorro_meta', 'pago_extra_deuda']
};

exports.getEgresos = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'usuario_id requerido' });
  try {
    const [rows] = await pool.query(
      'SELECT * FROM egresos WHERE usuario_id = ? ORDER BY fecha DESC',
      [usuario_id]
    );
    const egresos = rows.map(row => ({ ...row, recurrente: row.recurrente === 1 }));
    res.json(egresos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createEgreso = async (req, res) => {
  try {
    const { usuario_id, monto, fecha, descripcion, grupo, subcategoria, recurrente } = req.body;
    if (!usuario_id || monto === undefined || !fecha || !grupo || !subcategoria) {
      return res.status(400).json({ error: 'Campos obligatorios: usuario_id, monto, fecha, grupo, subcategoria' });
    }
    if (!GRUPOS_VALIDOS.includes(grupo)) {
      return res.status(400).json({ error: `Grupo no válido: ${grupo}` });
    }
    if (!SUBCATEGORIAS_VALIDAS[grupo].includes(subcategoria)) {
      return res.status(400).json({ error: `Subcategoría "${subcategoria}" no válida para "${grupo}"` });
    }
    const id = uuidv4();
    await pool.query(
      'INSERT INTO egresos (id, usuario_id, monto, fecha, descripcion, grupo, subcategoria, recurrente) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, usuario_id, monto, fecha, descripcion || null, grupo, subcategoria, recurrente ? 1 : 0]
    );
    res.status(201).json({ id, usuario_id, monto, fecha, descripcion, grupo, subcategoria, recurrente });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateEgreso = async (req, res) => {
  try {
    const { id } = req.params;
    const { monto, fecha, descripcion, grupo, subcategoria, recurrente } = req.body;
    if (!monto || !fecha || !grupo || !subcategoria) {
      return res.status(400).json({ error: 'Faltan campos' });
    }
    await pool.query(
      'UPDATE egresos SET monto = ?, fecha = ?, descripcion = ?, grupo = ?, subcategoria = ?, recurrente = ? WHERE id = ?',
      [monto, fecha, descripcion || null, grupo, subcategoria, recurrente ? 1 : 0, id]
    );
    res.json({ id, monto, fecha, descripcion, grupo, subcategoria, recurrente });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteEgreso = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM egresos WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'No encontrado' });
    res.json({ message: 'Eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};