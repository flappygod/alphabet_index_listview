import 'alphabet_index_header_controller.dart';
import 'package:flutter/cupertino.dart';
import 'alphabet_index_side_bar.dart';
import 'alphabet_index_tip_bar.dart';
import 'alphabet_index_base.dart';

///alphabet index tips side bar
class AlphabetIndexTipSideBar extends StatefulWidget {
  //side bar
  final List<String> sideBarAlphabet;

  //controller
  final AlphabetHeaderViewController controller;

  //align
  final AlphabetIndexTipsAlign tipsBarAlign;

  //tips view builder
  final AlphabetIndexGroupBuilder? tipsBuilder;

  //align
  final AlphabetIndexSideAlign sideBarAlign;

  //side bar builder
  final AlphabetIndexSideBuilder? sideBarBuilder;

  final Curve? curve;
  final Duration? duration;

  //on change
  final AlphabetIndexTagChanged? onChange;

  const AlphabetIndexTipSideBar({
    super.key,
    required this.sideBarAlphabet,
    required this.controller,
    this.tipsBarAlign = AlphabetIndexTipsAlign.center,
    this.tipsBuilder,
    this.sideBarAlign = AlphabetIndexSideAlign.right,
    this.sideBarBuilder,
    this.curve,
    this.duration,
    this.onChange,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexTipSideBarState();
  }
}

///alphabet index tips side bar state
class _AlphabetIndexTipSideBarState extends State<AlphabetIndexTipSideBar> {
  ///tips bar controller
  final AlphabetIndexTipBarController _indexTipBarController =
      AlphabetIndexTipBarController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        _buildIndexBar(),
        _buildTipsBar(),
      ],
    );
  }

  ///build index bar
  Widget _buildIndexBar() {
    ///get tags
    List<String> sideBarTags = widget.sideBarAlphabet;

    ///alphabet index side bar
    return AlphabetIndexSideBar(
      sideBarTags: sideBarTags,
      sideBarAlign: widget.sideBarAlign,
      sideBarBuilder: widget.sideBarBuilder,
      onChange: widget.onChange,
      onGestureStart: () {
        _indexTipBarController.isGesture = true;
      },
      onGestureEnd: () {
        _indexTipBarController.isGesture = false;
      },
      onPositionChange: (Size currentSize, String currentTag, int currentIndex,
          double offsetFromCenter) {
        ///now we calculate the data list tags list , the side bar tags may not the same with data tags!
        List<String> dataTags = widget.sideBarAlphabet;
        int dataIndex = dataTags.indexOf(currentTag);
        if (dataIndex != -1) {
          widget.controller.scrollToGroup(
            dataIndex,
            curve: widget.curve,
            duration: widget.duration,
          );
        }

        ///set tips bar align offset
        switch (widget.tipsBarAlign) {
          case AlphabetIndexTipsAlign.center:
            _indexTipBarController.setGroup(currentTag, currentIndex, 0, 0);
            break;
          case AlphabetIndexTipsAlign.leftFollowSideBar:
            _indexTipBarController.setGroup(
              currentTag,
              currentIndex,
              widget.sideBarAlign == AlphabetIndexSideAlign.left
                  ? currentSize.width
                  : 0,
              offsetFromCenter,
            );
            break;
          case AlphabetIndexTipsAlign.rightFollowSideBar:
            _indexTipBarController.setGroup(
              currentTag,
              currentIndex,
              widget.sideBarAlign == AlphabetIndexSideAlign.right
                  ? -currentSize.width
                  : 0,
              offsetFromCenter,
            );
            break;
          case AlphabetIndexTipsAlign.centerFollowSideBar:
            _indexTipBarController.setGroup(
              currentTag,
              currentIndex,
              0,
              offsetFromCenter,
            );
            break;
        }
      },
    );
  }

  ///build tips bar
  Widget _buildTipsBar() {
    return AlphabetIndexTipBar(
      controller: _indexTipBarController,
      tipsBarAlign: widget.tipsBarAlign,
      tipsBuilder: widget.tipsBuilder,
    );
  }

  @override
  void dispose() {
    _indexTipBarController.dispose();
    super.dispose();
  }
}
