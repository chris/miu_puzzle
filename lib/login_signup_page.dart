import 'package:flutter/material.dart';
import 'auth.dart';

class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.onSignedIn});

  final Auth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginSignupPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print("Signed in: $userId");
        } else {
          userId = await widget.auth.signUp(_email, _password);
          print("Signed up user: $userId");
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          widget.onSignedIn();
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          _errorMessage = _isIos ? e.details : e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignup() {
    _formKey.currentState.reset();
    _errorMessage = "";

    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";

    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
        appBar: AppBar(
          title: Text("MIU Puzzle Login"),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(height: 0.0, width: 0.0);
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showNameInput(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return Text(
        _errorMessage,
        style:
            TextStyle(fontSize: 13.0, color: Colors.red, height: 1.0, fontWeight: FontWeight.w300),
      );
    } else {
      return Container(height: 0.0);
    }
  }

  Widget _showLogo() {
    return Hero(
      tag: "hero",
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset("assets/geb.jpg"),
        ),
      ),
    );
  }

  Widget _showNameInput() {
    if (_formMode == FormMode.LOGIN) {
      return Container(padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0), height: 85.0);
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
              hintText: "Name",
              icon: Icon(
                Icons.person,
                color: Colors.grey,
              )),
          validator: (value) => value.isEmpty ? "Name can't be empty" : null,
          onSaved: (value) => _name = value,
        ),
      );
    }
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Email",
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? "Email can't be empty" : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Password",
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? "Password can't be empty" : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSecondaryButton() {
    const buttonTextStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300);
    return FlatButton(
      child: _formMode == FormMode.LOGIN
          ? Text("Create an account", style: buttonTextStyle)
          : Text("Have an account? Sign in", style: buttonTextStyle),
      onPressed: _formMode == FormMode.LOGIN ? _changeFormToSignup : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    const buttonTextStyle = TextStyle(fontSize: 20.0, color: Colors.white);
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.LOGIN
                ? Text("Login", style: buttonTextStyle)
                : Text("Create account", style: buttonTextStyle),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
