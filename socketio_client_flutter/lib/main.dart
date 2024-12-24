import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Socket.IO Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  // Para crear el cliente
  final IO.Socket _socket = IO.io('http://localhost:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  // Crear varios StreamController para eventos diferentes
  final StreamController<String> _mensajeStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    _socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    // Para escuchar se usa _socket.on
    _socket.on('connect', (_) {
      debugPrint('Conectado al servidor');
    });

    _socket.on('disconnect', (_) {
      debugPrint('Desconectado del servidor');
    });

    // Escuchar el evento 'mensaje' y agregar el dato al StreamController correspondiente
    _socket.on('mensaje', (data) {
      debugPrint('Mensaje recibido: $data');
      _mensajeStreamController.sink.add(data);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),

            // StreamBuilder para el evento 'mensaje'
            StreamBuilder<String>(
              stream: _mensajeStreamController.stream,
              builder: (context, snapshot) {
                // Para cuando esta cargando la conexion
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                // Para cuando se tienen los datos
                else if (snapshot.hasData) {
                  return Text('Mensaje: ${snapshot.data}',
                      style: const TextStyle(fontSize: 16));
                } else {
                  return const Text('Esperando mensaje...');
                }
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }

  // Para enviar se usa _socket.emit
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _socket.emit('mensaje', _controller.text);
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    _mensajeStreamController.close(); // Cerrar el StreamController
    _controller.dispose();
    super.dispose();
  }
}
