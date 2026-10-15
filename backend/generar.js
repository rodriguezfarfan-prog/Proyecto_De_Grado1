const bcrypt = require('bcryptjs');

const password = 'Hola1234.1';

bcrypt.genSalt(10, (err, salt) => {
    bcrypt.hash(password, salt, (err, hash) => {
        console.log('Contraseña:', password);
        console.log('Hash generado:', hash);
    });
});