# 🔍 Diagnóstico Firebase - WasiApp

## ❌ Problema Actual
**La aplicación no muestra datos de la base de datos**
- UI muestra "No hay registros aún"
- No se ven los niños registrados

---

## ✅ Verificaciones Implementadas

### 1. **Logs de Debug Agregados**
Los siguientes logs aparecerán en consola al ejecutar la app:

#### En `main.dart`:
```
🚀 Iniciando aplicación...
✅ Firebase inicializado
📱 Lanzando app...
```

#### En `home_view.dart`:
```
═══════════════════════════════════
🏠 HOME: Verificando usuario...
🏠 HOME: Usuario: [nombre_usuario]
🏠 HOME: ID: [usuario_id]
🏠 HOME: Logged in: true
═══════════════════════════════════
✅ HOME: Usuario válido - cargando datos...
🏠 HOME: Carga completada - X niños
🏠 HOME: Estadísticas cargadas
```

#### En `nino_controller.dart`:
```
🔄 Controller: Iniciando carga para usuario: [usuario_id]
⏳ Controller: Llamando al servicio...
✅ Controller: X niños cargados
📋 Controller: Lista actualizada en memoria
```

#### En `nino_service.dart`:
```
═══════════════════════════════════
🔍 Service: CONSULTANDO FIREBASE
🔍 Usuario ID: [usuario_id]
🔍 Colección: ninos
🔍 Firebase App: [default]
🔍 Project ID: wasiapp-66023
═══════════════════════════════════
📡 Ejecutando query a Firestore...
⏱️ Timestamp inicio: [timestamp]
⏱️ Timestamp fin: [timestamp]
📦 Respuesta recibida: X documentos
📦 Metadata: fromCache=false/true
═══════════════════════════════════
```

---

## 🔎 Pasos de Diagnóstico

### **PASO 1: Ejecutar la App**
```bash
flutter run -d windows
```

Observar los logs en la consola y buscar:

#### ✅ **Si aparece:**
```
✅ Firebase inicializado
✅ HOME: Usuario válido - cargando datos...
📡 Ejecutando query a Firestore...
📦 Respuesta recibida: 0 documentos
```
**→ Firebase funciona pero NO HAY DATOS en la BD**

#### ✅ **Si aparece:**
```
✅ Firebase inicializado
❌ HOME: Sin usuario - redirigiendo a login
```
**→ No hay sesión activa**

#### ❌ **Si aparece:**
```
❌ Error Firebase: [error]
```
**→ Firebase no está configurado correctamente**

#### ❌ **Si aparece:**
```
❌ Controller: Error capturado: [error]
❌ Controller: Tipo de error: [tipo]
```
**→ Problema de permisos o reglas de Firestore**

---

### **PASO 2: Verificar Datos en Firebase Console**

1. Ir a: https://console.firebase.google.com/
2. Seleccionar proyecto: **wasiapp-66023**
3. Ir a **Firestore Database**
4. Verificar colección `ninos`

**Verificar:**
- ✅ ¿Existen documentos?
- ✅ ¿Los documentos tienen el campo `usuarioId`?
- ✅ ¿El `usuarioId` coincide con el ID del usuario logueado?
- ✅ ¿Los documentos tienen `activo: true`?

**Ejemplo de documento correcto:**
```json
{
  "nombres": "Juan",
  "apellidos": "Pérez",
  "dniNino": "12345678",
  "usuarioId": "ABC123",  // ← Debe coincidir con el usuario logueado
  "activo": true,          // ← Debe ser true
  "fechaNacimiento": "2020-01-01",
  "peso": 15.5,
  "talla": 90.0,
  // ... otros campos
}
```

---

### **PASO 3: Verificar Reglas de Firestore**

En Firebase Console → Firestore Database → **Rules**

**Reglas mínimas necesarias:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ninos/{ninoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /usuarios/{usuarioId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ Si las reglas están muy restrictivas**, la consulta fallará silenciosamente.

---

### **PASO 4: Verificar Autenticación**

En Firebase Console → **Authentication**

- ✅ ¿Hay usuarios registrados?
- ✅ ¿El usuario puede iniciar sesión?
- ✅ ¿El UID del usuario coincide con el `usuarioId` en Firestore?

---

## 🛠️ Soluciones Comunes

### **Problema 1: NO HAY DATOS**
```
📦 Respuesta recibida: 0 documentos
```

**Solución:** Registrar un niño desde la app:
1. Tap en botón **"+"**
2. Llenar el formulario
3. Guardar
4. Verificar que aparezca en la lista

---

### **Problema 2: PERMISOS DENEGADOS**
```
❌ [cloud_firestore/permission-denied]
```

**Solución:** Actualizar reglas de Firestore:
```javascript
match /ninos/{ninoId} {
  allow read, write: if request.auth != null;
}
```

---

### **Problema 3: CAMPO usuarioId NO COINCIDE**
```
⚠️ NO HAY DOCUMENTOS para este usuario
```

**Solución:** Verificar en Firebase Console que:
- El campo `usuarioId` en documentos de `ninos` coincida con el UID del usuario
- Actualizar manualmente si es necesario

---

### **Problema 4: FIREBASE NO INICIALIZADO**
```
❌ Error Firebase: [error]
```

**Solución:**
1. Verificar `google-services.json` en `android/app/`
2. Ejecutar: `flutter clean && flutter pub get`
3. Reconstruir: `flutter run`

---

## 📊 Comando de Diagnóstico Rápido

**Verificar estado de Firebase en terminal:**
```bash
flutter run -d windows 2>&1 | grep -E "Firebase|HOME|Controller|Service|📦|✅|❌"
```

---

## 🎯 Próximos Pasos

1. **Ejecutar la app con logs**
2. **Copiar todos los logs de consola aquí**
3. **Verificar Firebase Console (datos + reglas)**
4. **Confirmar si el problema es:**
   - [ ] No hay datos en BD
   - [ ] Permisos de Firestore
   - [ ] Usuario no autenticado
   - [ ] Campo usuarioId no coincide
   - [ ] Firebase no configurado

---

## 📝 Información del Sistema

- **Proyecto Firebase:** wasiapp-66023
- **Colecciones:** usuarios, ninos, estadisticas
- **Flutter:** 3.38.1
- **Dart:** 3.10.0
- **Plataforma de prueba:** Windows
- **Logs habilitados:** ✅

---

**Última actualización:** 21 de noviembre de 2025
