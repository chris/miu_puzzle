/// Names for the MIU Puzzle rules
enum Rule { none, one, two, three, four }

/// MIU Puzzle state. Includes methods for determining applicable rules, and
/// applying a rule at a given location (mutating the state).
class PuzzleState {
  List<String> _state = ["MI"];

  static const noRule = 0; // no rule applies
  static const rule1 = 1; // last letter is I
  static const rule2 = 2; // "Mx"
  static const rule3 = 3; // "III"
  static const rule4 = 4; // "UU"

  PuzzleState();

  PuzzleState.fromString(String str)
      : assert(str != null && str.isNotEmpty),
        _state = [str];

  PuzzleState.deSerialize(Map<String, dynamic> serializedData)
      : _state = List<String>.from(serializedData["state"]) {}

  @override
  String toString() => current;

  bool isInitialState() => _state == ["MI"];

  get current => _state.last;

  get lastPosition => current.length - 1;

  get letterMap => current.split("").asMap();

  /// Determine what rule (if any) is applicable to the letter at the given position.
  /// Returns [Map] with rule, start, and end keys. rule is the [Rule], start is the first position
  /// of the affected match area, and end the last position. For example, if you had the state of
  /// "MIIIU", and you passed position 2, it would return:
  /// { "rule": Rule.three, "start": 1, "end": 3 }
  /// If no rule matches it returns {"rule": Rule.none, "start": 0, "end": 0}.
  Map applicableRuleAt(int position) {
    final letter = current[position];

    switch (letter) {
      case "I":
        if (position == this.lastPosition) {
          return {"rule": Rule.one, "start": lastPosition, "end": lastPosition};
        } else if (safeSubstring(position - 1, position + 1) == "III") {
          return {"rule": Rule.three, "start": position - 1, "end": position + 1};
        } else if (safeSubstring(position - 2, position) == "III") {
          return {"rule": Rule.three, "start": position - 2, "end": position};
        } else if (safeSubstring(position, position + 2) == "III") {
          return {"rule": Rule.three, "start": position, "end": position + 2};
        } else {
          return {"rule": Rule.none, "start": 0, "end": 0};
        }
        break;
      case "M":
        return position != this.lastPosition
            ? {"rule": Rule.two, "start": position, "end": lastPosition}
            : {"rule": Rule.none, "start": 0, "end": 0};
      case "U":
        if (safeSubstring(position, position + 1) == "UU") {
          return {"rule": Rule.four, "start": position, "end": position + 1};
        } else if (safeSubstring(position - 1, position) == "UU") {
          return {"rule": Rule.four, "start": position - 1, "end": position};
        } else {
          return {"rule": Rule.none, "start": 0, "end": 0};
        }
        break;
      default:
        throw "Unknown letter $letter for MIU puzzle.";
    }
  }

  void applyRuleAt(int position) {
    final ruleInfo = applicableRuleAt(position);

    switch (ruleInfo["rule"]) {
      case Rule.one:
        // Add U to end of string
        _state.add(current + "U");
        break;
      case Rule.two:
        // Append x of Mx
        _state.add(current + current.substring(position + 1));
        break;
      case Rule.three:
        _state.add(current.replaceRange(ruleInfo["start"], ruleInfo["end"] + 1, "U"));
        break;
      case Rule.four:
        _state.add(current.replaceRange(ruleInfo["start"], ruleInfo["end"] + 1, ""));
        break;
      default:
        break;
    }
  }

  bool canUndo() => _state.length > 1;

  undo() {
    assert(canUndo());

    _state.removeLast();
  }

  serialize() {
    return {"state": _state};
  }

  /// Gets a substring of our state string, from start (inclusive), to end (inclusive - note that
  /// this differs from the normal substring method). It will return a smaller string if either the
  /// start or end index is outside the bounds of the string.
  String safeSubstring(int start, int end) {
    if (start < 0) start = 0;
    if (start > lastPosition) return "";
    if (end > lastPosition) end = lastPosition;

    return current.substring(start, end + 1);
  }
}
