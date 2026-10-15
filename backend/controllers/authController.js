const pool = require('../db');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

// Registro
exports.registro = async (req, res) => {
    try {
        const { nombre, email, password } = req.body;

        if (!nombre || !email || !password) {
            return res.status(400).json({ error: 'Nombre, email y contraseña son obligatorios' });
        }

        // Validar contraseña fuerte
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;
        if (!passwordRegex.test(password)) {
            return res.status(400).json({
                error: 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial'
            });
        }

        // Verificar si el email ya existe
        const [existing] = await pool.query('SELECT id FROM usuarios WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(400).json({ error: 'El email ya está registrado' });
        }

        // Hashear contraseña
        const salt = await bcrypt.genSalt(10);
        const password_hash = await bcrypt.hash(password, salt);

        const id = uuidv4();
        await pool.query(
            'INSERT INTO usuarios (id, nombre, email, password_hash, nivel_financiero) VALUES (?, ?, ?, ?, ?)',
            [id, nombre, email, password_hash, 'principiante']
        );

        res.status(201).json({
            id,
            nombre,
            email,
            fecha_registro: new Date().toISOString(),
            nivel_financiero: 'principiante',
            mensaje: 'Usuario registrado exitosamente'
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Login
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email y contraseña son obligatorios' });
        }

        // Buscar usuario
        const [users] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ error: 'Email o contraseña incorrectos' });
        }

        const user = users[0];

        // Verificar contraseña
        const passwordValido = await bcrypt.compare(password, user.password_hash);
        if (!passwordValido) {
            return res.status(401).json({ error: 'Email o contraseña incorrectos' });
        }

        // Login exitoso: devolver datos del usuario (sin la contraseña)
        res.json({
            id: user.id,
            nombre: user.nombre,
            email: user.email,
            fecha_registro: user.fecha_registro,
            nivel_financiero: user.nivel_financiero,
            mensaje: 'Inicio de sesión exitoso'
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};