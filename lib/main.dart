import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'puzzle_state.dart';

void main() => runApp(MIUApp());

class MIUApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MIU Puzzle",
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
      home: GamePage(title: "MIU Puzzle"),
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
  final _ruleTextStyle = const TextStyle(fontSize: 24.0);
  final _selectedRuleTextStyle = const TextStyle(
      color: Colors.deepOrange,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic);
  final _instructionTextStyle = const TextStyle(fontSize: 18.0);

  // force landscape mode
  // Note that for the iOS simulator, you'll still have to rotate the device first
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRules(),
            _buildStringView(),
            _buildInstructions(),
          ],
        ),
      ),
    );
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
    return Column(
      children: [
        Text("Your goal: transform MI into MU via the rules:",
            style: const TextStyle(
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
            )),
        Text(
          "Rule I: if I is the last letter, add U.",
          style: _applicableRule == Rule.one ? _selectedRuleTextStyle : _ruleTextStyle,
        ),
        Text(
          "Rule II: M followed by letters, appends letters.",
          style: _applicableRule == Rule.two ? _selectedRuleTextStyle : _ruleTextStyle,
        ),
        Text(
          "Rule III: III may be replaced by U.",
          style: _applicableRule == Rule.three ? _selectedRuleTextStyle : _ruleTextStyle,
        ),
        Text(
          "Rule IV: UU can be dropped.",
          style: _applicableRule == Rule.four ? _selectedRuleTextStyle : _ruleTextStyle,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
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
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: 100,
    );
  }

  Widget _buildInstructions() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Expanded(
            child: Column(
              children: [
                Text("Tap a letter to select it and see which rule can be applied.",
                    style: _instructionTextStyle, textAlign: TextAlign.left),
                Text("The highlighted rule will be applied upon a tap of the selected letter.",
                    style: _instructionTextStyle, textAlign: TextAlign.left),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          _buildResetButton(),
          Padding(padding: EdgeInsets.only(right: 60), child: _buildUndoButton()),
        ]));
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
