# 📷 **ANÁLISIS VISUAL DE CONJUNTIVA - WasiApp**

## 🎯 **Ubicación y Funcionamiento**

### **📁 Archivos involucrados:**

1. **`lib/views/anemia_diagnostico_view.dart`** (líneas 75-85)
   - Función de captura de imagen: `_pickImage()`
   - Procesamiento y almacenamiento del resultado
   - Instrucciones visuales para el usuario

2. **`lib/utils/anemia_risk.dart`** (líneas 112-175)
   - Algoritmo de análisis mejorado: `imagePalenessFromFile()`
   - Detección específica de color rojo de la conjuntiva
   - Cálculo de saturación e intensidad del rojo

---

## 🔬 **Nuevo Algoritmo de Detección de Color Rojo**

### **🎯 Objetivo:**
Detectar el nivel de color rojo en la conjuntiva ocular (parte interna del párpado) para evaluar posible anemia. Una conjuntiva pálida (poco roja) puede indicar anemia.

### **1. Captura de imagen (`_pickImage`)**
```dart
Future<void> _pickImage() async {
  final x = await _picker.pickImage(
    source: ImageSource.camera, 
    imageQuality: 85, 
    maxWidth: 1024, 
    maxHeight: 1024
  );
  
  final score = AnemiaRiskEngine.imagePalenessFromFile(f);
  setState(() {
    _image = f;
    _imgScore = score;  // 0-1: 0=muy rojo (saludable), 1=muy pálido
  });
}
```

### **2. Algoritmo mejorado de detección de rojo**

#### **🔧 Proceso detallado:**

**PASO 1: Identificar píxeles rojizos (conjuntiva)**
```dart
// Detectar píxeles donde el rojo es dominante
if (r > g && r > b && r > 80) {
  // Este píxel tiene componente rojo significativo
}
```

**PASO 2: Calcular saturación del color**
```dart
final maxVal = max(r, max(g, b));
final minVal = min(r, min(g, b));
final saturation = maxVal > 0 ? (maxVal - minVal) / maxVal : 0.0;

// Filtrar píxeles grises (poca saturación)
if (saturation > 0.15) {
  // Color suficientemente saturado para análisis
}
```

**PASO 3: Analizar intensidad del rojo**
```dart
final redIntensity = r / 255.0;  // Normalizar 0-1
redSum += redIntensity;
saturationSum += saturation;
redPixelCount++;
```

**PASO 4: Calcular score de salud**
```dart
final avgRedIntensity = redSum / redPixelCount;
final avgSaturation = saturationSum / redPixelCount;
final redPixelRatio = redPixelCount / totalSamples;

// Combinar métricas (pesos optimizados)
final healthyRedScore = 
  (avgRedIntensity * 0.5) +    // 50% peso: intensidad del rojo
  (avgSaturation * 0.3) +       // 30% peso: saturación
  (redPixelRatio * 20 * 0.2);   // 20% peso: proporción de píxeles rojos

// Invertir para obtener score de palidez
final palenessScore = 1.0 - healthyRedScore;
```

---

## 📊 **Interpretación de Resultados**

### **🎨 Niveles de palidez:**

| Score | Nivel | Significado | Color UI |
|-------|-------|-------------|----------|
| 0.0 - 0.3 | **Normal** | Buena coloración de conjuntiva | 🟢 Verde |
| 0.3 - 0.6 | **Leve** | Palidez leve, vigilar | 🟡 Amarillo |
| 0.6 - 0.8 | **Moderada** | Palidez moderada, atención | 🟠 Naranja |
| 0.8 - 1.0 | **Severa** | Palidez severa, evaluar urgente | 🔴 Rojo |

### **⚖️ Peso en la evaluación global:**
```dart
// Contribuye hasta 25 puntos de 100 totales
final imgPts = (palenessScore * 25);
score += imgPts;
```

---

## 🖥️ **Interfaz de Usuario Mejorada**

### **📋 Instrucciones para el usuario:**
```
1️⃣ Baje suavemente el párpado inferior
2️⃣ Exponga la conjuntiva (parte interna rosada del ojo)
3️⃣ Tome la foto en un lugar bien iluminado
4️⃣ Mantenga la cámara estable y enfocada
```

### **📊 Visualización del resultado:**
- **Indicador de color:** Verde/Amarillo/Naranja/Rojo
- **Score numérico:** Porcentaje de palidez (0-100%)
- **Nivel descriptivo:** Normal/Leve/Moderada/Severa
- **Vista previa:** Imagen capturada

---

## � **Ventajas del Nuevo Algoritmo**

### **✅ Mejoras respecto al anterior:**

1. **Específico para conjuntiva:**
   - ❌ Antes: Analizaba brillo general
   - ✅ Ahora: Detecta específicamente color rojo

2. **Mayor precisión:**
   - ❌ Antes: Medía solo luminancia
   - ✅ Ahora: Analiza intensidad + saturación + proporción

3. **Filtrado inteligente:**
   - ❌ Antes: Consideraba todos los píxeles
   - ✅ Ahora: Solo píxeles con rojo dominante y saturado

4. **Robusto a iluminación:**
   - ❌ Antes: Muy sensible a luz
   - ✅ Ahora: Normaliza y filtra píxeles grises

---

## ⚠️ **Consideraciones Clínicas**

### **🔬 Validación:**
- ✅ Algoritmo optimizado para detección de rojo
- ✅ Filtrado de falsos positivos (grises, otros colores)
- ⚠️ Requiere validación clínica con profesionales
- ⚠️ No sustituye diagnóstico médico profesional

### **🎯 Factores que afectan la precisión:**
- **Iluminación:** Preferible luz natural o LED blanca
- **Enfoque:** Cámara debe estar enfocada en conjuntiva
- **Ángulo:** Toma frontal o ligeramente lateral
- **Tipo de piel:** Algoritmo normaliza, pero varía
- **Condiciones del ojo:** Irritación puede afectar

### **💡 Casos especiales:**
- **Sin píxeles rojos detectados:** Score = 0.7 (precaución)
- **Imagen borrosa/oscura:** Puede dar resultados inexactos
- **Conjuntivitis:** Puede mostrar más rojo del normal

---

## 🔧 **Configuración Técnica**

### **📸 Parámetros de captura:**
```dart
imageQuality: 85,      // Balance calidad/tamaño
maxWidth: 1024,        // Resolución máxima
maxHeight: 1024,       // Resolución máxima
source: ImageSource.camera  // Solo cámara
```

### **🎛️ Umbrales del algoritmo:**
```dart
minRedValue: 80,           // R > 80 para considerar rojo
minSaturation: 0.15,       // Saturación mínima 15%
sampleStep: ~50000 pixels  // Muestreo optimizado

Pesos del score:
- Intensidad rojo: 50%
- Saturación: 30%
- Proporción píxeles: 20%
```

### **⚡ Rendimiento:**
- **Tiempo de procesamiento:** < 1 segundo
- **Memoria:** Liberación automática
- **Complejidad:** O(n) con muestreo

---

## 📚 **Fundamento Científico**

### **🩺 Base médica:**
La palidez de la conjuntiva es un indicador clínico tradicional de anemia. En pacientes con anemia:
- ↓ Hemoglobina → ↓ Color rojo en tejidos
- Conjuntiva = Tejido muy vascularizado
- Fácil de examinar sin invasión

### **🔬 Implementación técnica:**
```
Color Rojo Alto + Alta Saturación = Saludable
Color Rojo Bajo + Baja Saturación = Posible Anemia
```

**El algoritmo cuantifica esta observación clínica mediante análisis digital de color, proporcionando una evaluación objetiva y reproducible.**