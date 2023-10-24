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
  UpdateFrameTool._internal(){
    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        for (VoidCallback listener in _listeners) {
          listener();
        }
      });
    });
  }

  ///listeners
  List<VoidCallback> _listeners = [];

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

  ///child
  Widget? _child;

  ///child group
  int? _childGroup;

  ///init state
  void initState() {
    _listener = () {
      setState(() {});
    };
    widget.stickOffsetController.addListener(_listener);
    super.initState();
  }

  ///get child
  Widget _getChild() {
    if (_childGroup != widget.stickOffsetController.currentGroup) {
      _childGroup = widget.stickOffsetController.currentGroup;
      _child = widget.groupBuilder(
        widget.dataList.map((e) => e.tag).toList()[widget.stickOffsetController.currentGroup],
        widget.stickOffsetController.currentGroup,
      );
    }
    return _child ?? const SizedBox();
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
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Transform.translate(
        offset: Offset(
          0,
          min(-widget.stickOffsetController.currentOffset + 1 / MediaQuery.of(context).devicePixelRatio, 0),
        ),
        child: _getChild(),
      ),
    );
  }
}
