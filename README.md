# Mercado Libre Clone - Flutter 🚀

Una réplica interactiva y de alto rendimiento de la aplicación móvil de Mercado Libre, desarrollada en Flutter. Esta versión incluye un flujo de navegación completo, simulación de carrito de compras, y optimizaciones avanzadas de rendimiento y búsqueda.

---

## ✨ Características Principales

1. **Buscador Dinámico e Interactivo**:
   - Barra de búsqueda limpia desde el inicio (sin términos preestablecidos molestos).
   - Botón de limpiar ("X") integrado para vaciar el texto con un solo toque.
   - Sincronización automática de pestañas superiores con el término buscado.
   
2. **Pantalla de Inicio Inteligente**:
   - **Modo Promocional**: Si no hay búsqueda activa, muestra el carrusel de banners del Día del Padre, beneficios de Meli+, accesos rápidos (Ofertas, Afiliados, etc.), ofertas relámpago con contador de tiempo y videos destacados.
   - **Modo Resultados**: Al buscar un término o seleccionar una categoría, oculta las promociones estáticas y muestra una cuadrícula responsiva con los resultados correspondientes obtenidos en tiempo real de la API de Mercado Libre o mocks enriquecidos.
   
3. **Carga Ultra Rápida de Imágenes (Optimización Unsplash)**:
   - Las imágenes de productos provienen de Unsplash y se optimizan dinámicamente agregando parámetros de tamaño y calidad en el backend (`w=350&q=70&fit=crop`).
   - Reduce el consumo de datos de red móvil de ~10MB por imagen a tan solo **15-30KB**, logrando que el feed de productos cargue instantáneamente y evitando caídas o congelamientos de memoria en el celular.

4. **Navegación e Integración Completa**:
   - **Categorías**: Pantalla interactiva que permite ver productos específicos por departamento (Tecnología, Ropa, Herramientas, etc.).
   - **Detalle de Producto**: Información técnica, envío gratuito, devolución, cuotas mensuales sin interés y botones de compra.
   - **Carrito**: Estado global compartido usando Riverpod para añadir productos y reflejar cantidades en la barra de navegación.

---

## 🛠️ Tecnologías Utilizadas

* **Framework**: Flutter & Dart.
* **Manejo de Estado**: [Flutter Riverpod](https://riverpod.dev/) con generación de código (`riverpod_generator`).
* **Navegación**: [GoRouter](https://pub.dev/packages/go_router) para rutas limpias y transiciones fluidas.
* **Peticiones HTTP**: [Dio](https://pub.dev/packages/dio) integrado con la API pública de Mercado Libre (sitio MLM - México).
* **Almacenamiento e Imagen**: [CachedNetworkImage](https://pub.dev/packages/cached_network_image) para persistencia en caché y [Shimmer](https://pub.dev/packages/shimmer) para esqueletos de carga de interfaz (*skeletons*).

---

## ⚙️ Instalación y Ejecución

Sigue estos pasos para correr el proyecto localmente o instalarlo en un emulador/dispositivo conectado:

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/manolokogamerx45-beep/Meli360.git
   cd Meli360
   ```

2. **Obtener las dependencias de Flutter**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar el generador de código** (necesario si realizas modificaciones en los modelos o proveedores annotados):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Correr la aplicación**:
   - **En modo Depuración (Debug)**:
     ```bash
     flutter run
     ```
   - **Instalar en un dispositivo físico específico**:
     ```bash
     flutter install -d <ID_DEL_DISPOSITIVO>
     ```

5. **Compilar la APK de Producción (Release)**:
   ```bash
   flutter build apk --release
   ```
