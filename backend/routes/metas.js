const express = require('express');
const router = express.Router();
const controller = require('../controllers/metasController');

router.get('/', controller.getMetas);
router.post('/', controller.createMeta);
router.delete('/:id', controller.deleteMeta);
router.patch('/:id/abonar', controller.abonarMeta);

module.exports = router;