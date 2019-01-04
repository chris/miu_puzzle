import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'puzzle_state.dart';
import 'login_signup_page.dart';
import 'auth.dart';
import 'database.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

void main() => runApp(MIUApp());

class MIUApp extends StatelessWidget {
  final lightTheme = ThemeData(primarySwatch: Colors.orange);
  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.orange,
    accentColor: Colors.orangeAccent,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MIU Puzzle",
      theme: darkTheme,
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
  final Auth auth = Auth();

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<GamePage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId;
  PuzzleState _puzzleState = PuzzleState();
  Database _db;
  int _selectedLetter;
  Rule _applicableRule;
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

    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _db = Database(_userId);
          _db.watch(_onDataChange);
        }
        authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
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

  void _onLogin() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _db = Database(_userId);
        _db.watch(_onDataChange);
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });

    Navigator.pop(context);
  }

  void _onSignup() {
    widget.auth.getCurrentUser().then((user) {
      // Setup their initial game record in the DB
      Database(user.uid.toString()).updateGame(_puzzleState);
    });

    _onLogin();
  }

  _showAuth() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return LoginSignupPage(auth: widget.auth, onLogin: _onLogin, onSignup: _onSignup);
    }));
  }

  _logout() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _db.stopWatching();
      _db = null;
      _userId = null;
    });
  }

  _onDataChange(data) {
    print("Got data change with data: ${data.data}");
    setState(() {
      _puzzleState = PuzzleState.deSerialize(data.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
          icon: Icon(Icons.account_circle),
          color: authStatus == AuthStatus.LOGGED_IN ? Colors.black : Colors.grey,
          onPressed: authStatus == AuthStatus.LOGGED_IN ? _logout : _showAuth,
        ),
      ]),
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
              await _areYouSureDialog("Start over?", () {
                _puzzleState = PuzzleState();
                _db?.updateGame(_puzzleState);
              });
            },
    );
  }

  Widget _buildUndoButton() {
    return IconButton(
        icon: Icon(Icons.undo),
        tooltip: 'Undo last move.',
        onPressed: _puzzleState.canUndo()
            ? () {
                setState(() {
                  _puzzleState.undo();
                  _db?.updateGame(_puzzleState);
                });
              }
            : null);
  }

  Widget _buildRules() {
    final _ruleTextStyle = const TextStyle(fontSize: 24.0);
    final _selectedRuleTextStyle = TextStyle(
        color: Theme.of(context).accentColor,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic);

    return Padding(
        padding: EdgeInsets.only(bottom: 15.0),
        child: Column(
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
        ));
  }

  Widget _buildStringView() {
    final _letterStyle = const TextStyle(fontSize: 32.0);

    List<Widget> letters = [];
    _puzzleState.letterMap.forEach((index, letter) {
      letters.add(FlatButton(
        child: Text(letter, style: _letterStyle),
        color: index == _selectedLetter
            ? Theme.of(context).primaryColor
            : Theme.of(context).scaffoldBackgroundColor,
        onPressed: () {
          if (_selectedLetter == index) {
            setState(() {
              _puzzleState.applyRuleAt(index);
              _selectedLetter = null;
              _applicableRule = null;
              _db?.updateGame(_puzzleState);
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
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: 80,
    );
  }

  Widget _buildInstructions() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
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
    var onYesPress = () => Navigator.pop(context, "yes");
    var onNoPress = () => Navigator.pop(context, "no");

    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(content: Text(text), actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Yes"),
                isDestructiveAction: true,
                onPressed: onYesPress,
              ),
              CupertinoDialogAction(
                child: const Text("No"),
                isDefaultAction: true,
                isDestructiveAction: true,
                onPressed: onNoPress,
              ),
            ]);
          } else {
            return SimpleDialog(
              title: Text(text),
              children: <Widget>[
                SimpleDialogOption(
                  child: const Text('Yes'),
                  onPressed: onYesPress,
                ),
                SimpleDialogOption(
                  child: const Text('No'),
                  onPressed: onNoPress,
                ),
              ],
            );
          }
        })) {
      case "yes":
        setState(yesFunc);
        break;
      default:
        break;
    }
  }
}
