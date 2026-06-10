import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image.dart';
import '../providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> items;
  final double total;
  final bool clearCartOnSuccess;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.total,
    required this.clearCartOnSuccess,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0; // 0: Dirección, 1: Pago, 2: Resumen, 3: Éxito
  String _generatedOrderId = '';

  // Formulario Dirección
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'Emmanuel');
  final _telefonoCtrl = TextEditingController(text: '4421234567');
  final _cpCtrl = TextEditingController(text: '76344');
  final _calleCtrl = TextEditingController(text: 'Calle Falsa 123');
  final _coloniaCtrl = TextEditingController(text: 'Colonia El Sol');
  final _estadoCtrl = TextEditingController(text: 'Querétaro');

  // Forma de Pago
  String _metodoPagoSeleccionado = 'tarjeta';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _cpCtrl.dispose();
    _calleCtrl.dispose();
    _coloniaCtrl.dispose();
    _estadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        leading: _currentStep == 3
            ? const SizedBox() // Bloquear botón atrás en pantalla de éxito
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textoPrincipal),
                onPressed: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep--;
                    });
                  } else {
                    context.pop();
                  }
                },
              ),
        title: Text(
          _currentStep == 3 ? '¡Compra Exitosa!' : 'Confirmar Compra',
          style: const TextStyle(
            color: AppColors.textoPrincipal,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: _buildStepContent(formatMoneda),
    );
  }

  Widget _buildStepContent(NumberFormat formatMoneda) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep(formatMoneda);
      case 3:
        return _buildSuccessStep();
      default:
        return _buildAddressStep();
    }
  }

  // PASO 1: Formulario de Dirección
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.azulLink),
                    SizedBox(width: 8),
                    Text(
                      'Dirección de Envío',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textoPrincipal),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de quien recibe', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => value!.isEmpty ? 'Ingresa el nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono celular', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (value) => value!.isEmpty ? 'Ingresa el teléfono' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Código Postal', prefixIcon: Icon(Icons.markunread_mailbox_outlined)),
                        validator: (value) => value!.isEmpty ? 'CP' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _estadoCtrl,
                        decoration: const InputDecoration(labelText: 'Estado', prefixIcon: Icon(Icons.map_outlined)),
                        validator: (value) => value!.isEmpty ? 'Ingresa el Estado' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _calleCtrl,
                  decoration: const InputDecoration(labelText: 'Calle y Número', prefixIcon: Icon(Icons.home_outlined)),
                  validator: (value) => value!.isEmpty ? 'Ingresa la calle' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coloniaCtrl,
                  decoration: const InputDecoration(labelText: 'Colonia', prefixIcon: Icon(Icons.location_city_outlined)),
                  validator: (value) => value!.isEmpty ? 'Ingresa la colonia' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulLink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Continuar a Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PASO 2: Selección de Pago
  Widget _buildPaymentStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payment, color: AppColors.azulLink),
                        SizedBox(width: 8),
                        Text(
                          'Método de Pago',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textoPrincipal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RadioListTile<String>(
                      title: const Text('Tarjeta de Crédito / Débito', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Hasta 12 meses sin intereses', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.credit_card, color: AppColors.azulLink),
                      value: 'tarjeta',
                      groupValue: _metodoPagoSeleccionado,
                      onChanged: (val) {
                        setState(() {
                          _metodoPagoSeleccionado = val!;
                        });
                      },
                    ),
                    const Divider(),
                    RadioListTile<String>(
                      title: const Text('Transferencia Bancaria SPEI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Acreditación inmediata', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.account_balance, color: Colors.blueGrey),
                      value: 'spei',
                      groupValue: _metodoPagoSeleccionado,
                      onChanged: (val) {
                        setState(() {
                          _metodoPagoSeleccionado = val!;
                        });
                      },
                    ),
                    const Divider(),
                    RadioListTile<String>(
                      title: const Text('Efectivo en OXXO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Acreditación en 1 hora', style: TextStyle(fontSize: 12)),
                      secondary: const Icon(Icons.store, color: Colors.deepOrange),
                      value: 'oxxo',
                      groupValue: _metodoPagoSeleccionado,
                      onChanged: (val) {
                        setState(() {
                          _metodoPagoSeleccionado = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulLink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Revisar Pedido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PASO 3: Resumen y Confirmación
  Widget _buildReviewStep(NumberFormat formatMoneda) {
    String txtPago = 'Tarjeta de Crédito';
    if (_metodoPagoSeleccionado == 'spei') txtPago = 'SPEI Transferencia';
    if (_metodoPagoSeleccionado == 'oxxo') txtPago = 'OXXO Efectivo';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Resumen Envío
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Envío a:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
                          TextButton(
                            onPressed: () => setState(() => _currentStep = 0),
                            child: const Text('Editar', style: TextStyle(fontSize: 12, color: AppColors.azulLink)),
                          ),
                        ],
                      ),
                      Text('${_nombreCtrl.text} - ${_telefonoCtrl.text}', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${_calleCtrl.text}, ${_coloniaCtrl.text}, CP ${_cpCtrl.text}, ${_estadoCtrl.text}', style: const TextStyle(fontSize: 13, color: AppColors.textoSecundario)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Resumen Pago
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.payment_outlined, color: AppColors.azulLink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Forma de pago:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textoPrincipal)),
                            Text(txtPago, style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _currentStep = 1),
                        child: const Text('Cambiar', style: TextStyle(fontSize: 12, color: AppColors.azulLink)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Resumen Productos
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final prod = item.product;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                ProductImage(imageUrl: prod.secureThumbnail, height: 40, width: 40),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prod.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'x${item.quantity}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  formatMoneda.format(prod.price * item.quantity),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Panel inferior de Compra
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Envío', style: TextStyle(fontSize: 13, color: AppColors.verdeExito, fontWeight: FontWeight.bold)),
                    const Text('Gratis', style: TextStyle(fontSize: 13, color: AppColors.verdeExito, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(formatMoneda.format(widget.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Crear la orden de compra simulada
                      final orderId = ref.read(ordersNotifierProvider.notifier).crearPedido(widget.items, widget.total);
                      
                      // Vaciar el carrito si corresponde
                      if (widget.clearCartOnSuccess) {
                        ref.read(cartNotifierProvider.notifier).limpiarCarrito();
                      }

                      setState(() {
                        _generatedOrderId = orderId;
                        _currentStep = 3;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulLink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirmar Compra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // PASO 4: Éxito
  Widget _buildSuccessStep() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.verdeExito,
            size: 96,
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Gracias por tu compra, Emmanuel!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código de pedido: $_generatedOrderId',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textoSecundario,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: AppColors.verdeExito, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu paquete está siendo preparado y llegará mañana gratis por envío FULL.',
                    style: TextStyle(
                      color: AppColors.verdeExito,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Navegar a Mis Compras
                context.pop(); // Cerrar Checkout
                context.push('/mis-compras');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulLink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Seguir mi Pedido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                context.pop(); // Regresar al inicio
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.azulLink,
                side: const BorderSide(color: AppColors.azulLink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Volver a la Tienda', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
