const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Base de datos de pedidos en memoria
let orders = [];

// Utilidad para transmitir mensajes a todos los clientes WebSocket conectados
function broadcast(type, data) {
  const message = JSON.stringify({ type, data });
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// --- Rutas HTTP REST ---

// Obtener todas las órdenes
app.get('/api/orders', (req, res) => {
  res.json(orders);
});

// Crear una nueva orden (desde la app de cliente)
app.post('/api/orders', (req, res) => {
  const { id, items, total, fecha, status } = req.body;
  
  if (!items || !total) {
    return res.status(400).json({ error: 'Faltan datos requeridos (items, total)' });
  }

  const orderId = id || `PED-${Date.now().toString().substring(7)}`;
  const nuevaOrden = {
    id: orderId,
    items,
    total: parseFloat(total),
    fecha: fecha || new Date().toLocaleDateString('es-MX'),
    status: status || 'Preparando envío',
    repartidor: null
  };

  orders.unshift(nuevaOrden); // Agregar al inicio de la lista
  console.log(`[HTTP] Pedido creado: ${orderId}. Total: $${total}`);

  // Emitir a todos por WebSocket
  broadcast('new_order', nuevaOrden);

  res.status(201).json(nuevaOrden);
});

// Modificar el estado o el repartidor de una orden (desde cliente o repartidor)
app.patch('/api/orders/:id', (req, res) => {
  const { id } = req.params;
  const { status, repartidor } = req.body;

  const ordenIndex = orders.findIndex(o => o.id === id);
  if (ordenIndex === -1) {
    return res.status(404).json({ error: 'Pedido no encontrado' });
  }

  if (status !== undefined) {
    orders[ordenIndex].status = status;
  }
  if (repartidor !== undefined) {
    orders[ordenIndex].repartidor = repartidor;
  }

  const ordenActualizada = orders[ordenIndex];
  console.log(`[HTTP] Pedido actualizado: ${id}. Estado: ${status}, Repartidor: ${repartidor}`);

  // Emitir actualización a todos los conectados
  broadcast('order_updated', ordenActualizada);

  res.json(ordenActualizada);
});

// --- Lógica del Servidor WebSocket ---
wss.on('connection', (ws) => {
  console.log('[WS] Cliente conectado');

  // Enviar estado inicial de las órdenes al conectarse
  ws.send(JSON.stringify({ type: 'init', data: orders }));

  ws.on('message', (message) => {
    try {
      const payload = JSON.parse(message);
      console.log(`[WS] Mensaje recibido de tipo "${payload.type}"`);

      // Manejar mensajes entrantes por WebSocket si es necesario
      if (payload.type === 'update_status') {
        const { id, status, repartidor } = payload.data;
        const ordenIndex = orders.findIndex(o => o.id === id);
        if (ordenIndex !== -1) {
          if (status !== undefined) orders[ordenIndex].status = status;
          if (repartidor !== undefined) orders[ordenIndex].repartidor = repartidor;
          
          broadcast('order_updated', orders[ordenIndex]);
          console.log(`[WS] Pedido actualizado vía WS: ${id} a ${status}`);
        }
      }
    } catch (e) {
      console.error('[WS] Error al procesar mensaje:', e.message);
    }
  });

  ws.on('close', () => {
    console.log('[WS] Cliente desconectado');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n==================================================`);
  console.log(`🚀 Servidor Meli360 corriendo en: http://localhost:${PORT}`);
  console.log(`📡 WebSocket listo en el mismo puerto`);
  console.log(`==================================================\n`);
});
