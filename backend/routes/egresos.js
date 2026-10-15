const express = require('express');
const router = express.Router();
const controller = require('../controllers/egresosController');

router.get('/', controller.getEgresos);
router.post('/', controller.createEgreso);
router.put('/:id', controller.updateEgreso);
router.delete('/:id', controller.deleteEgreso);

module.exports = router;