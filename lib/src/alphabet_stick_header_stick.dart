import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'alphabet_index_observe.dart';
import 'alphabet_index_base.dart';

///change notifier
class BaseChangeNotifier extends Listenable {
  //listeners
  final List<VoidCallback> _listeners = [];

  //notify all listeners
  void notifyListeners() {
    for (int s = _listeners.length - 1; s >= 0; s--) {
      _listeners[s]();
    }
  }

  //check listeners is not empty
  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  //add
  @override
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  //remove
  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  //remove all
  void clearListeners() {
    _listeners.clear();
  }

  //dispose
  void dispose() {
    clearListeners();
  }
}

///update frame tool
class UpdateFrameTool {
  //single instance
  factory UpdateFrameTool() => _instance;

  //single instance
  static UpdateFrameTool get instance => _instance;

  //single instance
  static final UpdateFrameTool _instance = UpdateFrameTool._internal();

  ///init
  UpdateFrameTool._internal();

  ///listeners
  List<VoidCallback> _listeners = [];

  ///is init or not ,only once
  static bool _isInit = false;

  ///add frame listener
  void addFrameListener(VoidCallback callback) {
    if (!_isInit) {
      _isInit = true;
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        for (VoidCallback listener in _listeners) {
          listener();
        }
      });
    }
    _listeners.add(callback);
  }

  ///remove frame listener
  void removeFrameListener(VoidCallback callback) {
    _listeners.remove(callback);
  }
}

///alphabet header list view group
class AlphabetHeaderListViewGroupController extends BaseChangeNotifier {
  ///current group
  int _currentGroup = 0;

  ///is offset or not
  double _currentOffset = 0;

  ///get current is offset or not
  double get currentOffset => _currentOffset;

  ///get current group
  int get currentGroup => _currentGroup;

  void setCurrentGroup(int value, double isOffset) {
    if (_currentGroup != value || _currentOffset != isOffset) {
      _currentGroup = value;
      _currentOffset = isOffset;
      notifyListeners();
    }
  }
}

///index tips bar
class AlphabetHeaderListViewStickView<T> extends StatefulWidget {
  ///stick offset controller
  final AlphabetHeaderListViewGroupController stickOffsetController;

  ///group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  ///tags list
  final List<AlphabetIndexGroup<T>> dataList;

  ///prefix index
  final String? indexPrefix;

  ///current offset
  final double scrollCurrentOffset;

  const AlphabetHeaderListViewStickView({
    super.key,
    required this.stickOffsetController,
    required this.groupBuilder,
    required this.dataList,
    this.scrollCurrentOffset = 0,
    this.indexPrefix,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderListViewStickViewState<T>();
  }
}

///tips bar state
class _AlphabetHeaderListViewStickViewState<T> extends State<AlphabetHeaderListViewStickView<T>> {
  ///listener
  late VoidCallback _listener;

  ///init state
  void initState() {
    _listener = () {
      setState(() {});
    };
    widget.stickOffsetController.addListener(_listener);
    super.initState();
  }

  ///update to reset listener
  void didUpdateWidget(AlphabetHeaderListViewStickView<T> oldWidget) {
    if (widget.stickOffsetController != oldWidget.stickOffsetController) {
      oldWidget.stickOffsetController.removeListener(_listener);
      widget.stickOffsetController.removeListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  void dispose() {
    widget.stickOffsetController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickOffsetController.currentGroup == -1 || widget.dataList.isEmpty) {
      return const SizedBox();
    }
    return Transform.translate(
      offset: Offset(0, min(-widget.stickOffsetController.currentOffset + 1 / MediaQuery.of(context).devicePixelRatio, 0)),
      child: widget.groupBuilder(
        widget.dataList.map((e) => e.tag).toList()[widget.stickOffsetController.currentGroup],
        widget.stickOffsetController.currentGroup,
      ),
    );
  }
}

///alphabet header list view group
@Deprecated("not need anymore")
class AlphabetHeaderListViewOffsetView<T> extends StatefulWidget {
  ///controller
  final AlphabetHeaderListViewGroupController controller;

  ///index
  final int groupIndex;

  ///child widget
  final AlphabetIndexGroupBuilder builder;

  ///data list
  final List<AlphabetIndexGroup<T>> dataList;

  const AlphabetHeaderListViewOffsetView({
    super.key,
    required this.controller,
    required this.groupIndex,
    required this.builder,
    required this.dataList,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderListViewOffsetViewState<T>();
  }
}

///alphabet header list view group state
class _AlphabetHeaderListViewOffsetViewState<T> extends State<AlphabetHeaderListViewOffsetView<T>> {
  ///listener
  late VoidCallback _listener;

  ///offset size
  Size? _offsetSize;

  @override
  void initState() {
    _listener = () {
      setState(() {});
    };
    widget.controller.addListener(_listener);
    super.initState();
  }

  ///update controller
  void didUpdateWidget(AlphabetHeaderListViewOffsetView<T> oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AlphabetIndexGroup<T>? formerGroup = widget.groupIndex - 1 >= 0 ? widget.dataList[widget.groupIndex - 1] : null;
    AlphabetIndexGroup<T> currentGroup = widget.dataList[widget.groupIndex];
    return Column(
      children: [
        _buildMeasureItem(
          formerGroup,
          currentGroup,
        ),
        _buildOffsetView(
          formerGroup,
          currentGroup,
        ),
        widget.builder(
          currentGroup.tag,
          widget.groupIndex,
        ),
      ],
    );
  }

  ///build measure item
  Widget _buildMeasureItem(AlphabetIndexGroup<T>? formerGroup, AlphabetIndexGroup<T> currentGroup) {
    if (_offsetSize != null || formerGroup == null) {
      return const SizedBox();
    }
    return Offstage(
      child: ObserveWidget(
        listener: (size) {
          _offsetSize = size;
          setState(() {});
        },
        child: widget.builder(
          formerGroup.tag,
          widget.groupIndex - 1,
        ),
      ),
    );
  }

  ///build offset view
  Widget _buildOffsetView(AlphabetIndexGroup<T>? formerGroup, AlphabetIndexGroup<T> currentGroup) {
    if (_offsetSize == null || formerGroup == null) {
      return const SizedBox();
    }
    return Visibility(
      visible: widget.controller.currentGroup == (widget.groupIndex - 1) && widget.controller.currentOffset != 0,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      maintainSemantics: true,
      child: SizedBox(
        height: 0.01,
        width: double.infinity,
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: _offsetSize?.height ?? 0,
          maxHeight: _offsetSize?.height ?? 0,
          child: widget.builder(
            formerGroup.tag,
            widget.groupIndex - 1,
          ),
        ),
      ),
    );
  }
}
