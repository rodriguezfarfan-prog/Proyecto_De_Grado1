# PROYECTO FINUP - Contexto actual (versión estable)

## DESCRIPCIÓN
Aplicación móvil de educación financiera para estudiantes universitarios.
Permite diagnóstico financiero, simulación de compras, plan de ahorro y recomendaciones.
No tiene login. Se usa un usuario fijo (`USER_UUID_DE_PRUEBA`).

## ARQUITECTURA
Clean Architecture estricta:
- `lib/core/` → Value Objects (Monto, Fecha), errores, UseCase base.
- `lib/domain/` → Entidades, repositorios abstractos, casos de uso.
- `lib/data/` → Modelos JSON, datasources remotos (Dio), implementaciones de repositorios.
- `lib/presentation/` → MVVM con Riverpod (StateNotifierProvider), BaseViewModel genérico, estados sellados (Initial, Loading, Data, Error).
- `lib/di/` → GetIt para inyección de dependencias.
- `lib/router/` → GoRouter con ShellRoute y BottomNavigationBar.

## BASE DE DATOS Y BACKEND
MySQL en XAMPP, base de datos `finup_db`.
Backend Node.js/Express en carpeta `backend/`.
Endpoints (todos piden `usuario_id` en query):
- `GET /api/ingresos?usuario_id=...`
- `POST /api/ingresos`
- `DELETE /api/ingresos/:id`
- `GET /api/egresos?usuario_id=...`
- `POST /api/egresos`
- `DELETE /api/egresos/:id`
- `GET /api/metas?usuario_id=...`
- `POST /api/metas`
- `DELETE /api/metas/:id`

Tabla egresos: categorías ENUM('alimentacion','transporte','ocio','vivienda','educacion','otros').

## DOMINIO (entidades clave)
- `Ingreso`: id, monto (Monto), fecha, tipo (TipoIngreso: mensual, ocasional, beca, trabajo)
- `Egreso`: id, monto (Monto), fecha, categoria (CategoriaEgreso: alimentacion, transporte, ocio, vivienda, educacion, otros), recurrente
- `DiagnosticoResultado`: capacidadAhorro, totalIngresos, totalEgresos, porcentajeAhorro, habito (Excelente/Bueno/Ajustado/Deficitario), recomendacionesBasicas (lista de strings)
- `ComparativaGastos`: actual (Map<CategoriaEgreso, double>), ideal (Map<CategoriaEgreso, double>)

## LÓGICA DE DIAGNÓSTICO (50/30/20) (hay que actualizarla)
Se suman ingresos y egresos. Los egresos se agrupan por categoría. La distribución ideal se calcula así:
- vivienda: 35%, alimentacion: 25%, transporte: 15%, educacion: 10%, ocio: 10%, otros: 5% del total de gastos.
Clasificación del hábito: porcentajeAhorro = (ingresos - egresos)/ingresos*100.
≥20% Excelente, 10-19% Bueno, 0-9% Ajustado, <0% Deficitario. Esa es la logica actual del programa, la logica que se debe implementar es:

vamos a reestructurar la recoleccion de datos y el analisis de estos, porque ya no sera un usuario predeterminado, vamos a crear el incio de sesion para los usuarios y el formulario de recoleccion de datos, estamos trabajando con el sitema 50/30/20, para esto vamos a clasificar los gastos de la siguiente manera:

*   **GASTOS PRIMORDIALES:** Vivienda (arriendo/hipoteca), Estudio (matrículas/pensiones), Mercado/Canasta Familiar (comida para cocinar en casa), Servicios Públicos (luz, agua, gas), Cuidado Personal (aseo y estética diaria) y Deudas Actuales (solo cuotas mínimas obligatorias).

*   **ENTRETENIMIENTO:** Plataformas de streaming (Netflix, Spotify, apple tv, disney, hbo, primevideo.), Suscripciones/Membresías en línea (Twitch, xbox game pass, ps plus), Espectáculos (cine, conciertos, eventos, teatro) y Compra de videojuegos.Todo lo anterior se pedirá para el registro en caso tal que no paguen en alguno de esos gastos el usuario pone 0.

