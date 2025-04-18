import 'package:flutter/cupertino.dart';
import 'alphabet_index_base.dart';
import 'dart:math';

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
  UpdateFrameTool._internal() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      for (VoidCallback listener in _listeners) {
        listener();
      }
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        for (VoidCallback listener in _listeners) {
          listener();
        }
      });
    });
  }

  ///listeners
  final List<VoidCallback> _listeners = [];

  ///add frame listener
  void addFrameListener(VoidCallback callback) {
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
  int _currentGroup = -1;

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

  const AlphabetHeaderListViewStickView({
    super.key,
    required this.stickOffsetController,
    required this.groupBuilder,
    required this.dataList,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderListViewStickViewState<T>();
  }
}

///tips bar state
class _AlphabetHeaderListViewStickViewState<T>
    extends State<AlphabetHeaderListViewStickView<T>> {
  ///listener
  late VoidCallback _listener;

  ///child
  Widget? _child;

  ///child group
  int? _childGroup;

  ///init state
  @override
  void initState() {
    _listener = () {
      setState(() {});
    };
    widget.stickOffsetController.addListener(_listener);
    super.initState();
  }

  ///get child
  Widget _getChild() {
    if (_childGroup != widget.stickOffsetController.currentGroup &&
        widget.stickOffsetController.currentGroup < widget.dataList.length) {
      _childGroup = widget.stickOffsetController.currentGroup;
      _child = widget.groupBuilder(
        widget.stickOffsetController.currentGroup,
        widget.dataList[widget.stickOffsetController.currentGroup].tag,
      );
    }
    return _child ?? const SizedBox();
  }

  ///update to reset listener
  @override
  void didUpdateWidget(AlphabetHeaderListViewStickView<T> oldWidget) {
    _child = null;
    _childGroup = null;
    if (widget.stickOffsetController != oldWidget.stickOffsetController) {
      oldWidget.stickOffsetController.removeListener(_listener);
      widget.stickOffsetController.addListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  @override
  void dispose() {
    widget.stickOffsetController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickOffsetController.currentGroup == -1 ||
        widget.dataList.isEmpty) {
      return const SizedBox();
    }
    double offsetDy = min(
        -widget.stickOffsetController.currentOffset +
            1 / MediaQuery.of(context).devicePixelRatio,
        0);
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Transform.translate(
        offset: Offset(0, offsetDy),
        child: _getChild(),
      ),
    );
  }
}
