import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Aca todo se recibe y se manda en formato String, en la UI es donde se hacen las transformaciones

// O tambien podria aqui transformar los datos, ya yo vere

class WebSocketService {
  // Socket.io client
  IO.Socket? _socket;

  // Streams para los diferentes eventos

  final StreamController<String> _messageStreamController =
      StreamController<String>();

  final StreamController<String> _messageEveryoneStreamController =
      StreamController<String>();

  // Obtener el Stream de mensajes para UI

  Stream<String> get messageStream => _messageStreamController.stream;

  Stream<String> get messageEveryoneStream =>
      _messageEveryoneStreamController.stream;

  // Conectar al WebSocket y configurar los eventos de escucha
  void connect(String url) {
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Eventos de escucha

    _socket?.on('connect', (_) {
      debugPrint('Conectado al servidor');
    });

    _socket?.on('disconnect', (_) {
      debugPrint('Desconectado del servidor');
    });

    _socket?.on('message', (data) {
      debugPrint('Mensaje recibido: $data');
      _messageStreamController.sink.add(data);
    });

    _socket?.on('messageEveryone', (data) {
      debugPrint('Mensaje Todos recibido: $data');
      _messageEveryoneStreamController.sink.add(data);
    });

    _socket?.connect();
  }

  // Eventos de mandar mensajes

  void sendMessage(String message) {
    _socket?.emit('message', message);
  }

  void sendMessageEveryone(String message) {
    _socket?.emit('messageEveryone', message);
  }

  // Cerrar conexión y Streams

  void disconnect() {
    _socket?.disconnect();
    _messageStreamController.close();
  }
}
