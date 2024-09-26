import 'package:flutter/material.dart';
import 'alphabet_index_base.dart';

///tag changed callback
typedef AlphabetIndexTagChanged = void Function(String tag);

///tag changed callback
typedef AlphabetIndexPositionChanged = void Function(
  Size currentSize,
  String currentTag,
  int currentIndex,
  double offsetFromCenter,
);

///alphabet index sidebar
class AlphabetIndexSideBar extends StatefulWidget {
  //side bar tags
  final List<String> sideBarTags;

  //side bar builder
  final AlphabetIndexSideBuilder? sideBarBuilder;

  //align
  final AlphabetIndexSideAlign sideBarAlign;

  //on change
  final AlphabetIndexTagChanged onChange;

  //position change
  final AlphabetIndexPositionChanged onPositionChange;

  //gesture start
  final VoidCallback onGestureStart;

  //gesture end
  final VoidCallback onGestureEnd;

  const AlphabetIndexSideBar({
    super.key,
    required this.sideBarTags,
    required this.sideBarAlign,
    required this.onChange,
    required this.onGestureStart,
    required this.onGestureEnd,
    required this.onPositionChange,
    this.sideBarBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexSideBarState();
  }
}

class _AlphabetIndexSideBarState extends State<AlphabetIndexSideBar> {
  //tags key
  final GlobalKey _tagsKey = GlobalKey();

  //current selected tag
  String? _selectedTag;

  //gesture change
  bool _isGesture = false;

  @override
  Widget build(BuildContext context) {
    ///tag widget
    List<Widget> sideBarWidgets = [];

    ///build tag items
    for (int s = 0; s < widget.sideBarTags.length; s++) {
      Widget item;

      ///from builder
      if (widget.sideBarBuilder != null) {
        item = widget.sideBarBuilder!(
          widget.sideBarTags[s],
          widget.sideBarTags[s] == _selectedTag,
        );
      }

      ///by default
      else {
        item = Padding(
          padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
          child: Text(
            widget.sideBarTags[s],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        );
      }
      sideBarWidgets.add(item);
    }

    return Align(
      alignment: widget.sideBarAlign == AlphabetIndexSideAlign.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (DragDownDetails details) {
          if (_isGesture != true) {
            _isGesture = true;
            widget.onGestureStart();
          }
          _checkAlphabet(
            widget.sideBarTags,
            details.localPosition.dy,
          );
        },
        onPanStart: (DragStartDetails details) {
          if (_isGesture != true) {
            _isGesture = true;
            widget.onGestureStart();
          }
          _checkAlphabet(
            widget.sideBarTags,
            details.localPosition.dy,
          );
        },
        onPanUpdate: (DragUpdateDetails details) {
          _checkAlphabet(
            widget.sideBarTags,
            details.localPosition.dy,
          );
        },
        onPanEnd: (DragEndDetails details) {
          if (_isGesture != false) {
            _isGesture = false;
            widget.onGestureEnd();
          }
        },
        onPanCancel: () {
          if (_isGesture != false) {
            _isGesture = false;
            widget.onGestureEnd();
          }
        },
        child: Column(
          key: _tagsKey,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: sideBarWidgets,
        ),
      ),
    );
  }

  ///check alphabet and jump
  void _checkAlphabet(List<String> tags, double offset) {
    if (_tagsKey.currentContext?.size?.height != null) {
      //height
      double height = _tagsKey.currentContext!.size!.height;
      double tagItemHeight = (height / tags.length);
      //calculate side bar index
      int sideBarIndex = (offset / tagItemHeight).truncate();
      if (sideBarIndex < 0 || sideBarIndex >= tags.length) {
        return;
      }
      String indexTag = tags[sideBarIndex];

      ///on changed
      if (_selectedTag != indexTag) {
        _selectedTag = indexTag;
        widget.onPositionChange(
          _tagsKey.currentContext!.size!,
          indexTag,
          sideBarIndex,
          -height / 2 + sideBarIndex * tagItemHeight + tagItemHeight / 2,
        );
      }

      ///refresh this page
      setState(() {});
    }
  }
}
