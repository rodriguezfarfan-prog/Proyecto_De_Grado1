class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email es obligatorio';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Formato de email inválido';
    return null;
  }

  static String? validateRequired(String? value, [String? label]) {
    if (value == null || value.trim().isEmpty) {
      return label != null ? '$label es obligatorio' : 'Campo obligatorio';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, [String? label]) {
    if (value == null || value.isEmpty) {
      return label != null ? '$label es obligatorio' : 'Campo obligatorio';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return label != null ? '$label debe ser un número positivo' : 'Debe ser un número positivo';
    }
    return null;
  }

  static String? validateMonto(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa un monto';
    final monto = double.tryParse(value);
    if (monto == null || monto < 0) return 'Monto no válido';
    return null;
  }
}