import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/cupertino.dart';

enum StatusServidor { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  StatusServidor _servidor = StatusServidor.Connecting;
  late IO.Socket _socket;

  get serveStatus => this._servidor;
  get socket => this._socket;

  SocketService() {
    this._inigConfig();
  }

  void _inigConfig() {
    this._socket = IO.io('http://192.168.1.6:3000', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.on('connect', (_) {
      print('connectado');
      _servidor = StatusServidor.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      print('desconectado');
      _servidor = StatusServidor.Offline;
      notifyListeners();
    });

    /* this._socket.on('nuevo mensaje', (payload) {
      print('nuevo mensaje: $payload');
    }); */
  }
}