*   **OCIO:** Comida fuera de casa (restaurantes, cafés, domicilios, galguerías), Vicios (cigarrillos, vapeadores, alcohol), Salidas sociales (discotecas, planes con amigos) y compras en plataformas como temu, shein y similares.
Todo lo anterior se pedirá para el registro en caso tal que no paguen en alguno de esos gastos el usuario pone 0.

Para el dashboard sigue todo igual se lee el ingreso, pero los gastos entonces como todo se recoge de la base de datos mediante varios gastos separados se deben sumar automaticamente para poder dar el valor total de todos los gastos.

Para la pantalla de diagnostico, se seguira mostrando la capacidad de ahorro pero ahora necesito que el grafico de barras muestre solo las 3 categorias de gastos y su respectiva optimizacion siguiendo los siguientes parametros:

Para pintar las barras "Ideales" en el gráfico junto a las "Actuales", debemoss aplicar esta lógica matemática basada en los Ingresos Mensuales Totales del usuario:

1.  **Gastos Primordiales (50)(Ideal):** El valor Ideal SIEMPRE debe ser igual al valor Actual. en pocas palabras no debe salir barra de optimizacion.

2.  **Entretenimiento (30)(Ideal):** este gasto comparte el 30% con ocio, pero es mas importante. El valor Ideal debe ser igual al valor Actual mismo caso que en los gastos primordiales, con la unica excepcion que este gasto se puede optimizar en caso tal que supere el 15% de los ingresos totales del usuario. Si lo supera, el Ideal se fijará exactamente en el equivalente al 15% de sus ingresos, mostrando en las recomendaciones abajo del grafico cuanto debria gastar en cada gasto registrado (cine,conciertos,etc).

3.  **Ocio (30)(Ideal):**este gasto comparte el 30% con entretenimiento. El valor Ideal se fijará exactamente en el equivalente al 10% de sus ingresos, mostrando en las recomendaciones abajo del grafico cuanto deberia gastar en cada gasto registrado(vicios, salidas, restaurantes, etc)esta suma de los gastos recomendados para cada uno de los gastos registrados debe ser igual al 10% del ingreso total. este sera el diferencial para optimizar el ahorro se dará una nueva capacidad de ahorro esperada para el siguiente mes, gracias a esto se puede recomendar que con la cantidad que se va a adicionar al ahorro se pueda ahorrarla o agregarla a los pagos de deudas para salir mas rapido.

**Restricción:** No propongas reducir gastos primordiales bajo ninguna circunstancia.

para el caso como lo es el ocio y el entretenimiento, como ya se explicó abajo del grafico debe salir cada gasto registrado con su optimizacion o recomendacion correspondiente, por ejemplo si el total de su gasto en ocio o entretenimento superan los porcentajes indicados indicados se debe optimizar cada uno de los gastos que tiene para reducir ese total al porcentaje indicado.

entonces hay que reestructurar todo lo que sea necesario para hacer esto, ya sea el json la base de datos y etc.

## PANTALLAS
Navegación inferior: Dashboard, Diagnóstico, Simulación, Ahorro, Tips.
- **Dashboard**: muestra hábito, capacidad de ahorro, y acceso rápido.
- **Diagnóstico**: gráfico de barras con 6 categorías (actual vs ideal) y recomendaciones.
- **Simulación**: calculadora de compra con diferentes métodos de pago (contado, tarjeta de crédito, crédito consumo, compra ahora paga después, préstamo informal).
- **Ahorro**: plan de ahorro para meta específica.
- **Tips**: recomendaciones adaptativas.

## INYECCIÓN DE DEPENDENCIAS
`Dio` configurado con `baseUrl: 'http://10.0.2.2:3000/api'`.
Todos los repositorios usan `USER_UUID_DE_PRUEBA` como usuario fijo.
No hay autenticación ni tokens.

## Base de Datos

la base de datos actual es: 
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS finup_db 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- Seleccionar la base de datos
USE finup_db;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id CHAR(36) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    nivel_financiero ENUM('principiante', 'intermedio', 'avanzado') NOT NULL,
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- Tabla de ingresos
CREATE TABLE IF NOT EXISTS ingresos (
    id CHAR(36) PRIMARY KEY,
    usuario_id CHAR(36) NOT NULL,
    monto DECIMAL(12,2) NOT NULL CHECK (monto >= 0),
    fecha DATETIME NOT NULL,
    descripcion VARCHAR(255),
    tipo ENUM('mensual','ocasional','beca','trabajo') NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_ingresos_usuario_fecha (usuario_id, fecha)
) ENGINE=InnoDB;

