# Mercado Libre Clone & Repartidor - Multi-App Flutter + Firebase 🚀

Este repositorio contiene un ecosistema interactivo de dos aplicaciones de Flutter que simulan el flujo de compra, despacho y entrega de **Mercado Libre**, utilizando **Firebase Firestore** para la sincronización en tiempo real.

---

## 📱 Componentes del Proyecto

El proyecto está dividido en dos aplicaciones principales y un servicio de backend:

1. **Mercado Libre Clone (Cliente)** (Ubicado en la raíz `/`):
   - Réplica de la app de usuario de Mercado Libre.
   - Búsqueda dinámica conectada a la API de Mercado Libre (sitio MLM - México) o mocks locales optimizados.
   - Simulación de carrito de compras global (Riverpod) y flujo de pedidos.
   - Creación de pedidos directamente en **Cloud Firestore**.

2. **Repartidor App (Reparto)** (Ubicado en `/repartidor_app`):
   - Aplicación para los repartidores encargados de la entrega.
   - Escucha en tiempo real (mediante Streams de Firestore) de pedidos disponibles.
   - Flujo para tomar pedidos, cambiar su estado (En camino, Entregado) y actualizar el estado de la entrega.
   - Login simulado de repartidor.

3. **Backend / Servidor Auxiliar** (Ubicado en `/backend`):
   - Servidor Node.js utilizado para optimización de recursos, imágenes y servicios adicionales.

---

## ✨ Características Principales

### 1. Sincronización en Tiempo Real con Firebase Firestore 🔥
- Al finalizar un pedido en la app del cliente, los datos se guardan instantáneamente en Firestore.
- La **App de Repartidores** recibe una actualización automática en segundos en la sección de *"Disponibles"*.
- Las actualizaciones de estado hechas por el repartidor se sincronizan inmediatamente en la base de datos global.

### 2. Buscador Dinámico e Interactivo (App Cliente)
- Barra de búsqueda limpia con botón de limpiar rápido.
- Sincronización automática de las pestañas superiores con el término buscado.
- Modo Promocional completo (carruseles, banners de Meli+, ofertas relámpago con cuenta regresiva) y Modo de Resultados dinámico.

### 3. Carga Ultra Rápida de Imágenes (Optimización Unsplash)
- Las imágenes de productos provienen de Unsplash y se optimizan dinámicamente agregando parámetros de tamaño y calidad en el backend (`w=350&q=70&fit=crop`).
- Reduce el consumo de datos móviles de ~10MB por imagen a tan solo **15-30KB**, logrando cargas instantáneas y evitando problemas de memoria en el celular.

### 4. Navegación y Estado Limpio
- **Manejo de Estado**: Riverpod con generación de código (`riverpod_generator`) en ambas apps para un estado consistente y reactivo.
- **Navegación**: GoRouter para rutas limpias y estructuradas.

---

## 🛠️ Tecnologías Utilizadas

* **Framework**: Flutter (Dart)
* **Base de Datos**: Google Cloud Firestore (Firebase)
* **Manejo de Estado**: [Flutter Riverpod](https://riverpod.dev/) con `riverpod_generator`.
* **Navegación**: [GoRouter](https://pub.dev/packages/go_router).
* **Peticiones HTTP**: [Dio](https://pub.dev/packages/dio) integrado con la API pública de Mercado Libre.
* **Imágenes**: [CachedNetworkImage](https://pub.dev/packages/cached_network_image) y [Shimmer](https://pub.dev/packages/shimmer) para esqueletos de carga.

---

## ⚙️ Instalación y Ejecución

### 🔑 Requisitos Previos: Firebase
Ambas apps están configuradas para usar Firebase. Asegúrate de tener los archivos de configuración correspondientes en las siguientes rutas (ya pre-configurados para el proyecto `meli360`):
- `android/app/google-services.json` (App Cliente)
- `repartidor_app/android/app/google-services.json` (App Repartidor)

---

### 1️⃣ Ejecutar la App del Cliente (Mercado Libre Clone)

Navega a la carpeta raíz del proyecto:

1. **Obtener las dependencias**:
   ```bash
   flutter pub get
   ```

2. **Ejecutar el generador de código** (build_runner):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Ejecutar la app**:
   - En modo Depuración (Debug):
     ```bash
     flutter run
     ```
   - Instalar en un dispositivo físico específico:
     ```bash
     flutter install -d <ID_DEL_DISPOSITIVO>
     ```

4. **Compilar APK**:
   ```bash
   flutter build apk --release
   ```

---

### 2️⃣ Ejecutar la App de Repartidores (Repartidor App)

Navega a la carpeta del repartidor:
```bash
cd repartidor_app
```

1. **Obtener las dependencias**:
   ```bash
   flutter pub get
   ```

2. **Ejecutar la app**:
   - En modo Depuración (Debug):
     ```bash
     flutter run
     ```
   - Instalar en un dispositivo físico específico:
     ```bash
     flutter install -d <ID_DEL_DISPOSITIVO>
     ```

3. **Compilar APK**:
   ```bash
   flutter build apk --release
   ```

---

> [!NOTE]
> Para probar el flujo en tiempo real, se recomienda ejecutar la **App de Cliente** en un dispositivo (ej. tu Xiaomi) y la **App de Repartidor** en otro (ej. tu tablet Galaxy Tab S9 Ultra), ambas conectadas a Internet para sincronizar mediante Firestore.
