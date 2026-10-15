const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

// Obtener metas del usuario
exports.getMetas = async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) return res.status(400).json({ error: 'usuario_id requerido' });
  try {
    const [rows] = await pool.query(
      'SELECT * FROM metas_ahorro WHERE usuario_id = ? ORDER BY fecha_limite ASC',
      [usuario_id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Crear meta
exports.createMeta = async (req, res) => {
  try {
    const { usuario_id, nombre, monto_objetivo, monto_actual, fecha_limite, descripcion, abono_mensual_fijo } = req.body;
    if (!usuario_id || !nombre || !monto_objetivo || !fecha_limite) {
      return res.status(400).json({ error: 'Faltan campos: usuario_id, nombre, monto_objetivo, fecha_limite' });
    }
    const id = uuidv4();
    const montoAct = monto_actual || 0;

    // Si el cliente no envía abono_mensual_fijo, lo calculamos aquí
    let abono = abono_mensual_fijo;
    if (!abono || abono <= 0) {
      const hoy = new Date();
      const limite = new Date(fecha_limite);
      const meses = Math.max(
        (limite.getFullYear() - hoy.getFullYear()) * 12 + (limite.getMonth() - hoy.getMonth()),
        1
      );
      abono = (monto_objetivo - montoAct) / meses;
    }

    await pool.query(
      'INSERT INTO metas_ahorro (id, usuario_id, nombre, monto_objetivo, monto_actual, abono_mensual_fijo, fecha_limite, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, usuario_id, nombre, monto_objetivo, montoAct, abono, fecha_limite, descripcion || null]
    );
    res.status(201).json({
      id, usuario_id, nombre,
      monto_objetivo,
      monto_actual: montoAct,
      abono_mensual_fijo: abono,
      fecha_limite,
      descripcion,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Eliminar meta
exports.deleteMeta = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM metas_ahorro WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'No encontrada' });
    res.json({ message: 'Eliminada' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Abonar a una meta Y registrar egreso automático
exports.abonarMeta = async (req, res) => {
  try {
    const { monto } = req.body;
    const { id } = req.params;

    if (!monto || monto <= 0) {
      return res.status(400).json({ error: 'El monto del abono debe ser positivo' });
    }

    // Buscar meta
    const [metas] = await pool.query('SELECT * FROM metas_ahorro WHERE id = ?', [id]);
    if (metas.length === 0) {
      return res.status(404).json({ error: 'Meta no encontrada' });
    }
    const meta = metas[0];
    const nuevoMonto = parseFloat(meta.monto_actual) + parseFloat(monto);

    if (nuevoMonto > parseFloat(meta.monto_objetivo)) {
      return res.status(400).json({ error: 'El abono supera el monto objetivo de la meta' });
    }

    // Actualizar meta
    await pool.query('UPDATE metas_ahorro SET monto_actual = ? WHERE id = ?', [nuevoMonto, id]);

    // ✅ Registrar el abono como EGRESO usando NOW() de MySQL (respeta la zona horaria del servidor)
    const egresoId = uuidv4();

    await pool.query(
      `INSERT INTO egresos (id, usuario_id, monto, fecha, descripcion, grupo, subcategoria, recurrente) 
       VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)`,
      [
        egresoId,
        meta.usuario_id,
        monto,
        `Abono a meta: ${meta.nombre}`,
        'ahorro_deuda',
        'ahorro_meta',
        0,
      ]
    );

    res.json({
      meta: { ...meta, monto_actual: nuevoMonto },
      egresoCreado: {
        id: egresoId,
        monto: parseFloat(monto),
        descripcion: `Abono a meta: ${meta.nombre}`,
        grupo: 'ahorro_deuda',
        subcategoria: 'ahorro_meta',
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};