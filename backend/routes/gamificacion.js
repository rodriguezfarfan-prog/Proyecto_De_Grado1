const express = require('express');
const router = express.Router();
const controller = require('../controllers/gamificacionController');

router.get('/perfil', controller.getPerfil);
router.post('/puntos', controller.sumarPuntos);
router.post('/logro', controller.desbloquearLogro);
router.post('/accion', controller.registrarAccion);
router.post('/racha', controller.registrarRacha);

module.exports = router;