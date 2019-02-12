import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: MyHomePage(title: "Flutter Demo Home Nullie's"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Participant {
  String name;
  int score;
  Participant(this.name, this.score);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Participant> _participants;
  int _round = 1;

  _MyHomePageState() {
    _participants = ['Егор', 'Богдан', 'Даша', 'Оля', 'Копетан', 'Флэш', 'Шлапак', 'Илья 2007'].map((name) => Participant(name, 0)).toList();
  }

  Widget longTapButton(Participant participant, int value) => GestureDetector(
    onLongPress: () => setState(() {
      Feedback.forLongPress(context);
      participant.score -= value;
    }),
    child: RaisedButton(
      onPressed: () { setState(() { participant.score += value; }); },
      child: Text(value.toString())
    )
  );

  List<Widget> buildParticipantColumn(Participant participant, List<int> values) {
    var buttons = values.map(
      (value) => Padding(
        padding: EdgeInsets.all(3),
        child: longTapButton(participant, value * _round)
      )
    ).toList();

    var items = <Widget>[
      Center(
        child: FlatButton(
          onPressed: () => _editName(participant),
          child: Text(
            participant.name,
            style: TextStyle(fontWeight: FontWeight.bold))
          )
        ),
        Center(
          child: Text(participant.score.toString(),
          style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ] + buttons;

    return items.map((item) => Expanded(child: item)).toList();
  }

  Future<void> _pushSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          return  Scaffold(
            appBar: AppBar(
              title: const Text('Настройки')
            ),
            body: TextField(keyboardType: TextInputType.number),
          );
        }
      )
    );
    // TODO: find a way to restore previous orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  Future<void> _editName(participant) async {
    var textController = TextEditingController(text: participant.name);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Редактирование имени'),
          content: TextField(
            autofocus: true,
            controller: textController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ОТМЕНИТЬ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('СОХРАНИТЬ'),
              onPressed: () {
                setState(() {
                  participant.name = textController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reset() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сброс'),
          content: Text('Сбросить счёт?'),
          actions: <Widget>[
            FlatButton(
              child: Text('ОТМЕНИТЬ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('СБРОСИТЬ'),
              onPressed: () {
                setState(() {
                  _participants.forEach((participant) {
                    participant.score = 0;
                  });
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    const values = [100, 200, 300, 400, 500];

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        child: ListView(
          children: [1, 2, 3].map(
            (round) => ListTile(
              enabled: true,
              selected: round == _round,
              title: Text('Раунд $round'),
              onTap: () {
                setState(() {
                  _round = round;
                });
                Navigator.pop(context);
              },
            )
          ).toList(),
      )
      ),
      appBar: AppBar(
        title: Text(
          'Учёт — Раунд $_round',
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _reset),
          IconButton(icon: const Icon(Icons.settings), onPressed: _pushSettings),
        ],
      ),
      body: Row(
        children: _participants.map((participant) => Expanded(
          child: Column(
            children: buildParticipantColumn(participant, values).toList()
          )
        )
        ).toList()
      )
    );
  }
}
