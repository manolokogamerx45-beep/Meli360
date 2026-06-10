import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasource/mercadolibre_api_service.dart';
import '../../data/models/product_model.dart';

part 'home_provider.g.dart';

/// Productos simulados idénticos a los del screenshot del usuario para asegurar
/// que la UI cargue perfectamente incluso sin conexión o ante fallos de la API.
final List<Product> _productosMockDefault = _generar135ProductosMock();

List<Product> _generar135ProductosMock() {
  final list = <Product>[];
  
  // 1. Agregar los 5 productos principales del screenshot
  list.addAll([
    const Product(
      id: "mock-mochila",
      title: "Mochila Escolar Impermeable Con Estampado Cereza",
      price: 164.97,
      originalPrice: 351.0,
      thumbnail: "assets/images/mochila.png",
      shipping: ShippingModel(freeShipping: true),
      category: "moda",
    ),
    const Product(
      id: "mock-muneca",
      title: "Muñeca Bebé Realista De Silicona Con Gorrito Rosa",
      price: 629.87,
      originalPrice: 1244.0,
      thumbnail: "assets/images/bebe.png",
      shipping: ShippingModel(freeShipping: true),
      category: "juguetes",
    ),
    const Product(
      id: "mock-mesa",
      title: "Mesa De Centro Plegable Para Laptop Y Desayuno",
      price: 940.50,
      originalPrice: 1980.0,
      thumbnail: "assets/images/mesa.png",
      shipping: ShippingModel(freeShipping: false),
      category: "hogar",
    ),
    const Product(
      id: "mock-laptop",
      title: "Laptop Huawei Matebook D 14 Intel Core I5 8gb 512gb",
      price: 13599.0,
      originalPrice: 13999.0,
      thumbnail: "assets/images/laptop.png",
      shipping: ShippingModel(freeShipping: true),
      category: "tecnologia",
    ),
    const Product(
      id: "mock-audifonos",
      title: "Audífonos In-ear Inalámbricos F9-5 Tws Bluetooth",
      price: 249.0,
      originalPrice: 499.0,
      thumbnail: "assets/images/audifonos.png",
      shipping: ShippingModel(freeShipping: true),
      category: "tecnologia",
    ),
  ]);

  // Definición de las categorías y sus productos plantilla
  final categoriasInfo = {
    "tecnologia": [
      {"t": "iPhone 14 Pro Max 256gb - Morado Oscuro", "p": 19499.0, "op": 24999.0, "img": "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5"},
      {"t": "Consola PlayStation 5 Slim 1tb Standard Edition", "p": 8999.0, "op": 11499.0, "img": "https://images.unsplash.com/photo-1606813907291-d86efa9b94db"},
      {"t": "Smart TV Samsung 55 Pulgadas QLED 4K Ultra HD", "p": 10499.0, "op": 14999.0, "img": "https://images.unsplash.com/photo-1593305841991-05c297ba4575"},
      {"t": "Nintendo Switch OLED Model Neon Blue/Red", "p": 5499.0, "op": 7999.0, "img": "https://images.unsplash.com/photo-1578301978693-85fa9c0320b9"},
      {"t": "Cámara Mirrorless Canon EOS R50 Con Lente 18-45mm", "p": 14899.0, "op": 18499.0, "img": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32"},
      {"t": "Tablet Xiaomi Pad 6 8gb Ram 256gb Gris", "p": 5999.0, "op": 7499.0, "img": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0"},
      {"t": "Bocina Inteligente Amazon Echo Dot 5a Generación", "p": 799.0, "op": 1299.0, "img": "https://images.unsplash.com/photo-1543512214-318c7553f230"},
      {"t": "Teclado Mecánico Gamer Razer BlackWidow V4 Pro", "p": 2899.0, "op": 3599.0, "img": "https://images.unsplash.com/photo-1587829741301-dc798b83add3"},
      {"t": "Monitor Gamer Curvo LG 34 Pulgadas UltraWide WQHD", "p": 7299.0, "op": 9999.0, "img": "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf"},
      {"t": "Reloj Inteligente Huawei Watch GT 4 Active Edition", "p": 3899.0, "op": 4999.0, "img": "https://images.unsplash.com/photo-1523275335684-37898b6baf30"},
      {"t": "Proyector Portátil Anker Nebula Capsule Max HD", "p": 8499.0, "op": 10999.0, "img": "https://images.unsplash.com/photo-1535016120720-40c646be5580"},
      {"t": "Audífonos Inalámbricos Sony WH-1000XM5 Cancelación de Ruido", "p": 6299.0, "op": 7999.0, "img": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e"},
      {"t": "Tarjeta De Memoria MicroSD SanDisk Extreme 256gb", "p": 549.0, "op": 799.0, "img": "https://images.unsplash.com/photo-1546027658-e535014166ee"},
    ],
    "moda": [
      {"t": "Tenis Running Hombre Adidas Ultraboost Light", "p": 2799.0, "op": 3999.0, "img": "https://images.unsplash.com/photo-1608231387042-66d1773070a5"},
      {"t": "Chamarra De Mezclilla Levi's Trucker Clasica Azul", "p": 1199.0, "op": 1799.0, "img": "https://images.unsplash.com/photo-1576995853123-5a10305d93c0"},
      {"t": "Sudadera Cuello Redondo Champion Powerblend Gris", "p": 649.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1556821840-3a63f95609a7"},
      {"t": "Playera Polo Lacoste De Algodón Pima Clásica", "p": 1699.0, "op": 2299.0, "img": "https://images.unsplash.com/photo-1581655353564-df123a1eb820"},
      {"t": "Lentes De Sol Ray-Ban Classic Aviator Negros", "p": 2499.0, "op": 3299.0, "img": "https://images.unsplash.com/photo-1511499767150-a48a237f0083"},
      {"t": "Jeans Corte Recto 501 Original Levi's Azul Oscuro", "p": 999.0, "op": 1499.0, "img": "https://images.unsplash.com/photo-1542272604-787c3835535d"},
      {"t": "Gorra Ajustable New Era Yankees De Nueva York Negra", "p": 599.0, "op": 799.0, "img": "https://images.unsplash.com/photo-1588850561407-ed78c282e89b"},
      {"t": "Vestido Corto Casual De Verano Con Flores Hermosas", "p": 449.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1595777457583-95e059d581b8"},
      {"t": "Reloj Analógico Casio Classic Vintage Plateado", "p": 799.0, "op": 1099.0, "img": "https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3"},
      {"t": "Bolsa De Mano Para Mujer Michael Kors Satchel Marrón", "p": 3899.0, "op": 5299.0, "img": "https://images.unsplash.com/photo-1584917865442-de89df76afd3"},
      {"t": "Cartera De Piel Genuina Para Caballero Tommy Hilfiger", "p": 499.0, "op": 799.0, "img": "https://images.unsplash.com/photo-1627124424074-7527c2fc9384"},
      {"t": "Tenis De Moda Para Mujer Converse Chuck Taylor All Star", "p": 1199.0, "op": 1499.0, "img": "https://images.unsplash.com/photo-1607522370275-f14206abe5d3"},
      {"t": "Cinturón Casual De Piel De Doble Vista Dockers Cafe/Negro", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1624222247566-7f8240268538"},
      {"t": "Pijama Completa Térmica De Algodón Suave Invierno", "p": 399.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1562157873-818bc0726f68"},
      {"t": "Calcetines Deportivos Tobilleros Puma Paquete Con 6", "p": 249.0, "op": 349.0, "img": "https://images.unsplash.com/photo-1582966772680-860e372bb558"},
    ],
    "hogar": [
      {"t": "Juego De Sábanas Matrimonial Microfibra Ultra Suave", "p": 299.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af"},
      {"t": "Lámpara Escritorio LED Moderna Recargable USB Tactil", "p": 249.0, "op": 399.0, "img": "https://images.unsplash.com/photo-1507473885765-e6ed057f782c"},
      {"t": "Set De 3 Sartenes Antiadherentes T-fal Easy Care Negros", "p": 799.0, "op": 1199.0, "img": "https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7"},
      {"t": "Organizador Alacena Especiero Giratorio De Cocina", "p": 189.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1588854337221-4cf9fa96059c"},
      {"t": "Silla Ejecutiva De Oficina Ergonómica Giratoria Mesh", "p": 1499.0, "op": 1999.0, "img": "https://images.unsplash.com/photo-1580481072645-022f9a6dbf27"},
      {"t": "Sofá Cama Individual Plegable Moderno Gris Oxford", "p": 3299.0, "op": 4499.0, "img": "https://images.unsplash.com/photo-1555041469-a586c61ea9bc"},
      {"t": "Espejo De Pared Cuerpo Completo Con Marco De Madera", "p": 899.0, "op": 1299.0, "img": "https://images.unsplash.com/photo-1618220179428-22790b461013"},
      {"t": "Cortinas Blackout Aislante Térmico Juego De 2 Paneles", "p": 499.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1513694203232-719a280e022f"},
      {"t": "Bote De Basura Inteligente Con Sensor Infrarrojo 12L", "p": 399.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1532996127006-03c43429550e"},
      {"t": "Difusor Aromatizante Ultrasónico De Aceites Esenciales", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1608571423902-eed4a5ad8108"},
      {"t": "Set De 4 Organizadores De Cajones Ropa Interior Clóset", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1595428774223-ef52624120d2"},
      {"t": "Vajilla De Cerámica Para 4 Personas Corona 16 Piezas", "p": 799.0, "op": 1099.0, "img": "https://images.unsplash.com/photo-1610701596007-11502861dcfa"},
      {"t": "Caja Fuerte Digital Electrónica De Acero Reforzado", "p": 899.0, "op": 1299.0, "img": "https://images.unsplash.com/photo-1563986768609-322da13575f3"},
      {"t": "Zapatera Organizador Metálico Para 30 Pares De Zapatos", "p": 399.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a"},
      {"t": "Juego De Toallas De Algodón Baño Paquete De 4 Piezas", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1618220179428-22790b461013"},
    ],
    "deportes": [
      {"t": "Mancuernas Ajustables Hexagonales Par De 10kg C/U", "p": 1299.0, "op": 1799.0, "img": "https://images.unsplash.com/photo-1638536532686-d610adfc8e5c"},
      {"t": "Tapete De Yoga Antideslizante Ecológico TPE 6mm", "p": 299.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1592432678016-e910b452f9a2"},
      {"t": "Bicicleta De Montaña Cuadro De Aluminio R29 21 Velocidades", "p": 4899.0, "op": 6499.0, "img": "https://images.unsplash.com/photo-1485965120184-e220f721d03e"},
      {"t": "Cuerda Para Saltar De Alta Velocidad Baleros Ajustable", "p": 129.0, "op": 199.0, "img": "https://images.unsplash.com/photo-1601224976700-517aab2c0a13"},
      {"t": "Mochila De Hidratación 2L Deporte Ciclismo Senderismo", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62"},
      {"t": "Fajas Deportivas Lumbar De Neopreno Ajustable Gimnasio", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1605296867304-46d5465a25f1"},
      {"t": "Set De 5 Bandas De Resistencia Elásticas De Látex Ejercicio", "p": 159.0, "op": 249.0, "img": "https://images.unsplash.com/photo-1598262138503-6788220bc035"},
      {"t": "Gorra Para Correr Ultraligera Con Protección Solar Filtro", "p": 249.0, "op": 349.0, "img": "https://images.unsplash.com/photo-1588850561407-ed78c282e89b"},
      {"t": "Termo Deportivo De Acero Inoxidable Doble Capa 1L", "p": 299.0, "op": 450.0, "img": "https://images.unsplash.com/photo-1602143407151-7111542de6e8"},
      {"t": "Lentes De Natación Antiempañantes Ajustables Protección UV", "p": 189.0, "op": 279.0, "img": "https://images.unsplash.com/photo-1582126892900-5309e301297f"},
      {"t": "Guantes De Boxeo Profesionales Piel Sintética Everlast 12oz", "p": 699.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed"},
      {"t": "Rueda Abdominal De Ejercicio Doble Con Alfombrilla Rodillas", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b"},
      {"t": "Jersey Oficial De Fútbol Selección Mexicana Copa América", "p": 1499.0, "op": 1899.0, "img": "https://images.unsplash.com/photo-1508098682722-e99c43a406b2"},
      {"t": "Bomba De Aire De Mano Inflador Balones Bicicletas Portátil", "p": 129.0, "op": 199.0, "img": "https://images.unsplash.com/photo-1620288627223-53302f4e8c74"},
      {"t": "Cronómetro Deportivo Digital Precisión Con Silbato Cuerda", "p": 99.0, "op": 149.0, "img": "https://images.unsplash.com/photo-1583500557349-fb52bc577f88"},
    ],
    "juguetes": [
      {"t": "Cochecito Auto De Juguete A Control Remoto Todo Terreno", "p": 399.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1594787318286-3d835c1d207f"},
      {"t": "Bloques De Construcción LEGO Classic Caja Creativa 484 Pzas", "p": 649.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1560961050-13f56d0914c6"},
      {"t": "Juego De Mesa Turista Mundial Edición Especial Clásica", "p": 189.0, "op": 279.0, "img": "https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09"},
      {"t": "Peluche Oso Gigante Con Moño Regalo San Valentín Suave", "p": 499.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1559251606-c623743a6d76"},
      {"t": "Cuna De Viaje Plegable Para Bebé Corral Con Mosquitero", "p": 1899.0, "op": 2499.0, "img": "https://images.unsplash.com/photo-1544816155-12df9643f363"},
      {"t": "Pañalera Mochila Térmica Impermeable Cuna Extensible Cama", "p": 449.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf"},
      {"t": "Set De 3 Mordederas Refrigerables De Agua Libre De BPA", "p": 119.0, "op": 179.0, "img": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1"},
      {"t": "Gimnasio Alberca De Pelotas Tapete De Actividades Bebé", "p": 599.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1515488042361-404e9250afef"},
      {"t": "Pista De Carreras Autos Con Lanzador Plegable Juguete", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1594787318286-3d835c1d207f"},
      {"t": "Cámara De Burbujas Eléctrica Automática Con Luz Música", "p": 159.0, "op": 249.0, "img": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1"},
      {"t": "Triciclo Infantil Con Bastón Dirigible Toldo Carriola", "p": 1299.0, "op": 1799.0, "img": "https://images.unsplash.com/photo-1515488042361-404e9250afef"},
      {"t": "Set De Arte Dibujo Maletín Con Colores Plumones Crayones", "p": 249.0, "op": 399.0, "img": "https://images.unsplash.com/photo-1513364776144-60967b0f800f"},
      {"t": "Carriola Para Bebé Plegable Ligera Reversible Compacta", "p": 1699.0, "op": 2299.0, "img": "https://images.unsplash.com/photo-1591088398332-8a7791972843"},
      {"t": "Andadera Mecedora Para Bebé Con Juguetero Musical Luces", "p": 799.0, "op": 1099.0, "img": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1"},
      {"t": "Juguete De Baño Pulpo Flotante Lanza Aros Set 6 Pzas", "p": 149.0, "op": 229.0, "img": "https://images.unsplash.com/photo-1515488042361-404e9250afef"},
    ],
    "belleza": [
      {"t": "Perfume Mujer 100ml Eau De Parfum Aroma Floral Dulce", "p": 999.0, "op": 1299.0, "img": "https://images.unsplash.com/photo-1541643600914-78b084683601"},
      {"t": "Serum Facial Ácido Hialurónico Puro Hidratante Antiarrugas", "p": 249.0, "op": 399.0, "img": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be"},
      {"t": "Bloqueador Protector Solar Facial FPS 50 Antibrillo Matificante", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908"},
      {"t": "Rímel Máscara De Pestañas Efecto Pestañas Postizas Negra", "p": 119.0, "op": 179.0, "img": "https://images.unsplash.com/photo-1625093742435-6fa192b6fb10"},
      {"t": "Paleta De Sombras De Ojos Ultra Pigmentada 35 Tonos Nude", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1596462502278-27bfdc403348"},
      {"t": "Crema Hidratante Cerave Tarro 454g Piel Seca A Muy Seca", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19"},
      {"t": "Set De 12 Brochas Profesionales De Maquillaje Con Estuche", "p": 149.0, "op": 249.0, "img": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9"},
      {"t": "Secadora De Cabello Profesional Con Difusor Iónica 2000W", "p": 499.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e"},
      {"t": "Plancha Alaciadora De Cabello De Cerámica Placas Anchas", "p": 599.0, "op": 799.0, "img": "https://images.unsplash.com/photo-1560869713-7d0a29430f23"},
      {"t": "Gel Limpiador Espumoso Facial Cuidado Piel Grasa Acné", "p": 249.0, "op": 349.0, "img": "https://images.unsplash.com/photo-1556228720-195a672e8a03"},
      {"t": "Esmalte Uñas Gel Semi permanente Kit De 6 Colores Primavera", "p": 189.0, "op": 279.0, "img": "https://images.unsplash.com/photo-1604654894610-df63bc536371"},
      {"t": "Cortadora De Cabello Patillera Trimmer Barba Inalámbrica Pro", "p": 299.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1621607512214-68297480165e"},
      {"t": "Agua Micelar Limpiadora Desmaquillante Garnier Todo En Uno", "p": 109.0, "op": 159.0, "img": "https://images.unsplash.com/photo-1556228720-195a672e8a03"},
      {"t": "Colágeno Hidrolizado Polvo Premium Sabor Frutos Rojos 500g", "p": 389.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1584017911766-d451b3d0e843"},
      {"t": "Organizador Acrílico Para Maquillaje Y Labiales Cajones", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc"},
    ],
    "herramientas": [
      {"t": "Juego De Herramientas Caja Maletín Con 150 Piezas Llaves", "p": 599.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1504148455328-c376907d081c"},
      {"t": "Esmeriladora Angular Mini Amoladora Eléctrica 800W Pro", "p": 499.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1572981779307-38b8cabb2407"},
      {"t": "Juego De Destornilladores Puntas Imantadas Juego De 12 Pzas", "p": 199.0, "op": 299.0, "img": "https://images.unsplash.com/photo-1534224039826-c7a0dea0e66a"},
      {"t": "Multímetro Digital De Precisión Medición De Voltaje Corriente", "p": 149.0, "op": 249.0, "img": "https://images.unsplash.com/photo-1601584115197-04ecc0da31d7"},
      {"t": "Cinta Métrica Flexómetro Alta Resistencia 5 Metros Gancho", "p": 79.0, "op": 119.0, "img": "https://images.unsplash.com/photo-1586864387967-d02ef85d93e8"},
      {"t": "Pistola De Silicón Caliente Eléctrica 40W Con 10 Silicones", "p": 119.0, "op": 179.0, "img": "https://images.unsplash.com/photo-1513151233558-d860c5398176"},
      {"t": "Soldadora Inverter Portátil Micro Alambre Electrodos MMA", "p": 1599.0, "op": 2299.0, "img": "https://images.unsplash.com/photo-1581092160607-ee22621dd758"},
      {"t": "Nivel De Mano Láser Autonivelante Vertical Horizontal", "p": 349.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1581092335397-9583fe92d232"},
      {"t": "Kit De Cautín Para Soldar Lápiz Eléctrico 60W Con Estaño", "p": 189.0, "op": 279.0, "img": "https://images.unsplash.com/photo-1558137623-ce933996c730"},
      {"t": "Juego De Pinzas Alicate Universal Pinza Punta Corte 3 Pzas", "p": 249.0, "op": 399.0, "img": "https://images.unsplash.com/photo-1586864387967-d02ef85d93e8"},
      {"t": "Lámpara Reflector LED Recargable Exterior Impermeable 50W", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1565814329452-e1efa11c5b89"},
      {"t": "Caladora Sierra Eléctrica De Mano Regulación Velocidad 500W", "p": 699.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1504148455328-c376907d081c"},
      {"t": "Cinta De Aislar Negra De PVC Paquete Con 5 Rollos Seguros", "p": 89.0, "op": 129.0, "img": "https://images.unsplash.com/photo-1601584115197-04ecc0da31d7"},
      {"t": "Serrucho Cortar Madera Tradicional Mango Plástico Ergonómico", "p": 149.0, "op": 229.0, "img": "https://images.unsplash.com/photo-1586864387967-d02ef85d93e8"},
      {"t": "Juego De Llaves Allen Hexagonales Milimétricas 9 Pzas L", "p": 119.0, "op": 189.0, "img": "https://images.unsplash.com/photo-1534224039826-c7a0dea0e66a"},
    ],
    "vehiculos": [
      {"t": "Estéreo Para Auto Bluetooth Pantalla Táctil 7 Pulgadas MP5", "p": 799.0, "op": 1199.0, "img": "https://images.unsplash.com/photo-1616422285623-13ff0162193c"},
      {"t": "Kit De Luces LED H7 H4 Para Faros De Auto Alta Potencia", "p": 349.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1486006920555-c77dce18193b"},
      {"t": "Compresor De Aire Portátil Mini Bomba Eléctrica Auto 12V", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1616422285623-13ff0162193c"},
      {"t": "Cargador Inteligente De Batería Auto Moto 12v Automático", "p": 389.0, "op": 499.0, "img": "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2"},
      {"t": "Aspiradora De Mano Para Auto Potente Conexión Encendedor", "p": 249.0, "op": 399.0, "img": "https://images.unsplash.com/photo-1563720223185-11003d516935"},
      {"t": "Juego De Tapetes Universales De Hule Para Auto 4 Piezas", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1616422285623-13ff0162193c"},
      {"t": "Soporte Celular Magnético Rejilla Aire Auto Universal", "p": 89.0, "op": 149.0, "img": "https://images.unsplash.com/photo-1584438784894-089d6a128f3e"},
      {"t": "Funda Protectora Para Auto Impermeable Antilluvia Sol Sol", "p": 499.0, "op": 699.0, "img": "https://images.unsplash.com/photo-1503376780353-7e6692767b70"},
      {"t": "Kit De Herramientas Gato Hidráulico Botella 2 Toneladas Llave", "p": 649.0, "op": 899.0, "img": "https://images.unsplash.com/photo-1586864387967-d02ef85d93e8"},
      {"t": "Filtro De Aire De Alto Flujo Deportivo Universal Cono", "p": 189.0, "op": 279.0, "img": "https://images.unsplash.com/photo-1616422285623-13ff0162193c"},
      {"t": "Estuche De Herramientas Autocle Matraca Dados 40 Piezas", "p": 299.0, "op": 449.0, "img": "https://images.unsplash.com/photo-1586864387967-d02ef85d93e8"},
      {"t": "Alarma De Seguridad Para Auto Cortacorriente 2 Controles", "p": 399.0, "op": 599.0, "img": "https://images.unsplash.com/photo-1562654501-a0ccc0fc3fb1"},
      {"t": "Aditivo Limpiador Inyectores Motor Gasolina Lucas 155ml", "p": 129.0, "op": 189.0, "img": "https://images.unsplash.com/photo-1619642751034-765dfdf7c58e"},
      {"t": "Kit De Limpieza Lavado Auto Esponja Champú Toalla Microfibra", "p": 249.0, "op": 349.0, "img": "https://images.unsplash.com/photo-1607860108855-64acf2078ed9"},
      {"t": "Espejo Retrovisor Con Cámara DVR Dash Cam Delantera Reversa", "p": 599.0, "op": 799.0, "img": "https://images.unsplash.com/photo-1502877338535-766e1452684a"},
    ],
    "supermercado": [
      {"t": "Leche Entera Premium Alpura Caja Con 12 Litros Clásica", "p": 289.0, "op": 349.0, "img": "https://images.unsplash.com/photo-1550583724-b2692b85b150"},
      {"t": "Aceite Vegetal Nutrioli Botella 946ml De Soya Natural", "p": 42.0, "op": 55.0, "img": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5"},
      {"t": "Galletas Emperador Combinado Caja Paquete Familiar Chocolate", "p": 89.0, "op": 119.0, "img": "https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e"},
      {"t": "Atún En Agua Herdez Lata De 130g Con Lomo De Aleta Amarilla", "p": 19.0, "op": 25.0, "img": "https://images.unsplash.com/photo-1604328698692-f76ea9498e76"},
      {"t": "Arroz Súper Extra Morelos Bolsa 1kg De Grano Entero Blanco", "p": 29.0, "op": 39.0, "img": "https://images.unsplash.com/photo-1586201375761-83865001e31c"},
      {"t": "Frijol Negro Querétaro Selección Especial Bolsa 1kg Sabor", "p": 34.0, "op": 45.0, "img": "https://images.unsplash.com/photo-1586201375761-83865001e31c"},
      {"t": "Detergente Líquido Ariel Doble Poder Botella Para Ropa 2.8L", "p": 129.0, "op": 169.0, "img": "https://images.unsplash.com/photo-1610557892470-76d747e4927f"},
      {"t": "Papel Higiénico Regio Aires De Frescura 32 Rollos Suave", "p": 169.0, "op": 219.0, "img": "https://images.unsplash.com/photo-1584622650111-993a426fbf0a"},
      {"t": "Cereal Zucaritas Kellogg's Caja Grande Familiar 710g Azúcar", "p": 69.0, "op": 89.0, "img": "https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e"},
      {"t": "Pasta Dental Colgate Triple Acción Paquete Con 3 Tubos Flúor", "p": 79.0, "op": 99.0, "img": "https://images.unsplash.com/photo-1559591937-e520b0ca816c"},
      {"t": "Jabón De Barra Corporal Zest Brisa Marina Paquete 4 Barras", "p": 59.0, "op": 75.0, "img": "https://images.unsplash.com/photo-1607006342460-e7e11942bf50"},
      {"t": "Papas Fritas Sabritas Sal Original Bolsa Compartir Botana", "p": 49.0, "op": 59.0, "img": "https://images.unsplash.com/photo-1566478989037-eec744351383"},
      {"t": "Refresco Coca-Cola Sabor Original Botella Familiar 3 Litros", "p": 45.0, "op": 49.0, "img": "https://images.unsplash.com/photo-1622483767028-3f66f32aef97"},
      {"t": "Mayonesa Hellmann's Con Limón Frasco Grande De 390g Clásica", "p": 39.0, "op": 49.0, "img": "https://images.unsplash.com/photo-1588166524941-3bf61a9c41db"},
      {"t": "Café Soluble Premium Descafeinado Frasco 200g", "p": 120.0, "op": 150.0, "img": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd"},
    ]
  };

  // 2. Generar el resto de los 15 productos para cada una de las 9 categorías
  categoriasInfo.forEach((catId, items) {
    final existentesCount = list.where((p) => p.category == catId).length;
    final faltan = 15 - existentesCount;
    
    for (var i = 0; i < faltan; i++) {
      if (i < items.length) {
        final item = items[i];
        list.add(Product(
          id: "mock-$catId-gen-$i",
          title: item["t"] as String,
          price: item["p"] as double,
          originalPrice: item["op"] as double?,
          thumbnail: item["img"] as String,
          shipping: ShippingModel(freeShipping: (i % 2 == 0)),
          category: catId,
        ));
      } else {
        list.add(Product(
          id: "mock-$catId-gen-$i",
          title: "Producto Premium de $catId Novedad #$i",
          price: 199.0 + (i * 75),
          originalPrice: 299.0 + (i * 90),
          thumbnail: "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
          shipping: const ShippingModel(freeShipping: true),
          category: catId,
        ));
      }
    }
  });

  return list;
}

/// Notificador de Riverpod encargado de controlar el estado de la búsqueda en la pantalla de inicio.
@riverpod
class HomeNotifier extends _$HomeNotifier {
  String _ultimaConsulta = '';

  String get ultimaConsulta => _ultimaConsulta;

  @override
  Future<List<Product>> build() async {
    return _ejecutarBusqueda(_ultimaConsulta);
  }

  /// Ejecuta una nueva búsqueda de productos según la consulta del usuario.
  Future<void> buscar(String consulta) async {
    _ultimaConsulta = consulta;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ejecutarBusqueda(consulta));
  }

  /// Reintenta la última consulta realizada.
  Future<void> reintentar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ejecutarBusqueda(_ultimaConsulta));
  }

  /// Realiza la consulta a la API de ML, si falla o está vacía, devuelve los productos Mock
  /// para garantizar que la pantalla siempre luzca llena y funcional.
  Future<List<Product>> _ejecutarBusqueda(String consulta) async {
    try {
      if (consulta.trim().isEmpty) {
        return _productosMockDefault;
      }
      final apiService = ref.read(mercadoLibreApiServiceProvider);
      final resultados = await apiService.searchProducts(consulta);
      
      // Si la API no retorna nada, usamos los mocks enriquecidos.
      if (resultados.isEmpty) {
        return _productosMockDefault;
      }
      
      // Combinamos los resultados de la API con los mocks para asegurar que siempre
      // tengamos los productos del screenshot disponibles en las secciones fijas.
      final listaCompleta = <Product>[...resultados];
      for (final mock in _productosMockDefault) {
        if (!listaCompleta.any((element) => element.id == mock.id)) {
          listaCompleta.add(mock);
        }
      }
      return listaCompleta;
    } catch (e) {
      // Fallback robusto en caso de error de conexión o bloqueo de la API pública.
      return _productosMockDefault;
    }
  }
}
