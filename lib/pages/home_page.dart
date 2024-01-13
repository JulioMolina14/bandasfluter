import 'dart:io';

import 'package:bandasname/models/band.dart';
import 'package:bandasname/providers/sockets_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    /* Band(id: '1', name: 'Link Park', votes: 5),
    Band(id: '2', name: 'MegaDeath', votes: 8),
    Band(id: '3', name: 'System of dowm', votes: 2),
    Band(id: '4', name: 'Evanense', votes: 7), */
  ];

  @override
  void initState() {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    socketProvider.socket.on('bandasactivas', (payload) {
      bands = (payload as List).map((band) => Band.fromJson(band)).toList();
      print(payload);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketProvider = Provider.of<SocketService>(context);
    socketProvider.socket.off('bandasactivas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketProvider.serveStatus == StatusServidor.Online)
                ? Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
        title: Center(
          child: Text(
            'BanNames',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _graficaBands(),
          Expanded(
              child: ListView.builder(
                  itemCount: bands.length,
                  itemBuilder: (context, i) => bandslist(bands[i]))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 1,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.blueAccent,
          onPressed: addNewBand),
    );
  }

  Widget bandslist(Band band) {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketProvider.socket.emit('eliminate-banda', {'id': band.id});
        //aqui el emit hpta
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete bands',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue[100]),
        title: Text(band.name),
        onTap: () {
          socketProvider.socket.emit('votando-bandas', {'id': band.id});
        },
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  addNewBand() {
    final textControler = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New Band name:'),
              content: TextField(
                controller: textControler,
              ),
              actions: [
                MaterialButton(
                    child: Text('Add'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandtoList(textControler.text))
              ],
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New band name'),
              content: CupertinoTextField(
                controller: textControler,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandtoList(textControler.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          });
    }
  }

  void addBandtoList(String name) {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    socketProvider.socket.emit('añandiendo-banda', {'name': name});

    Navigator.pop(context);
  }

  Widget _graficaBands() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
      width: double.infinity,
      child: PieChart(dataMap: dataMap),
      height: 200.0,
    );
  }
}
