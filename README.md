## 📂 Estructura del proyecto

La aplicación sigue una arquitectura en capas (inspirada en Clean Architecture), organizada de la siguiente manera:
Cada capa tiene una responsabilidad clara:  
lib/
├── presentation/ # Pantallas, UI
│ ├── home.dart
│ ├── registro_nino.dart
│ ├── login.dart
│
├── application/ # Lógica de negocio / controladores
│ ├── registro_controller.dart
│ ├── auth_controller.dart
│
├── domain/ # Entidades / modelos
│ ├── niño.dart
│ ├── usuario.dart
│
├── infrastructure/ # Conexión Firebase, servicios
│ ├── firebase_options.dart
│ ├── firestore_login.dart
│
└── main.dart # Punto de entrada
