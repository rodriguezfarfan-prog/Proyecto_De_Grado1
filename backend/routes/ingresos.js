const express = require('express');
const router = express.Router();
const controller = require('../controllers/ingresosController');

router.get('/', controller.getIngresos);
router.post('/', controller.createIngreso);
router.delete('/:id', controller.deleteIngreso);

module.exports = router;