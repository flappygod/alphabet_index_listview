import 'package:flutter/cupertino.dart';
import 'alphabet_index_base.dart';

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

///alphabet header list view group
class AlphabetHeaderListViewGroupController extends BaseChangeNotifier {
  ///current group
  int _currentGroup = 0;

  ///is offset or not
  bool _isOffset = false;

  ///get current is offset or not
  bool get isOffset => _isOffset;

  ///get current group
  int get currentGroup => _currentGroup;

  void setCurrentGroup(int value, bool isOffset) {
    if (_currentGroup != value || _isOffset != isOffset) {
      _currentGroup = value;
      _isOffset = isOffset;
      notifyListeners();
    }
  }
}

///alphabet header list view group
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
      visible: widget.controller.currentGroup == (widget.groupIndex - 1) && widget.controller.isOffset,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      maintainSemantics: true,
      child: SizedBox(
        height: 0.01,
        child: OverflowBox(
          minHeight: _offsetSize?.height ?? 0,
          maxHeight: _offsetSize?.height ?? 0,
          alignment: Alignment.bottomCenter,
          child: widget.builder(
            formerGroup.tag,
            widget.groupIndex - 1,
          ),
        ),
      ),
    );
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
    return Visibility(
      visible: !widget.stickOffsetController.isOffset,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      maintainSemantics: true,
      child: widget.groupBuilder(
        widget.dataList.map((e) => e.tag).toList()[widget.stickOffsetController.currentGroup],
        widget.stickOffsetController.currentGroup,
      ),
    );
  }
}

///observe height listener
typedef ObserveHeightListener = Function(Size height);

///Observe widget height
class ObserveWidget extends StatefulWidget {
  //child
  final Widget child;

  //listener
  final ObserveHeightListener listener;

  const ObserveWidget({
    Key? key,
    required this.listener,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ObserveWidgetState();
  }
}

class _ObserveWidgetState extends State<ObserveWidget> {
  //globalKey
  final GlobalKey _globalKey = GlobalKey();

  //size
  Size? size;

  //addPostFrameCallback
  void _setListener() {
    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_globalKey.currentContext?.size != null &&
          (_globalKey.currentContext?.size?.width != size?.width || _globalKey.currentContext?.size?.height != size?.height)) {
        size = _globalKey.currentContext?.size;
        widget.listener(_globalKey.currentContext!.size!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _setListener();
    return Offstage(
      child: SizedBox(
        key: _globalKey,
        child: widget.child,
      ),
    );
  }
}
