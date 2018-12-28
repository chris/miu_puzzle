import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'puzzle_state.dart';

void main() => runApp(MIUApp());

class MIUApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIU Puzzle',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: GamePage(title: 'MIU Puzzle'),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<GamePage> {
  PuzzleState _puzzleState = PuzzleState();
  PuzzleState _priorState;
  int _selectedLetter;
  Rule _applicableRule;
  final _letterStyle = const TextStyle(fontSize: 32.0);
  final _rulesTextStyle = const TextStyle(fontSize: 24.0);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTopRow(),
            _buildStringView(),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(children: [
      _buildResetButton(),
      _buildUndoButton(),
      Expanded(child: _buildRules()),
    ]);
  }

  Widget _buildResetButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      tooltip: 'Restart the puzzle.',
      onPressed: _puzzleState.isInitialState()
          ? null
          : () async {
              await _areYouSureDialog("Start over?", () => _puzzleState = PuzzleState());
            },
    );
  }

  Widget _buildUndoButton() {
    return IconButton(
      icon: Icon(Icons.undo),
      tooltip: 'Undo last move.',
      onPressed: _priorState == null
          ? null
          : () {
              setState(() {
                _puzzleState = _priorState;
                _priorState = null;
              });
            },
    );
  }

  Widget _buildRules() {
    var ruleName;
    switch (_applicableRule) {
      case Rule.one:
        ruleName = "Rule I";
        break;
      case Rule.two:
        ruleName = "Rule II";
        break;
      case Rule.three:
        ruleName = "Rule III";
        break;
      case Rule.four:
        ruleName = "Rule IV";
        break;
      default:
        ruleName = "No rule";
        break;
    }
    return Text("$ruleName will be applied.", style: _rulesTextStyle, textAlign: TextAlign.center);
  }

  Widget _buildStringView() {
    List<Widget> letters = [];
    _puzzleState.letterMap.forEach((index, letter) {
      letters.add(FlatButton(
        child: Text(letter, style: _letterStyle),
        color: index == _selectedLetter ? Colors.orange : Colors.white,
        onPressed: () {
          if (_selectedLetter == index) {
            setState(() {
              _priorState = _puzzleState.clone();
              _puzzleState.applyRuleAt(index);
              _selectedLetter = null;
              _applicableRule = null;
            });
          } else {
            final ruleInfo = _puzzleState.applicableRuleAt(index);
            if (ruleInfo["rule"] == Rule.none) {
              setState(() {
                _selectedLetter = null;
                _applicableRule = null;
              });
            } else {
              setState(() {
                _selectedLetter = index;
                _applicableRule = ruleInfo["rule"];
              });
            }
          }
        },
      ));
    });

    return Container(
      child: ListView(scrollDirection: Axis.horizontal, children: letters),
      height: 100,
    );
  }

  Widget _buildInstructions() {
    return Text(
      "Tap a letter to select it and see which rule can be applied.",
    );
  }

  Future<void> _areYouSureDialog(String text, Function yesFunc) async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(text),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "yes");
                },
                child: const Text('Yes'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "no");
                },
                child: const Text('No'),
              ),
            ],
          );
        })) {
      case "yes":
        setState(yesFunc);
        break;
      default:
        break;
    }
  }
}
