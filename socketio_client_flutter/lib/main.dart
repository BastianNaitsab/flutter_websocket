import 'package:flutter/material.dart';
import 'package:socketio_client_flutter/model/message.dart';

import 'services/websocket_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Socket.IO Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  // Instancia del servicio
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    const String wsUrl = 'http://localhost:3000';
    // Conectar al WebSocket
    _webSocketService.connect(wsUrl);
  }

  @override
  Widget build(BuildContext context) {
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

            // Usar el StreamBuilder con los Streams del WebSocketService

            StreamBuilder<String>(
              stream: _webSocketService.messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return Text('Mensaje: ${snapshot.data}',
                      style: const TextStyle(fontSize: 16));
                } else {
                  return const Text('Esperando mensaje...');
                }
              },
            ),

            const SizedBox(height: 24),

            StreamBuilder<String>(
              stream: _webSocketService.messageEveryoneStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  try {
                    // Se debe decodificar el dato para obtener el modelo
                    Message decodedMessage = Message.fromJson(snapshot.data!);
                    return Text(
                        'Mensaje complejo de ${decodedMessage.user}: ${decodedMessage.message}',
                        style: const TextStyle(fontSize: 16));
                  } catch (error) {
                    return Text("Error al procesar el mensaje: $error");
                  }
                } else {
                  return const Text('Esperando mensaje...');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _sendMessageEveryone,
            tooltip: 'Send message everyone',
            child: const Icon(Icons.send_and_archive),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _sendMessage,
            tooltip: 'Send message',
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  // Enviar el mensaje usando el servicio WebSocket
  void _sendMessage() {
    // para enviar datos complejos convertir el dato con .toJson
    if (_controller.text.isNotEmpty) {
      _webSocketService.sendMessage(_controller.text);
    }
  }

  // Enviar mensaje a todos con dato complejo
  void _sendMessageEveryone() {
    if (_controller.text.isNotEmpty) {
      Message message = Message(
        user: "user",
        message: _controller.text,
      );

      // Se debe codificar el modelo para enviar en formato cadena de texto
      String encodedMessage = message.toJson();
      _webSocketService.sendMessageEveryone(encodedMessage);
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect(); // Desconectar WebSocket
    _controller.dispose();
    super.dispose();
  }
}
