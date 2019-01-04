import 'package:cloud_firestore/cloud_firestore.dart';
import 'puzzle_state.dart';

class Database {
  static final _collection = Firestore.instance.collection("games");

  final String _uid;
  var _subscription;

  Database(this._uid);

  updateGame(PuzzleState state) async {
    await _collection.document(_uid).setData(state.serialize());
  }

  watch(onDataHandler) {
    _subscription = _collection.document(_uid).snapshots().listen(onDataHandler);
  }

  stopWatching() {
    _subscription?.cancel();
  }
}
