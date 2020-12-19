import "package:flutter_test/flutter_test.dart";
import "package:matcher/matcher.dart";

import "package:fast_immutable_collections/fast_immutable_collections.dart";

void main() {
  /////////////////////////////////////////////////////////////////////////////

  test("lock", () {
    // 1) From an empty list
    expect([].lock, isA<IList>());
    expect([].lock.isEmpty, isTrue);
    expect([].lock.isNotEmpty, isFalse);

    // 2) Type Check: from an empty list typed with String
    final typedList = <String>[].lock;
    expect(typedList, isA<IList<String>>());

    // 3) From a list with one item
    expect([1].lock, isA<IList<int>>());
    expect([1].lock.isEmpty, isFalse);
    expect([1].lock.isNotEmpty, isTrue);

    // 4) Nulls
    expect([null].lock, allOf(isA<IList<String>>(), [null]));

    // 5) Typical usage
    expect([1, 2, 3].lock, allOf(isA<IList<int>>(), [1, 2, 3]));
  });

  /////////////////////////////////////////////////////////////////////////////

  test("lockUnsafe", () {
    final List<int> list = [1, 2, 3];
    final IList<int> ilist = list.lockUnsafe;

    expect(list, ilist);

    list[1] = 4;

    expect(list, ilist);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("sortOrdered", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];

    list.sortOrdered((int a, int b) => a.compareTo(b));

    expect(list, [1, 2, 3, 4, 5, 10]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("sortLike", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];

    list.sortLike([1, 2, 3]);

    expect(list, [1, 2, 3, 4, 10, 5]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("sortLike | the ordering can't be null", () {
    expect(() => [1, 2, 3, 4, 10, 5].sortLike(null), throwsAssertionError);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("moveToTheEnd", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];
    list.moveToTheEnd(4);
    expect(list, [1, 2, 10, 3, 5, 4]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("moveToTheFront", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];
    list.moveToTheFront(4);
    expect(list, [4, 1, 2, 10, 3, 5]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("whereMoveToTheEnd", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];
    list.whereMoveToTheEnd((int item) => item > 4);
    expect(list, [1, 2, 4, 3, 10, 5]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("whereMoveToTheFront", () {
    final List<int> list = [1, 2, 4, 10, 3, 5];
    list.whereMoveToTheFront((int item) => item > 4);
    expect(list, [10, 5, 1, 2, 4, 3]);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("toggle", () {
    List<int> list = [1, 2, 3, 4, 5];

    // 1) Toggle existing item
    expect(list.contains(4), isTrue);
    expect(list.toggle(4), isTrue);
    expect(list.contains(4), isFalse);
    expect(list.toggle(4), isFalse);
    expect(list.contains(4), isTrue);

    // 2) Toggle NON-existing item
    expect(list.contains(6), isFalse);
    expect(list.toggle(6), isFalse);
    expect(list.contains(6), isTrue);
    expect(list.toggle(6), isTrue);
    expect(list.contains(6), isFalse);

    // 3) Nulls and other checks
    list = <int>[];
    expect(list.toggle(1), isFalse);
    expect(list.contains(1), isTrue);

    list = <int>[];
    expect(list.toggle(null), isFalse);
    expect(list.contains(null), isTrue);

    list = <int>[null];
    expect(list.toggle(1), isFalse);
    expect(list.contains(1), isTrue);

    list = <int>[null];
    expect(list.toggle(null), isTrue);
    expect(list.contains(null), isFalse);

    list = <int>[1];
    expect(list.toggle(1), isTrue);
    expect(list.contains(1), isFalse);

    list = <int>[1];
    expect(list.toggle(null), isFalse);
    expect(list.contains(null), isTrue);

    list = <int>[null, null, null];
    expect(list.toggle(1), isFalse);
    expect(list.contains(1), isTrue);

    list = <int>[null, null, null];
    expect(list.toggle(null), isTrue);
    expect(list, <int>[null, null]);

    list = <int>[null, 1, null, 1];
    expect(list.toggle(1), isTrue);
    expect(list, <int>[null, null, 1]);

    list = <int>[null, 1, null, 1];
    expect(list.toggle(null), isTrue);
    expect(list, <int>[1, null, 1]);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("compareAsSets", () {
    // 1) Identical
    const List<int> list1 = [1, 2, 3];
    const List<int> list2 = [1, 2, 3];
    const List<int> list3 = [1, 2, 4];
    const List<int> list4 = [1, 2, 2, 3, 3, 3];
    const List<int> list5 = [1, 2, 2, 3, 3, 3, 4];
    expect(list1.compareAsSets(list1), isTrue);
    expect(list1.compareAsSets(list2), isTrue);
    expect(list1.compareAsSets(list3), isFalse);
    expect(list1.compareAsSets(list4), isTrue);
    expect(list1.compareAsSets(list5), isFalse);

    // 3) Nulls
    // TODO: Marcelo, se `this == null` como podemos então chamar o método `compareAsSets`?
    List<int> list;
    expect(list.compareAsSets(null), isTrue);
    expect(list.compareAsSets([]), isFalse);
    expect([].compareAsSets(list), isFalse);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("mapIndexed", () {
    expect(
        [1, 2, 3].mapIndexed((int index, int item) => (index + item).toString()), ["1", "3", "5"]);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("splitList", () {
    expect([].splitList((v) => v == 3), []);

    expect([1, 2, 3, 4, 5].splitList((v) => v == 2 || v == 4), [
      [1],
      [3],
      [5]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].splitList((v) => v == 3), [
      [1, 2],
      [4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].splitList((v) => v == 1), [
      [2, 3, 4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].splitList((v) => v == 7), [
      [1, 2, 3, 4, 5, 6]
    ]);
  });

  // /////////////////////////////////////////////////////////////////////////////

  test("divideList", () {
    //
    expect([].divideList((v) => v == 3), []);

    expect([1, 2, 3, 4, 5].divideList((v) => v == 2 || v == 4), [
      [1, 2, 3],
      [4, 5]
    ]);

    expect([0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1].divideList((v) => v == 1), [
      [0, 1, 0],
      [1, 0],
      [1],
      [1, 0, 0],
      [1],
      [1],
      [1],
      [1],
      [1, 0],
      [1]
    ]);

    expect([1].divideList((v) => v == 1), [
      [1]
    ]);

    expect([1, 2].divideList((v) => v == 1), [
      [1, 2]
    ]);

    expect([1, 2].divideList((v) => v == 2), [
      [1, 2],
    ]);

    expect([1, 2, 3].divideList((v) => v == 2), [
      [1, 2, 3]
    ]);

    expect([1, 2, 3].divideList((v) => v == 2 || v == 3), [
      [1, 2],
      [3]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 3), [
      [1, 2, 3, 4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 1), [
      [1, 2, 3, 4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 7), [
      [1, 2, 3, 4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 8), [
      [1, 2, 3, 4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 3 || v == 4), [
      [1, 2, 3],
      [4, 5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 3 || v == 5), [
      [1, 2, 3, 4],
      [5, 6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v == 3 || v == 6), [
      [1, 2, 3, 4, 5],
      [6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v % 2 == 0), [
      [1, 2, 3],
      [4, 5],
      [6, 7]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7].divideList((v) => v % 2 == 1), [
      [1, 2],
      [3, 4],
      [5, 6],
      [7]
    ]);

    expect([1, 2, 3, 8, 12, 1, 4, 6].divideList((v) => v % 2 == 1), [
      [1, 2],
      [3, 8, 12],
      [1, 4, 6],
    ]);
  });

  // /////////////////////////////////////////////////////////////////////////////

  test("divideListAsMap", () {
    //
    expect([].divideListAsMap((v) => v == 3, key: (v) => -v), {});

    expect([1].divideListAsMap((v) => v == 1), {
      1: [1],
    });

    expect([1].divideListAsMap((v) => v == 1, key: (v) => -v), {
      -1: [1],
    });

    expect([1, 2].divideListAsMap((v) => v == 1, key: (v) => -v), {
      -1: [1, 2]
    });

    expect([1, 2].divideListAsMap((v) => v == 2, key: (v) => -v), {
      -2: [1, 2],
    });

    expect([1, 2, 3].divideListAsMap((v) => v == 2, key: (v) => -v), {
      -2: [1, 2, 3]
    });

    expect([1, 2, 3].divideListAsMap((v) => v == 2 || v == 3, key: (v) => -v), {
      -2: [1, 2],
      -3: [3]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 3, key: (v) => -v), {
      -3: [1, 2, 3, 4, 5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 1, key: (v) => -v), {
      -1: [1, 2, 3, 4, 5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 7, key: (v) => -v), {
      -7: [1, 2, 3, 4, 5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 8, key: (v) => -v), {
      null: [1, 2, 3, 4, 5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 3 || v == 4, key: (v) => -v), {
      -3: [1, 2, 3],
      -4: [4, 5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 3 || v == 5, key: (v) => -v), {
      -3: [1, 2, 3, 4],
      -5: [5, 6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v == 3 || v == 6, key: (v) => -v), {
      -3: [1, 2, 3, 4, 5],
      -6: [6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v % 2 == 0, key: (v) => -v), {
      -2: [1, 2, 3],
      -4: [4, 5],
      -6: [6, 7]
    });

    expect([1, 2, 3, 4, 5, 6, 7].divideListAsMap((v) => v % 2 == 1, key: (v) => -v), {
      -1: [1, 2],
      -3: [3, 4],
      -5: [5, 6],
      -7: [7]
    });

    /// Repeating keys will be joined together.
    expect([1, 2, 3, 8, 12, 1, 4, 6].divideListAsMap((v) => v % 2 == 1), {
      1: [1, 2, 1, 4, 6],
      3: [3, 8, 12],
    });
  });

  // /////////////////////////////////////////////////////////////////////////////

  test("addBetween", () {
    expect(null.addBetween("|"), null);
    expect([].addBetween("|"), []);
    expect(["A"].addBetween("|"), ["A"]);
    expect(["A", "B"].addBetween("|"), ["A", "|", "B"]);
    expect(["A", "B", "C"].addBetween("|"), ["A", "|", "B", "|", "C"]);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("Efficiently Concat lists. The resulting list has fixed size.", () {
    expect([].concat([], []), []);
    expect([5].concat([], []), [5]);
    expect([].concat([6], []), [6]);
    expect([].concat([], [7]), [7]);
    expect([1, 2].concat([3, 4, 5, 6], [7, 8, 9]), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect([1, 2].concat([7, 8, 9]), [1, 2, 7, 8, 9]);
    expect([1, 2].concat([], [7, 8, 9]), [1, 2, 7, 8, 9]);
    expect([1, 2].concat([2, 3], [3, 4]), [1, 2, 2, 3, 3, 4]);
    expect([1, 2].concat([2, 3], null, [3, 4]), [1, 2, 2, 3, 3, 4]);
    expect(null.concat([2, 3], null, [3, 4]), [2, 3, 3, 4]);
    expect([10, 2].concat([20, 3], [30]), [10, 2, 20, 3, 30]);
    expect(["10", 2].concat([20, "3"], [30]), ["10", 2, 20, "3", 30]);
    expect(["10", 2].concat([20, "3"], [30], ["a", "b"]), ["10", 2, 20, "3", 30, "a", "b"]);
    expect([1].concat([2], [3], [4], [5]), [1, 2, 3, 4, 5]);

    // The resulting list is not unmodifiable/immutable.
    var list = [1, 2].concat([3, 4]);
    list[2] = 100;
    expect(list, [1, 2, 100, 4]);

    // The resulting list has fixed size.
    expect(() => [1, 2].concat([3, 4])..add(5), throwsA(isA<Error>()));
  });

  /////////////////////////////////////////////////////////////////////////////

  test("splitByLength", () {
    //
    expect([1, 2, 3, 4, 5, 6, 7, 8].splitByLength(2), [
      [1, 2],
      [3, 4],
      [5, 6],
      [7, 8],
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(2), [
      [1, 2],
      [3, 4],
      [5, 6],
      [7, 8],
      [9]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(1), [
      [1],
      [2],
      [3],
      [4],
      [5],
      [6],
      [7],
      [8],
      [9]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(3), [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(8), [
      [1, 2, 3, 4, 5, 6, 7, 8],
      [9]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(9), [
      [1, 2, 3, 4, 5, 6, 7, 8, 9]
    ]);

    expect([1, 2, 3, 4, 5, 6, 7, 8, 9].splitByLength(50), [
      [1, 2, 3, 4, 5, 6, 7, 8, 9]
    ]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("update", () {
    //
    var list = <_WithId>[];
    var newItems = [_WithId(id: "x", name: "Lyn")];
    var updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [_WithId(id: "x", name: "Lyn")]);

    //
    list = [_WithId(id: "x", name: "Lyn")];
    newItems = <_WithId>[];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [_WithId(id: "x", name: "Lyn")]);

    //
    list = [_WithId(id: "x", name: "Marc")];
    newItems = [_WithId(id: "x", name: "Lyn")];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [_WithId(id: "x", name: "Lyn")]);

    //
    list = [_WithId(id: "x", name: "Marc")];
    newItems = [_WithId(id: "a", name: "Lyn")];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "x", name: "Marc"),
      _WithId(id: "a", name: "Lyn"),
    ]);

    //
    // Replace the first, remove the second.
    list = [_WithId(id: "x", name: "Marc"), _WithId(id: "x", name: "Marc")];
    newItems = [_WithId(id: "x", name: "Lyn")];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "x", name: "Lyn"),
    ]);

    //
    // Remove nulls.
    list = [_WithId(id: "x", name: "Marc"), null, _WithId(id: "x", name: "Marc")];
    newItems = [];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "x", name: "Marc"),
      _WithId(id: "x", name: "Marc"),
    ]);

    //
    list = [_WithId(id: "x", name: "Marc")];
    newItems = [_WithId(id: "a", name: "Lyn"), _WithId(id: "a", name: "Lyn")];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "x", name: "Marc"),
      _WithId(id: "a", name: "Lyn"),
      _WithId(id: "a", name: "Lyn"),
    ]);

    //
    list = [_WithId(id: "a", name: "Marc")];
    newItems = [_WithId(id: "a", name: "Lyn"), _WithId(id: "a", name: "Lyn")];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "a", name: "Lyn"),
      _WithId(id: "a", name: "Lyn"),
    ]);

    //
    list = [null, _WithId(id: "x", name: "Marc")];
    newItems = [null, _WithId(id: "a", name: "Lyn"), null];
    updatedList = list.update(newItems, (_WithId obj) => obj.id);
    expect(updatedList, [
      _WithId(id: "x", name: "Marc"),
      _WithId(id: "a", name: "Lyn"),
    ]);

    //
    list = [
      _WithId(id: "x", name: "Marc"),
      _WithId(id: "y", name: "Bill"),
      _WithId(id: "z", name: "Luke"),
      _WithId(id: "k", name: "July"),
      _WithId(id: "l", name: "Samy"),
      _WithId(id: "m", name: "Jane"),
      _WithId(id: "n", name: "Zack"),
    ];

    newItems = [
      _WithId(id: "x", name: "Lyn"),
      _WithId(id: "a", name: "Richard"),
      _WithId(id: "l", name: "Lea"),
      _WithId(id: "n", name: "Amy"),
    ];

    updatedList = list.update(newItems, (_WithId obj) => obj.id);

    expect(updatedList, [
      _WithId(id: "x", name: "Lyn"),
      _WithId(id: "y", name: "Bill"),
      _WithId(id: "z", name: "Luke"),
      _WithId(id: "k", name: "July"),
      _WithId(id: "l", name: "Lea"),
      _WithId(id: "m", name: "Jane"),
      _WithId(id: "n", name: "Amy"),
      _WithId(id: "a", name: "Richard"),
    ]);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  test("distinct", () {
    expect(([].distinct()), []);
    expect(([5, 5, 5].distinct()), [5]);
    expect(([1, 2, 3, 4].distinct()), [1, 2, 3, 4]);
    expect(([1, 2, 3, 4, 3, 5, 3].distinct()), [1, 2, 3, 4, 5]);
    expect(([1, 2, 3, 4, 3, 5, 1].distinct()), [1, 2, 3, 4, 5]);
    expect((["abc", "abc", "def"].distinct()), ["abc", "def"]);
    expect((["abc", "abc", "def"].distinct()).take(1), ["abc"]);

    expect((["a", "b", "abc", "ab", "def"].distinct((item) => item.length)), ["a", "abc", "ab"]);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("reversedListView runtime type", () {
    expect([].reversed is Iterable, isTrue);
    expect([].reversed is List, isFalse);
    expect([].reversedListView is List, isTrue);
    expect([1].reversedListView is List<int>, isTrue);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView | single, first, last, length", () {
    // 1) single

    expect(() => [].reversedListView.single, throwsStateError);
    expect(() => [1, 2].reversedListView.single, throwsStateError);
    expect([1].reversedListView.single, 1);

    // 2) first | last

    var list = [0, 1, 2, 3, 3, 4];
    var inverted = list.reversedListView;

    expect(inverted.first, 4);

    expect(inverted.last, 0);

    expect(() => [].reversedListView.first, throwsStateError);
    expect(() => [].reversedListView.last, throwsStateError);

    // 3) length

    expect(inverted.length, 6);

    // 4) length, first and  last setters

    // TODO: Marcelo, é isso mesmo que você gostaria que fossem estes testes?
    list = [1, 2, 3].reversedListView;
    expect(() => list.length = 100, throwsUnsupportedError);

    list.first = 100;
    expect(list.first, 100);

    list.last = 500;
    expect(list.last, 500);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.indexWhere", () {
    var list = [0, 1, 2, 3, 3, 4];
    var inverted = list.reversedListView;

    expect(inverted.indexWhere((i) => i == 0), 5);
    expect(inverted.indexWhere((i) => i == 1), 4);
    expect(inverted.indexWhere((i) => i == 2), 3);
    expect(inverted.indexWhere((i) => i == 3), 1);
    expect(inverted.indexWhere((i) => i == 4), 0);
    expect(inverted.indexWhere((i) => i == 5), null);
    expect(inverted.indexWhere((i) => i == 4, 1), null);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.lastIndexWhere", () {
    var list = [0, 1, 2, 3, 3, 4];
    var inverted = list.reversedListView;

    expect(inverted.lastIndexWhere((i) => i == 0), 5);
    expect(inverted.lastIndexWhere((i) => i == 1), 4);
    expect(inverted.lastIndexWhere((i) => i == 2), 3);
    expect(inverted.lastIndexWhere((i) => i == 3), 2);
    expect(inverted.lastIndexWhere((i) => i == 4), 0);
    expect(inverted.lastIndexWhere((i) => i == 5), null);

    expect(inverted.lastIndexWhere((i) => i == 0, 1), null);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.+", () {
    List<int> list = [1, 2, 3].reversedListView;

    // TODO
    expect(list + [4, 5, 6], [3, 2, 1, 4, 5, 6]);
    expect(list + [4], [3, 2, 1, 4]);
    expect(list + [null], [3, 2, 1, null]);
    expect(() => list + null, throwsNoSuchMethodError);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.[]", () {
    const List<int> list = [0, 1, 2, 3, 4];
    final List<int> inverted = list.reversedListView;

    expect(inverted[0], 4);
    expect(inverted[1], 3);
    expect(inverted[2], 2);
    expect(inverted[3], 1);
    expect(inverted[4], 0);
    expect(() => inverted[5], throwsRangeError);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.[]=", () {
    List<int> list = [1, 2, 3].reversedListView;

    expect(() => list[-100] = 10, throwsRangeError);
    expect(() => list[-1] = 10, throwsRangeError);
    expect(() => list[100] = 10, throwsRangeError);
    expect(() => list[3] = 10, throwsRangeError);

    list[0] = 10;
    expect(list, [10, 2, 1]);
    list[1] = 10;
    expect(list, [10, 10, 1]);
    list[2] = 10;
    expect(list, [10, 10, 10]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.add", () {
    List<int> reversed = [1, 2, 3].reversedListView;

    reversed.add(1);
    expect(reversed, [3, 2, 1, 1]);

    reversed.add(null);
    expect(reversed, [3, 2, 1, 1, null]);

    reversed = <int>[null].reversedListView;
    reversed.add(1);
    expect(reversed, <int>[null, 1]);

    reversed = [null, 1, null, 2].reversedListView;
    reversed.add(10);
    expect(reversed, <int>[2, null, 1, null, 10]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.addAll", () {
    List<int> reversed = [1, 2, 3].reversedListView;

    reversed.addAll([1, 2]);
    expect(reversed, [3, 2, 1, 1, 2]);

    reversed.addAll([1, null]);
    expect(reversed, [3, 2, 1, 1, null]);

    reversed = <int>[null].reversedListView;
    reversed.addAll([1, 2]);
    expect(reversed, <int>[null, 1, 2]);

    reversed = [null, 1, null, 2].reversedListView;
    reversed.addAll([10, 11]);
    expect(reversed, <int>[2, null, 1, null, 10, 11]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.elementAt", () {
    const List<int> list = [0, 1, 2, 3, 4];
    final List<int> inverted = list.reversedListView;

    expect(inverted.elementAt(0), 4);
    expect(inverted.elementAt(1), 3);
    expect(inverted.elementAt(2), 2);
    expect(inverted.elementAt(3), 1);
    expect(inverted.elementAt(4), 0);
    expect(() => inverted.elementAt(5), throwsRangeError);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.any", () {
    final List<int> inverted = [0, 1, 2, 3, 4].reversedListView;

    expect(inverted.any((i) => i == 2), isTrue);
    expect(inverted.any((i) => i == 5), isFalse);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.asMap", () {
    expect([1, 2, 3].reversedListView.asMap(), {0: 3, 1: 2, 2: 1});
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.cast", () {
    const TypeMatcher<TypeError> isTypeError = TypeMatcher<TypeError>();
    final Matcher throwsTypeError = throwsA(isTypeError);

    final List<int> inverted = [1, 2, 3].reversedListView;
    expect(inverted.cast<num>(), allOf(isA<List<num>>(), <num>[3, 2, 1]));
    expect(() => inverted.cast<String>(), throwsTypeError);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.clear", () {
    final List<int> inverted = [0, 1, 2, 3, 4].reversedListView;
    expect(inverted, [4, 3, 2, 1, 0]);
    expect(inverted.isEmpty, isFalse);
    inverted.clear();
    expect(inverted, []);
    expect(inverted.isEmpty, isTrue);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.contains", () {
    final List<int> inverted = [0, 1, 2, 3, 4].reversedListView;

    expect(inverted.contains(0), isTrue);
    expect(inverted.contains(1), isTrue);
    expect(inverted.contains(2), isTrue);
    expect(inverted.contains(3), isTrue);
    expect(inverted.contains(4), isTrue);
    expect(inverted.contains(5), isFalse);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.every", () {
    final List<int> inverted = [1, 2, 3, 4, 5, 6].reversedListView;
    expect(inverted.every((int v) => v > 0), isTrue);
    expect(inverted.every((int v) => v < 0), isFalse);
    expect(inverted.every((int v) => v != 4), isFalse);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.expand", () {
    final List<int> inverted = [1, 2, 3, 4, 5, 6].reversedListView;
    expect(inverted.expand((int v) => [v, v]),
        allOf(isA<Iterable<int>>(), [6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1]));
    expect(inverted.expand((int v) => <int>[]), allOf(isA<Iterable<int>>(), <int>[]));
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.fillRange", () {
    final List<int> list = List<int>(3).reversedListView;
    list.fillRange(0, 2, 1);
    expect(list, [1, 1, null]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.firstWhere", () {
    final List<int> inverted = [1, 2, 3, 4, 5, 6].reversedListView;
    expect(inverted.firstWhere((int v) => v <= 1, orElse: () => 100), 1);
    expect(inverted.firstWhere((int v) => v < 5, orElse: () => 100), 4);
    expect(inverted.firstWhere((int v) => v > 5, orElse: () => 100), 6);
    expect(inverted.firstWhere((int v) => v > 6, orElse: () => 100), 100);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.fold", () {
    expect([1, 2, 3, 4, 5, 6].reversedListView.fold(100, (int p, int e) => p * (1 + e)), 504000);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.followedBy", () {
    final List<int> inverted = [1, 2, 3, 4, 5, 6].reversedListView;
    expect(inverted.followedBy([7, 8]), [6, 5, 4, 3, 2, 1, 7, 8]);
    expect(inverted.followedBy(<int>[].lock.add(7).addAll([8, 9])), [6, 5, 4, 3, 2, 1, 7, 8, 9]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.forEach", () {
    int result = 100;
    [1, 2, 3, 4, 5, 6].reversedListView.forEach((int v) => result *= 1 + v);
    expect(result, 504000);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.getRange", () {
    final List<String> colors = ["red", "green", "blue", "orange", "pink"].reversedListView;
    final Iterable<String> range = colors.getRange(1, 4);
    expect(range, ["green", "blue", "orange"]);
    expect(colors, ["red", "green", "blue", "orange", "pink"]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.indexOf", () {
    var inverted = ["do", "re", "mi", "re"].reversedListView;

    // 1) Regular usage
    expect(inverted.indexOf("re"), 0);
    expect(inverted.indexOf("re", 1), 2);
    expect(inverted.indexOf("fa"), -1);

    // 2) Argument error
    expect(() => inverted.indexOf("re", -1), throwsArgumentError);
    expect(() => inverted.indexOf("re", 4), throwsArgumentError);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.insert", () {
    final List<String> inverted = ["do", "re", "mi", "re"].reversedListView;
    inverted.insert(2, "fa");

    expect(inverted, ["re", "mi", "fa", "re", "do"]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView || isEmpty | isNotEmpty", () {
    expect([].reversedListView, isEmpty);
    expect([1].reversedListView, isNotEmpty);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.iterator", () {
    const List<int> list = [0, 1, 2, 3, 4];
    final List<int> inverted = list.reversedListView;
    var iterator = inverted.iterator;

    expect(iterator.current, isNull);

    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, inverted[0]);

    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, inverted[1]);

    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, inverted[2]);

    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, inverted[3]);

    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, inverted[4]);

    expect(iterator.moveNext(), isFalse);
    expect(iterator.current, isNull);
  });

  /////////////////////////////////////////////////////////////////////////////

  test("reversedListView.lastIndexOf", () {
    // 1) Regular Usage
    List<String> inverted = ["do", "re", "mi", "re"].reversedListView;
    expect(inverted.lastIndexOf("re", 1), 2);
    expect(inverted.lastIndexOf("re"), 2);
    expect(inverted.lastIndexOf("fa"), -1);

    // 2) Start cannot be smaller than zero
    inverted = ["do", "re", "mi", "re"].reversedListView;
    expect(() => inverted.lastIndexOf("do", -1), throwsArgumentError);
  }, skip: true);

  /////////////////////////////////////////////////////////////////////////////

  test("reversedListView.lastWhere", () {
    final List<int> inverted = [1, 2, 3, 4, 5, 6].reversedListView;
    expect(inverted.lastWhere((int v) => v < 2, orElse: () => 100), 1);
    expect(inverted.lastWhere((int v) => v < 5, orElse: () => 100), 1);
    expect(inverted.lastWhere((int v) => v > 1, orElse: () => 100), 2);
    expect(inverted.lastWhere((int v) => v >= 5, orElse: () => 100), 5);
    expect(inverted.lastWhere((int v) => v < 50, orElse: () => 100), 1);
    expect(inverted.lastWhere((int v) => v < 1, orElse: () => 100), 100);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.map", () {
    expect([1, 2, 3].reversedListView.map((int v) => v + 1), [4, 3, 2]);
    expect([1, 2, 3, 4, 5, 6].reversedListView.map((int v) => v + 1), [7, 6, 5, 4, 3, 2]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.reduce", () {
    // 1) Regular usage
    expect([1, 2, 3, 4, 5, 6].reversedListView.reduce((int p, int e) => p * (1 + e)), 4320);
    expect([5].reversedListView.reduce((int p, int e) => p * (1 + e)), 5);

    // 2) State Exception
    expect(() => IList().reduce((dynamic p, dynamic e) => p * (1 + (e as num))), throwsStateError);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.remove", () {
    List<int> inverted = [1, 2, 3].reversedListView;

    expect(inverted.remove(2), isTrue);
    expect(inverted, [3, 1]);

    expect(inverted.remove(3), isTrue);
    expect(inverted, [1]);

    expect(inverted.remove(10), isFalse);
    expect(inverted, [1]);

    expect(inverted.remove(1), isTrue);
    expect(inverted, []);

    expect(inverted.remove(10), isFalse);
    expect(inverted, []);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.removeAt", () {
    final List<String> inverted = ["do", "re", "mi", "re"].reversedListView;
    expect(inverted.removeAt(1), "mi");
    expect(inverted, ["re", "re", "do"]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.removeLast", () {
    final List<String> inverted = ["do", "re", "mi", "re"].reversedListView;
    expect(inverted.removeLast(), "do");
    expect(inverted, ["re", "mi", "re"]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.removeRange", () {
    final List<String> inverted = ["do", "re", "mi", "re"].reversedListView;
    inverted.removeRange(1, 3);
    expect(inverted, ["re", "do"]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.removeWhere", () {
    final List<String> inverted = ["one", "two", "three", "four"].reversedListView;
    inverted.removeWhere((String item) => item.length == 3);
    expect(inverted, ["four", "three"]);
  });

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.replaceRange", () {
    final List<String> inverted = ["a", "b", "c", "d", "e"].reversedListView;
    inverted.replaceRange(1, 4, ["f", "g"]);
    expect(inverted, ["e", "f", "g"]);
  }, skip: true);

  //////////////////////////////////////////////////////////////////////////////

  test("reversedListView.retainWhere", () {
    final List<String> inverted = ["one", "two", "three", "four"].reversedListView;
    inverted.retainWhere((String item) => item.length == 3);
    expect(inverted, ["two", "one"]);
  });

  //////////////////////////////////////////////////////////////////////////////
}

class _WithId {
  String id;
  String name;

  _WithId({this.id, this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WithId && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => "_WithId{$id, $name}";
}

// /////////////////////////////////////////////////////////////////////////////
