const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

// ═══════════════════════════════════════════════════════════════
// OBTENER PERFIL DE GAMIFICACIÓN
// ═══════════════════════════════════════════════════════════════
exports.getPerfil = async (req, res) => {
    const { usuario_id } = req.query;
    if (!usuario_id) return res.status(400).json({ error: 'usuario_id requerido' });
    try {
        const [users] = await pool.query(
            'SELECT id, nombre, email, puntos, racha_actual, ultima_visita FROM usuarios WHERE id = ?',
            [usuario_id]
        );
        if (users.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
        const [logros] = await pool.query(
            'SELECT logro_id, fecha FROM logros_usuario WHERE usuario_id = ? ORDER BY fecha DESC',
            [usuario_id]
        );
        res.json({
            usuario: users[0],
            logros: logros.map(l => ({ logro_id: l.logro_id, fecha: l.fecha })),
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ═══════════════════════════════════════════════════════════════
// SUMAR PUNTOS MANUALMENTE
// ═══════════════════════════════════════════════════════════════
exports.sumarPuntos = async (req, res) => {
    try {
        const { usuario_id, puntos } = req.body;
        if (!usuario_id || !puntos || puntos <= 0) {
            return res.status(400).json({ error: 'usuario_id y puntos son obligatorios' });
        }
        await pool.query('UPDATE usuarios SET puntos = puntos + ? WHERE id = ?', [puntos, usuario_id]);
        const [rows] = await pool.query('SELECT puntos FROM usuarios WHERE id = ?', [usuario_id]);
        res.json({ puntos: rows[0].puntos });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ═══════════════════════════════════════════════════════════════
// DESBLOQUEAR LOGRO (una sola vez por usuario)
// ═══════════════════════════════════════════════════════════════
exports.desbloquearLogro = async (req, res) => {
    try {
        const { usuario_id, logro_id, puntos } = req.body;
        if (!usuario_id || !logro_id) {
            return res.status(400).json({ error: 'usuario_id y logro_id son obligatorios' });
        }
        const [existente] = await pool.query(
            'SELECT id FROM logros_usuario WHERE usuario_id = ? AND logro_id = ?',
            [usuario_id, logro_id]
        );
        if (existente.length > 0) {
            return res.json({ nuevo: false, puntos: 0 });
        }
        const id = uuidv4();
        await pool.query(
            'INSERT INTO logros_usuario (id, usuario_id, logro_id) VALUES (?, ?, ?)',
            [id, usuario_id, logro_id]
        );
        if (puntos && puntos > 0) {
            await pool.query('UPDATE usuarios SET puntos = puntos + ? WHERE id = ?', [puntos, usuario_id]);
        }
        const [rows] = await pool.query('SELECT puntos FROM usuarios WHERE id = ?', [usuario_id]);
        res.json({ nuevo: true, puntos: puntos || 0, puntosTotales: rows[0].puntos });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ═══════════════════════════════════════════════════════════════
// PUNTOS RECURRENTES con tope global diario de 200
// ═══════════════════════════════════════════════════════════════
const PUNTOS_POR_ACCION = {
    ingreso: 10,
    gasto: 10,
    calculo: 10,
    meta: 30,
    abono: 30,
};
const MAX_PUNTOS_DIA = 200;

exports.registrarAccion = async (req, res) => {
    try {
        const { usuario_id, tipo_accion } = req.body;
        if (!usuario_id || !tipo_accion) {
            return res.status(400).json({ error: 'usuario_id y tipo_accion son obligatorios' });
        }
        const puntosBase = PUNTOS_POR_ACCION[tipo_accion];
        if (!puntosBase) {
            return res.status(400).json({ error: `Tipo de acción no válido: ${tipo_accion}` });
        }
        const hoy = new Date().toISOString().split('T')[0];
        const [rows] = await pool.query(
            'SELECT COALESCE(SUM(puntos_acumulados), 0) AS total FROM puntos_diarios WHERE usuario_id = ? AND fecha = ?',
            [usuario_id, hoy]
        );
        const totalHoy = Number(rows[0].total) || 0;
        if (totalHoy >= MAX_PUNTOS_DIA) {
            return res.json({
                puntosOtorgados: 0,
                topeAlcanzado: true,
                puntosHoy: totalHoy,
                topeDiario: MAX_PUNTOS_DIA,
            });
        }
        const puntosAOtorgar = Math.min(puntosBase, MAX_PUNTOS_DIA - totalHoy);
        const [existe] = await pool.query(
            'SELECT id FROM puntos_diarios WHERE usuario_id = ? AND fecha = ? AND tipo_accion = ?',
            [usuario_id, hoy, tipo_accion]
        );
        if (existe.length > 0) {
            await pool.query(
                'UPDATE puntos_diarios SET puntos_acumulados = puntos_acumulados + ? WHERE id = ?',
                [puntosAOtorgar, existe[0].id]
            );
        } else {
            await pool.query(
                'INSERT INTO puntos_diarios (id, usuario_id, fecha, tipo_accion, puntos_acumulados) VALUES (?, ?, ?, ?, ?)',
                [uuidv4(), usuario_id, hoy, tipo_accion, puntosAOtorgar]
            );
        }
        await pool.query('UPDATE usuarios SET puntos = puntos + ? WHERE id = ?', [puntosAOtorgar, usuario_id]);
        const [userRows] = await pool.query('SELECT puntos FROM usuarios WHERE id = ?', [usuario_id]);
        res.json({
            puntosOtorgados: puntosAOtorgar,
            topeAlcanzado: false,
            totalPuntos: userRows[0].puntos,
            puntosHoy: totalHoy + puntosAOtorgar,
            topeDiario: MAX_PUNTOS_DIA,
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ═══════════════════════════════════════════════════════════════
// RACHA DIARIA (streak)
// Días 1-2: +10 puntos por día
// Día 3+: +30 puntos por día
// Si no entra un día → se reinicia a 1
// ═══════════════════════════════════════════════════════════════
exports.registrarRacha = async (req, res) => {
    try {
        const { usuario_id } = req.body;
        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id es obligatorio' });
        }

        const [rows] = await pool.query(
            'SELECT racha_actual, ultima_visita FROM usuarios WHERE id = ?',
            [usuario_id]
        );
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const hoy = new Date().toISOString().split('T')[0];
        const rachaActual = rows[0].racha_actual || 0;
        const ultimaVisita = rows[0].ultima_visita
            ? new Date(rows[0].ultima_visita).toISOString().split('T')[0]
            : null;

        // Si ya registró hoy, no hacer nada
        if (ultimaVisita === hoy) {
            return res.json({
                rachaActual,
                puntosOtorgados: 0,
                yaRegistrado: true,
            });
        }

        // Calcular ayer
        const ayer = new Date();
        ayer.setDate(ayer.getDate() - 1);
        const ayerStr = ayer.toISOString().split('T')[0];

        let nuevaRacha;
        let puntosOtorgados;

        if (ultimaVisita === ayerStr) {
            // Vino ayer → continuar racha
            nuevaRacha = rachaActual + 1;
        } else {
            // No vino ayer (o es su primera vez) → reiniciar
            nuevaRacha = 1;
        }

        // Calcular puntos según la racha
        puntosOtorgados = nuevaRacha <= 2 ? 10 : 30;

        // Actualizar usuario
        await pool.query(
            'UPDATE usuarios SET racha_actual = ?, ultima_visita = ?, puntos = puntos + ? WHERE id = ?',
            [nuevaRacha, hoy, puntosOtorgados, usuario_id]
        );

        const [userRows] = await pool.query(
            'SELECT puntos FROM usuarios WHERE id = ?',
            [usuario_id]
        );

        res.json({
            rachaActual: nuevaRacha,
            puntosOtorgados,
            yaRegistrado: false,
            totalPuntos: userRows[0].puntos,
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};