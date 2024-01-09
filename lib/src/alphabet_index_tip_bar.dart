import 'package:flutter/cupertino.dart';
import 'alphabet_index_base.dart';

///controller
class AlphabetIndexTipBarController extends ChangeNotifier {
  //selected tag
  String? _selectedTag;

  //selected group
  int? _selectedGroup;

  //gesture
  bool _isGesture = false;

  //set offset
  double _translateOffsetX = 0;

  //set offset
  double _translateOffsetY = 0;

  void setGroup(
      String groupTag, int groupIndex, double offsetX, double offsetY) {
    _selectedTag = groupTag;
    _selectedGroup = groupIndex;
    _translateOffsetX = offsetX;
    _translateOffsetY = offsetY;
    notifyListeners();
  }

  //set is gesture
  set isGesture(bool value) {
    _isGesture = value;
    notifyListeners();
  }

  String? get selectedTag => _selectedTag;

  int? get selectedGroup => _selectedGroup;

  bool get isGesture => _isGesture;

  double get translateOffsetX => _translateOffsetX;

  double get translateOffsetY => _translateOffsetY;
}

///index tips bar
class AlphabetIndexTipBar extends StatefulWidget {
  final AlphabetIndexTipBarController controller;
  final AlphabetIndexGroupBuilder? tipsBuilder;
  final AlphabetIndexTipsAlign tipsBarAlign;

  const AlphabetIndexTipBar({
    super.key,
    required this.controller,
    required this.tipsBarAlign,
    required this.tipsBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexTipBarState();
  }
}

class _AlphabetIndexTipBarState extends State<AlphabetIndexTipBar> {
  late VoidCallback _listener;

  void initState() {
    _listener = () {
      setState(() {});
    };
    widget.controller.addListener(_listener);
    super.initState();
  }

  void didUpdateWidget(AlphabetIndexTipBar oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller._selectedTag == null ||
        widget.controller._selectedTag!.isEmpty ||
        widget.controller._selectedGroup == null) {
      return const SizedBox();
    }

    ///build tips bar
    Widget tipsBar;
    if (widget.tipsBuilder != null) {
      tipsBar = Visibility(
        visible: widget.controller._isGesture,
        child: widget.tipsBuilder!(
          widget.controller._selectedGroup!,
          widget.controller._selectedTag!,
        ),
      );
    } else {
      tipsBar = Visibility(
        visible: widget.controller._isGesture,
        child: kTipsBarDefault(
          widget.controller._selectedGroup!,
          widget.controller._selectedTag!,
        ),
      );
    }

    ///align
    switch (widget.tipsBarAlign) {
      case AlphabetIndexTipsAlign.center:
        return Align(
          alignment: Alignment.center,
          child: tipsBar,
        );
      case AlphabetIndexTipsAlign.centerFollowSideBar:
        return Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, widget.controller._translateOffsetY),
            child: tipsBar,
          ),
        );
      case AlphabetIndexTipsAlign.leftFollowSideBar:
        return Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(
              widget.controller._translateOffsetX,
              widget.controller._translateOffsetY,
            ),
            child: tipsBar,
          ),
        );
      case AlphabetIndexTipsAlign.rightFollowSideBar:
        return Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: Offset(
              widget.controller._translateOffsetX,
              widget.controller._translateOffsetY,
            ),
            child: tipsBar,
          ),
        );
    }
  }
}
