# Arquitectura MVC en Flutter - WASI App

## Estructura del Proyecto

La aplicación sigue el patrón **Modelo-Vista-Controlador (MVC)** organizado en capas para mantener una separación clara de responsabilidades.

```
lib/
├── models/                 # Modelos de datos (Entidades)
│   ├── usuario_model.dart
│   └── nino_model.dart
├── views/                  # Vistas (Interfaz de Usuario)
│   ├── login_view.dart
│   ├── home_view.dart
│   ├── create_user_view.dart
│   └── registro_nino_view.dart
├── controllers/            # Controladores (Lógica de negocio)
│   ├── auth_controller.dart
│   └── nino_controller.dart
├── services/              # Servicios (Acceso a datos)
│   ├── usuario_service.dart
│   └── nino_service.dart
├── utils/                 # Utilidades y helpers
│   ├── validators.dart
│   └── imc_calculator.dart
└── main_mvc.dart          # Punto de entrada con Provider
```

## Capas de la Arquitectura

### 1. **Modelos (Models)**
**Responsabilidad**: Representar las entidades de datos y su estructura.

- `UsuarioModel`: Representa los datos del usuario del sistema
- `NinoModel`: Representa los datos de los niños registrados

**Características**:
- Inmutables (usando `final`)
- Métodos `fromMap()` y `toMap()` para conversión con Firestore
- Método `copyWith()` para crear copias modificadas
- Validación básica de datos

### 2. **Vistas (Views)**
**Responsabilidad**: Mostrar la interfaz de usuario y capturar interacciones.

- `LoginView`: Pantalla de inicio de sesión
- `HomeView`: Pantalla principal
- `CreateUserView`: Formulario para crear usuarios
- `RegistroNinoView`: Formulario para registrar niños

**Características**:
- Solo contienen código de UI
- Usan `Consumer` o `Provider.of()` para escuchar cambios
- No contienen lógica de negocio
- Manejan la navegación entre pantallas

### 3. **Controladores (Controllers)**
**Responsabilidad**: Gestionar el estado de la aplicación y coordinar entre Modelos y Vistas.

- `AuthController`: Maneja autenticación y estado del usuario
- `NinoController`: Maneja CRUD de niños y búsquedas

**Características**:
- Extienden `ChangeNotifier` para notificación de cambios
- Contienen la lógica de negocio
- Coordinan llamadas a servicios
- Manejan estados de carga y errores
- Notifican cambios a las vistas

### 4. **Servicios (Services)**
**Responsabilidad**: Abstrae el acceso a datos externos (Firestore, APIs, etc.).

- `UsuarioService`: Operaciones CRUD para usuarios
- `NinoService`: Operaciones CRUD para niños

**Características**:
- Métodos estáticos para operaciones de datos
- Manejo de excepciones
- Abstracción de la fuente de datos
- Conversión entre formatos de datos

### 5. **Utilidades (Utils)**
**Responsabilidad**: Funciones auxiliares y herramientas comunes.

- `Validators`: Validaciones de formularios
- `IMCCalculator`: Cálculos médicos
- `DateTimeUtils`: Utilidades de fecha/hora

## Flujo de Datos

### Flujo Típico de una Operación:

1. **Vista** → Captura evento del usuario (ej: botón presionado)
2. **Vista** → Llama método del **Controlador**
3. **Controlador** → Ejecuta lógica de negocio
4. **Controlador** → Llama **Servicio** para datos
5. **Servicio** → Interactúa con Firestore usando **Modelos**
6. **Servicio** → Devuelve datos al **Controlador**
7. **Controlador** → Actualiza estado y notifica cambios
8. **Vista** → Se reconstruye automáticamente con nuevos datos

### Ejemplo: Login de Usuario

```dart
// 1. Vista captura datos
await authController.login(email, password);

// 2. Controlador procesa
Future<bool> login(String usuario, String contrasena) async {
  _setLoading(true);
  
  // 3. Llama al servicio
  final isValid = await UsuarioService.verificarCredenciales(usuario, contrasena);
  
  if (isValid) {
    // 4. Actualiza estado
    _usuarioActual = await UsuarioService.buscarPorUsuario(usuario);
    notifyListeners(); // 5. Notifica cambios
  }
  
  _setLoading(false);
  return isValid;
}

// 6. Vista se actualiza automáticamente
Consumer<AuthController>(
  builder: (context, authController, child) {
    if (authController.isLoggedIn) {
      return HomeView();
    }
    return LoginForm();
  },
)
```

## Ventajas de esta Arquitectura

### ✅ **Separación de Responsabilidades**
- Cada capa tiene una función específica
- Facilita el mantenimiento y testing
- Código más organizado y legible

### ✅ **Reutilización de Código**
- Servicios reutilizables entre diferentes controladores
- Modelos consistentes en toda la aplicación
- Utilidades compartidas

### ✅ **Testabilidad**
- Fácil mockear servicios para testing
- Controladores testeable independientemente
- Validaciones centralizadas

### ✅ **Escalabilidad**
- Fácil agregar nuevas funcionalidades
- Estructura clara para nuevos desarrolladores
- Mantenimiento simplificado

### ✅ **Gestión de Estado**
- Provider para manejo reactivo del estado
- Notificaciones automáticas de cambios
- Estado centralizado en controladores

## Patrones Implementados

### **State Management**: Provider + ChangeNotifier
```dart
// Configuración en main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => NinoController()),
  ],
  child: MaterialApp(...),
)

// Uso en vistas
Consumer<AuthController>(
  builder: (context, authController, child) {
    return authController.isLoading 
      ? CircularProgressIndicator()
      : LoginForm();
  },
)
```

### **Repository Pattern** (en Servicios)
```dart
class UsuarioService {
  static Future<UsuarioModel?> buscarPorUsuario(String usuario) async {
    // Lógica de acceso a datos abstraída
  }
}
```

### **Factory Pattern** (en Modelos)
```dart
factory UsuarioModel.fromMap(Map<String, dynamic> map, String documentId) {
  return UsuarioModel(
    id: documentId,
    usuario: map['usuario'] ?? '',
    // ...
  );
}
```

## Uso de la Aplicación

### 1. **Instalar dependencias**
```bash
flutter pub get
```

### 2. **Ejecutar la aplicación**
```bash
flutter run lib/main_mvc.dart
```

### 3. **Estructura de navegación**
- Inicias en `LoginView`
- Tras autenticación → `HomeView`
- Acceso a formularios según permisos

## Consideraciones Futuras

### **Posibles Mejoras**:
- Implementar Repository Interface para abstracción completa
- Agregar caching local (SharedPreferences/Hive)
- Implementar interceptores para manejo global de errores
- Agregar logging centralizado
- Implementar offline-first con sincronización

### **Testing**:
- Unit tests para controladores y servicios
- Widget tests para vistas
- Integration tests para flujos completos

Esta arquitectura proporciona una base sólida, mantenible y escalable para el desarrollo de la aplicación Flutter con Firebase.