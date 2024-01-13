import 'package:bandasname/providers/sockets_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Estado del servidor ${socketProvider.serveStatus}')
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          socketProvider.socket.emit(
              'emitir-mensaje', {'nombre': 'julio', 'mensaje': 'Aqui esta'});
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
