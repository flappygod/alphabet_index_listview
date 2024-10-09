import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'alphabet_index_sidebar.dart';

///index bar list view
class AlphabetIndexListView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderListViewController<T>? controller;

  //group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  //child builder
  final AlphabetIndexChildBuilder<T> childBuilder;

  //data list
  final List<AlphabetIndexGroup<T>> dataList;

  //align
  final AlphabetIndexTipsAlign tipsBarAlign;

  //tips view builder
  final AlphabetIndexGroupBuilder? tipsBuilder;

  //align
  final AlphabetIndexSideAlign sideBarAlign;

  //side bar builder
  final AlphabetIndexSideBuilder? sideBarBuilder;

  //group selected
  final AlphabetIndexGroupScrolled? onGroupSelected;

  //alphabet list
  final List<String>? sideBarAlphabet;

  //scroll speed
  final Duration indexedScrollDuration;

  //stick header
  final bool stickHeader;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ChildIndexGetter? findChildIndexCallback;
  final EdgeInsets? padding;

  final double? preferGroupHeight;
  final double? preferChildHeight;

  //index bar list view
  const AlphabetIndexListView({
    super.key,
    this.controller,
    required this.dataList,
    required this.groupBuilder,
    required this.childBuilder,
    this.sideBarAlign = AlphabetIndexSideAlign.right,
    this.tipsBarAlign = AlphabetIndexTipsAlign.center,
    this.sideBarBuilder,
    this.sideBarAlphabet,
    this.tipsBuilder,
    this.stickHeader = true,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.physics,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.findChildIndexCallback,
    this.padding,
    this.onGroupSelected,
    double? preferGroupHeight,
    double? preferChildHeight,
    double? indexedScrollSpeed,
  })  : this.preferGroupHeight = preferGroupHeight,
        this.preferChildHeight = preferChildHeight,
        this.indexedScrollDuration =
            (preferGroupHeight != null && preferChildHeight != null)
                ? Duration.zero
                : const Duration(milliseconds: 50);

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexListViewState<T>();
  }
}

///index bar list view
class _AlphabetIndexListViewState<T> extends State<AlphabetIndexListView<T>> {
  ///head stick view controller
  late AlphabetHeaderListViewController<T> _alphabetHeaderListViewController;

  ///tips bar controller
  final AlphabetIndexTipBarController _indexTipBarController =
      AlphabetIndexTipBarController();

  @override
  void initState() {
    _alphabetHeaderListViewController = widget.controller ??
        AlphabetHeaderListViewController(
          preferGroupHeight: widget.preferGroupHeight,
          preferChildHeight: widget.preferChildHeight,
        );
    super.initState();
  }

  ///update widget if need
  void didUpdateWidget(AlphabetIndexListView<T> oldWidget) {
    if (_alphabetHeaderListViewController != widget.controller) {
      _alphabetHeaderListViewController =
          widget.controller ?? _alphabetHeaderListViewController;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _indexTipBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        _buildListView(),
        _buildIndexBar(),
        _buildTipsBar(),
      ],
    );
  }

  ///build list view
  Widget _buildListView() {
    return AlphabetHeaderListView<T>(
      onGroupSelected: widget.onGroupSelected,
      stickHeader: widget.stickHeader,
      dataList: widget.dataList,
      controller: _alphabetHeaderListViewController,
      groupBuilder: widget.groupBuilder,
      childBuilder: widget.childBuilder,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      semanticChildCount: widget.semanticChildCount,
      findChildIndexCallback: widget.findChildIndexCallback,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      padding: widget.padding,
    );
  }

  ///build index bar
  Widget _buildIndexBar() {
    ///get tags
    List<String> sideBarTags =
        widget.sideBarAlphabet ?? widget.dataList.map((e) => e.tag).toList();

    ///alphabet index side bar
    return AlphabetIndexSideBar(
      sideBarTags: sideBarTags,
      sideBarAlign: widget.sideBarAlign,
      sideBarBuilder: widget.sideBarBuilder,
      onChange: (String tag) {},
      onGestureStart: () {
        _indexTipBarController.isGesture = true;
      },
      onGestureEnd: () {
        _indexTipBarController.isGesture = false;
      },
      onPositionChange: (Size currentSize, String currentTag, int currentIndex,
          double offsetFromCenter) {
        ///now we calculate the data list tags list , the side bar tags may not the same with data tags!
        List<String> dataTags = widget.dataList.map((e) => e.tag).toList();
        int dataIndex = dataTags.indexOf(currentTag);
        if (dataIndex != -1) {
          _scrollToGroup(dataIndex);
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

  ///jump to group
  void _scrollToGroup(int groupIndex) {
    _alphabetHeaderListViewController.scrollToGroup(
      groupIndex,
      duration: widget.indexedScrollDuration,
    );
  }
}
