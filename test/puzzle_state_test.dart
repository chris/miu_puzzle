import "package:test/test.dart";
import 'package:miu_puzzle/puzzle_state.dart';

void main() {
  test("fromString constructor sets the state to the supplied string", () {
    expect(PuzzleState.fromString("MIUI").toString(), equals("MIUI"));
  });

  test("letterMap getter converts state to a map of index to letters", () {
    expect(PuzzleState().letterMap, equals({0: "M", 1: "I"}));
  });

  test("applicableRuleAt returns rule and affected positions", () {
    // last letter is I
    expect(PuzzleState().applicableRuleAt(1), equals({"rule": Rule.one, "start": 1, "end": 1}));

    final state = PuzzleState.fromString("MIUIMIIIUMUUIM");

    expect(state.applicableRuleAt(13), equals({"rule": Rule.none, "start": 0, "end": 0}));

    // III positions
    expect(state.applicableRuleAt(5), equals({"rule": Rule.three, "start": 5, "end": 7}));
    expect(state.applicableRuleAt(6), equals({"rule": Rule.three, "start": 5, "end": 7}));
    expect(state.applicableRuleAt(7), equals({"rule": Rule.three, "start": 5, "end": 7}));

    // an I, but not at end or III
    expect(state.applicableRuleAt(1), equals({"rule": Rule.none, "start": 0, "end": 0}));

    // Mx's
    expect(state.applicableRuleAt(0), equals({"rule": Rule.two, "start": 0, "end": 13}));
    expect(state.applicableRuleAt(4), equals({"rule": Rule.two, "start": 4, "end": 13}));
    expect(state.applicableRuleAt(9), equals({"rule": Rule.two, "start": 9, "end": 13}));

    // UU's
    expect(state.applicableRuleAt(10), equals({"rule": Rule.four, "start": 10, "end": 11}));
    expect(state.applicableRuleAt(11), equals({"rule": Rule.four, "start": 10, "end": 11}));
    // U, but not UU
    expect(state.applicableRuleAt(2), equals({"rule": Rule.none, "start": 0, "end": 0}));
  });

  test("apply rule at a position with no rule, does nothing", () {
    const originalState = "MIUIMIIIUMUUIM";
    final state = PuzzleState.fromString(originalState);

    state.applyRuleAt(13);
    expect(state.toString(), equals(originalState));

    state.applyRuleAt(1);
    expect(state.toString(), equals(originalState));

    state.applyRuleAt(2);
    expect(state.toString(), equals(originalState));
  });

  test("apply rule one", () {
    var state = PuzzleState();

    state.applyRuleAt(1);
    expect(state.toString(), equals("MIU"));
  });

  test("rule 1 supersedes rule 3", () {
    var state = PuzzleState.fromString("MIII");
    state.applyRuleAt(3);
    expect(state.toString(), equals("MIIIU"));

    state = PuzzleState.fromString("MIUI");
    state.applyRuleAt(3);
    expect(state.toString(), equals("MIUIU"));
  });

  test("apply rule two", () {
    var state = PuzzleState();

    state.applyRuleAt(0);
    expect(state.toString(), equals("MII"));
    state.applyRuleAt(0);
    expect(state.toString(), equals("MIIII"));

    state = PuzzleState.fromString("MIUIMIIIUMUUIM");
    state.applyRuleAt(13); // no change
    expect(state.toString(), equals("MIUIMIIIUMUUIM"));
    state.applyRuleAt(4);
    expect(state.toString(), equals("MIUIMIIIUMUUIMIIIUMUUIM"));
  });

  test("apply rule three", () {
    var state = PuzzleState.fromString("MIII");
    state.applyRuleAt(2);
    expect(state.toString(), equals("MU"));

    state = PuzzleState.fromString("MIUIMIIIUMUUIM");
    state.applyRuleAt(7);
    expect(state.toString(), equals("MIUIMUUMUUIM"));
  });

  test("apply rule four", () {
    var state = PuzzleState.fromString("MIUIMIIIUMUUIM");
    state.applyRuleAt(10);
    expect(state.toString(), equals("MIUIMIIIUMIM"));

    state = PuzzleState.fromString("MIUIMIIIUMUUIM");
    state.applyRuleAt(11);
    expect(state.toString(), equals("MIUIMIIIUMIM"));

    state = PuzzleState.fromString("MIUUUM");
    state.applyRuleAt(2);
    expect(state.toString(), equals("MIUM"));

    state = PuzzleState.fromString("MIUUUM");
    state.applyRuleAt(3);
    expect(state.toString(), equals("MIUM"));

    state = PuzzleState.fromString("MIUUUM");
    state.applyRuleAt(4);
    expect(state.toString(), equals("MIUM"));
  });

  group("undo", () {
    test("single level basic undo", () {
      var state = PuzzleState();
      expect(state.canUndo(), equals(false));

      state.applyRuleAt(0);
      expect(state.canUndo(), equals(true));

      state.undo();
      expect(state.canUndo(), equals(false));
    });

    test("multiple levels of undo", () {
      var state = PuzzleState();
      expect(state.canUndo(), equals(false));

      state.applyRuleAt(0);
      state.applyRuleAt(0);
      state.applyRuleAt(0);
      state.applyRuleAt(0);

      expect(state.canUndo(), equals(true));

      state.undo();
      expect(state.canUndo(), equals(true));

      state.undo();
      expect(state.canUndo(), equals(true));

      state.applyRuleAt(0);
      expect(state.canUndo(), equals(true));

      state.undo();
      state.undo();
      state.undo();
      expect(state.canUndo(), equals(false));
    });
  });
}