-- Tabla de egresos
CREATE TABLE IF NOT EXISTS egresos (
    id CHAR(36) PRIMARY KEY,
    usuario_id CHAR(36) NOT NULL,
    monto DECIMAL(12,2) NOT NULL CHECK (monto >= 0),
    fecha DATETIME NOT NULL,
    descripcion VARCHAR(255),
    categoria ENUM('alimentacion','transporte','ocio','vivienda','educacion','otros') NOT NULL,
    recurrente BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_egresos_usuario_fecha (usuario_id, fecha)
) ENGINE=InnoDB;

-- Tabla de metas de ahorro
CREATE TABLE IF NOT EXISTS metas_ahorro (
    id CHAR(36) PRIMARY KEY,
    usuario_id CHAR(36) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    monto_objetivo DECIMAL(12,2) NOT NULL CHECK (monto_objetivo > 0),
    monto_actual DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (monto_actual >= 0),
    fecha_limite DATE NOT NULL,
    descripcion VARCHAR(500),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_metas_usuario (usuario_id)
) ENGINE=InnoDB;

-- Asegurar el usuario de prueba
INSERT IGNORE INTO usuarios (id, nombre, email, nivel_financiero)
VALUES ('USER_UUID_DE_PRUEBA', 'Estudiante Test', 'test@finup.com', 'principiante');

-- Ingresos
INSERT INTO ingresos (id, usuario_id, monto, fecha, tipo)
VALUES (UUID(), 'USER_UUID_DE_PRUEBA', 1500.00, NOW(), 'beca');

-- Egresos
INSERT INTO egresos (id, usuario_id, monto, fecha, categoria, recurrente)
VALUES 
  (UUID(), 'USER_UUID_DE_PRUEBA', 200.00, NOW(), 'alimentacion', TRUE),
  (UUID(), 'USER_UUID_DE_PRUEBA', 120.00, NOW(), 'transporte', TRUE),
  (UUID(), 'USER_UUID_DE_PRUEBA', 80.00, NOW(), 'ocio', FALSE);

-- Meta de ahorro
INSERT INTO metas_ahorro (id, usuario_id, nombre, monto_objetivo, monto_actual, fecha_limite)
VALUES ('META_PRUEBA_001', 'USER_UUID_DE_PRUEBA', 'Laptop', 2000.00, 100.00, '2026-12-31');

##  IMPORTANTE:
 ESa base de datos es unicamente para probar la aplicacion entonces esta sujeta a los cambios que sugieras para crear un pagina de incio de sesion al abrir la aplicacion y que el usuario inicie sesion con su correo y contraseña de minimo 8 caracteres con una mayuscula una minuscula numeros y un caracter especial, no hace falta que sea el login mas seguro o avanzado porque es un proyecto de grado solo es necesario crear un MVP. por lo tanto debes crear o modificar todo lo necesario para que esto sea posible. Al inciar sesion debe abrir el formulario para llenar los datos, nombres apellidos, ingresos y todos los gastos anterior mente mencionados, si no tiene alguno el usuario puede ponerle 0 osea no gasta nada en eso, deben salir todos los gastos mencionados en primordiales, entretenimiento y ocio.
al finalizar todos los gastos se suman para saber el total de ingresos, el total de egresos y la capacidad de ahorro. Entonces segun esto la base de datos esta sujeta a los cambios que suieras para poder hacer estas operaciones posibles.

otro dato, no se porque la pagina de metas de ahorro no muestra nada, deberia mostrar la meta "Laptop" que esta en la base de datos.Asi que revisa que pasa con eso. y si hay que cambiar la base de datos para que funcione mejor cambiala pero asegurate de que se mantenga la logica.

## REGLAS PARA GENERACIÓN DE CÓDIGO
- Mantener Clean Architecture y MVVM.
- Seguridad de los datos
- Mantener la arquitectura de capas
- Mantener el estilo de diseño, colores y el tema de la aplicacion dados en dashborad_page.dart
