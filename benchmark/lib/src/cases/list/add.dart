import "package:benchmark_harness/benchmark_harness.dart";
import "package:built_collection/built_collection.dart";
import "package:kt_dart/kt.dart";
import "package:meta/meta.dart";

import "package:fast_immutable_collections/fast_immutable_collections.dart";

import "../../utils/table_score_emitter.dart";
import "../../utils/multi_benchmark_reporter.dart";
import "../../utils/collection_benchmark_base.dart";

// /////////////////////////////////////////////////////////////////////////////////////////////////

class ListAddBenchmark extends MultiBenchmarkReporter<ListBenchmarkBase> {
  static const int innerRuns = 100;

  @override
  final IList<ListBenchmarkBase> benchmarks;

  ListAddBenchmark({@required TableScoreEmitter emitter})
      : benchmarks = <ListBenchmarkBase>[
          MutableListAddBenchmark(emitter: emitter),
          IListAddBenchmark(emitter: emitter),
          KtListAddBenchmark(emitter: emitter),
          BuiltListAddWithRebuildBenchmark(emitter: emitter),
          BuiltListAddWithListBuilderBenchmark(emitter: emitter),
        ].lock,
        super(emitter: emitter);
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class MutableListAddBenchmark extends ListBenchmarkBase {
  MutableListAddBenchmark({@required ScoreEmitter emitter})
      : super(name: "List (Mutable)", emitter: emitter);

  List<int> _list;
  List<int> _fixedList;

  @override
  List<int> toMutable() => _list;

  @override
  void setup() => _fixedList = ListBenchmarkBase.getDummyGeneratedList(size: config.size);

  @override
  void run() {
    _list = List<int>.of(_fixedList);
    for (int i = 0; i < ListAddBenchmark.innerRuns; i++) _list.add(i);
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class IListAddBenchmark extends ListBenchmarkBase {
  IListAddBenchmark({@required ScoreEmitter emitter}) : super(name: "IList", emitter: emitter);

  IList<int> _iList;
  IList<int> _result;

  @override
  List<int> toMutable() => _result.unlock;

  @override
  void setup() {
    _iList = IList<int>();
    for (int i = 0; i < config.size; i++) _iList = _iList.add(i);
  }

  @override
  void run() {
    _result = _iList;
    for (int i = 0; i < ListAddBenchmark.innerRuns; i++) _result = _result.add(i);
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class KtListAddBenchmark extends ListBenchmarkBase {
  KtListAddBenchmark({@required ScoreEmitter emitter}) : super(name: "KtList", emitter: emitter);

  KtList<int> _ktList;
  KtList<int> _result;

  @override
  List<int> toMutable() => _result.asList();

  @override
  void setup() =>
      _ktList = ListBenchmarkBase.getDummyGeneratedList(size: config.size).toImmutableList();

  @override
  void run() {
    _result = _ktList;
    for (int i = 0; i < ListAddBenchmark.innerRuns; i++) _result = _result.plusElement(i);
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class BuiltListAddWithRebuildBenchmark extends ListBenchmarkBase {
  BuiltListAddWithRebuildBenchmark({@required ScoreEmitter emitter})
      : super(name: "BuiltList with Rebuild", emitter: emitter);

  BuiltList<int> _builtList;
  BuiltList<int> _result;

  @override
  List<int> toMutable() => _result.asList();

  @override
  void setup() {
    _builtList = BuiltList<int>(ListBenchmarkBase.getDummyGeneratedList(size: config.size));
  }

  @override
  void run() {
    _result = _builtList;
    for (int i = 0; i < ListAddBenchmark.innerRuns; i++)
      _result = _result.rebuild((ListBuilder<int> listBuilder) => listBuilder.add(i));
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

class BuiltListAddWithListBuilderBenchmark extends ListBenchmarkBase {
  BuiltListAddWithListBuilderBenchmark({@required ScoreEmitter emitter})
      : super(name: "BuiltList with List Builder", emitter: emitter);

  BuiltList<int> _builtList;
  BuiltList<int> _result;

  @override
  List<int> toMutable() => _result.asList();

  @override
  void setup() =>
      _builtList = BuiltList<int>(ListBenchmarkBase.getDummyGeneratedList(size: config.size));

  @override
  void run() {
    final ListBuilder<int> listBuilder = _builtList.toBuilder();
    for (int i = 0; i < ListAddBenchmark.innerRuns; i++) listBuilder.add(i);
    _result = listBuilder.build();
  }
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
