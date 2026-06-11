const WebSocket = require('./backend/node_modules/ws');
const ws = new WebSocket('ws://localhost:3000');

ws.on('open', () => {
  console.log('Successfully connected to WebSocket server!');
  ws.close();
});

ws.on('error', (err) => {
  console.error('WebSocket connection error:', err);
});
