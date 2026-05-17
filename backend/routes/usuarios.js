const express = require('express');
const router = express.Router();
const controller = require('../controllers/usuariosController');

router.get('/', controller.getUsuarios);
router.get('/:id', controller.getUsuarioById);
router.post('/', controller.createUsuario);

module.exports = router;