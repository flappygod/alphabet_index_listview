import 'package:scroll_to_index/scroll_to_index.dart';
import 'alphabet_stick_header_stick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'alphabet_index_base.dart';
import 'alphabet_index_tool.dart';
import 'dart:async';

typedef AlphabetHeaderScrollToProvider = int Function(int group, {int child});

///group list view controller
class AlphabetHeaderSliverViewController<T> {
  ///scroll controller
  final AutoScrollController _scrollController;

  ///get scroll controller
  AutoScrollController get scrollController => _scrollController;

  ///provider
  AlphabetHeaderScrollToProvider? _headerScrollToProvider;

  ///scrolling
  bool _isScrolling = false;

  ///create list view controller
  AlphabetHeaderSliverViewController({
    AutoScrollController? scrollController,
  }) : _scrollController = scrollController ?? AutoScrollController();

  ///scroll to group
  Future<bool> scrollToGroup(
    int groupIndex, {
    Duration? scrollAnimationDuration,
    AutoScrollPosition? preferPosition,
  }) async {
    if (_headerScrollToProvider != null) {
      int index = _headerScrollToProvider!(groupIndex);
      if (_isScrolling == false) {
        _isScrolling = true;
        await _scrollController.scrollToIndex(
          index,
          duration: scrollAnimationDuration ?? Duration(milliseconds: 20),
          preferPosition: preferPosition ?? AutoScrollPosition.begin,
        );
        _isScrolling = false;
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  ///scroll to child
  void scrollToChild(
    int groupIndex,
    int childIndex, {
    Duration? scrollAnimationDuration,
    AutoScrollPosition? preferPosition,
  }) {
    if (_headerScrollToProvider != null) {
      int index = _headerScrollToProvider!(groupIndex, child: childIndex);
      _scrollController.scrollToIndex(
        index,
        duration: scrollAnimationDuration ?? Duration(microseconds: 1),
        preferPosition: preferPosition ?? AutoScrollPosition.begin,
      );
    }
  }
}

///group list view
class AlphabetHeaderSliverView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderSliverViewController<T> controller;

  //group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  //child builder
  final AlphabetIndexChildBuilder<T> childBuilder;

  //data list
  final List<AlphabetIndexGroup<T>> dataList;

  //header view
  final Widget? headerView;

  //foot view
  final Widget? footerView;

  //group selected
  final AlphabetIndexGroupScrolled? onGroupSelected;

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

  ///the group height is instability
  final instabilityHeaderHeight;

  const AlphabetHeaderSliverView({
    super.key,
    required this.dataList,
    required this.controller,
    required this.groupBuilder,
    required this.childBuilder,
    this.onGroupSelected,
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
    this.instabilityHeaderHeight = false,
    this.headerView,
    this.footerView,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderSliverViewState<T>();
  }
}

///group list view state
class _AlphabetHeaderSliverViewState<T>
    extends State<AlphabetHeaderSliverView<T>> {
  ///unique str
  final String _uniqueStr =
      "alphabet_index_list_view_stick_header_index_prefix";

  ///scroll key
  final GlobalKey _scrollKey = GlobalKey();

  ///data update listener
  late AlphabetHeaderScrollToProvider _provider;

  ///frame update callback
  late VoidCallback _frameUpdateListener;

  ///header controller
  final AlphabetHeaderListViewGroupController _headerController =
      AlphabetHeaderListViewGroupController();

  ///header key
  final GlobalKey _headerKey = GlobalKey();

  ///calculated group position list
  final Map<int, GroupPosition> _groupPositionList = {};

  ///init controllers
  void _initControllers() {
    ///set index provider for controller to known which index to jump
    _provider = (int group, {int? child}) {
      if (child == null) {
        return AlphabetIndexTool.getItemIndexFromGroupPos(
            widget.dataList, group);
      } else {
        return AlphabetIndexTool.getItemIndexFromGroupPos(
                widget.dataList, group) +
            child +
            1;
      }
    };
    widget.controller._headerScrollToProvider = _provider;

    ///update frame and calculate all groups position if need
    _frameUpdateListener = () {
      _refreshGroupPositions();
    };
    UpdateFrameTool.instance.addFrameListener(_frameUpdateListener);
  }

  ///init state
  void initState() {
    _initControllers();
    super.initState();
  }

  ///controller has changed
  void didUpdateWidget(AlphabetHeaderSliverView<T> oldWidget) {
    if (oldWidget.controller != widget.controller) {
      ///remove former listener and add current
      oldWidget.controller._headerScrollToProvider = null;
      widget.controller._headerScrollToProvider = _provider;
    }
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  void dispose() {
    UpdateFrameTool.instance.removeFrameListener(_frameUpdateListener);
    widget.controller._headerScrollToProvider = null;
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickHeader) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _buildListView(),
          AlphabetHeaderListViewStickView(
            key: _headerKey,
            stickOffsetController: _headerController,
            scrollCurrentOffset: widget.padding?.top ?? 0,
            groupBuilder: widget.groupBuilder,
            dataList: widget.dataList,
            indexPrefix: _uniqueStr,
          ),
        ],
      );
    } else {
      return _buildListView();
    }
  }

  ///build list view
  Widget _buildListView() {
    return NotificationListener(
      onNotification: (notification) {
        _refreshGroupAndOffset();
        return false;
      },
      child: CustomScrollView(
        key: _scrollKey,
        controller: widget.controller._scrollController,
        physics: widget.physics,
        cacheExtent: widget.cacheExtent,
        dragStartBehavior: widget.dragStartBehavior,
        semanticChildCount: widget.semanticChildCount,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        slivers: [
          SliverToBoxAdapter(
            child: widget.headerView,
          ),
          SliverList.builder(
            itemCount: AlphabetIndexTool.getItemIndexCount(widget.dataList),
            findChildIndexCallback: widget.findChildIndexCallback,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
            itemBuilder: (context, index) {
              Widget indexItem;
              if (AlphabetIndexTool.isItemIndexGroup(widget.dataList, index)) {
                int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(
                    widget.dataList, index);
                indexItem = widget.groupBuilder(
                  widget.dataList[groupIndex].tag,
                  groupIndex,
                );
              } else {
                int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(
                    widget.dataList, index);
                int childIndex = AlphabetIndexTool.getItemIndexChildPos(
                    widget.dataList, index);
                AlphabetIndexGroup<T> group = widget.dataList[groupIndex];
                indexItem = widget.childBuilder(
                  group.dataList[childIndex],
                  groupIndex,
                  childIndex,
                );
              }
              return AutoScrollTag(
                index: index,
                key: ValueKey(_uniqueStr + "." + index.toString()),
                controller: widget.controller._scrollController,
                child: indexItem,
              );
            },
          ),
          SliverToBoxAdapter(
            child: widget.footerView,
          ),
        ],
      ),
    );
  }

  ///refresh top stick
  void _refreshGroupPositions() {
    ///always calculate the header height
    if (widget.instabilityHeaderHeight) {
      ///get list render box
      RenderBox? listRenderBox =
          _scrollKey.currentContext?.findRenderObject() as RenderBox?;
      Offset? listOffset = listRenderBox?.localToGlobal(const Offset(0.0, 0.0));
      if (listOffset == null) {
        return;
      }

      ///calculate group positions
      for (int s = 0; s < widget.dataList.length; s++) {
        ///get item data
        int groupIndex =
            AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, s);
        AutoScrollTagState<AutoScrollTag>? data =
            widget.controller._scrollController.tagMap[groupIndex];
        RenderBox? itemBox = data?.context.findRenderObject() as RenderBox?;
        Offset? itemTopOffset = itemBox?.localToGlobal(Offset(0.0, 0.0));

        ///calculate data
        if (itemTopOffset != null) {
          double scrollOffset = itemTopOffset.dy -
              listOffset.dy +
              widget.controller._scrollController.position.pixels;
          _groupPositionList[s] =
              GroupPosition(scrollOffset, scrollOffset + itemBox!.size.height);
        }
      }
    } else {
      ///get list render box
      RenderBox? listRenderBox =
          _scrollKey.currentContext?.findRenderObject() as RenderBox?;
      Offset? listOffset = listRenderBox?.localToGlobal(const Offset(0.0, 0.0));
      if (listOffset == null) {
        return;
      }

      ///calculate group positions
      bool allCalculated = true;
      for (int s = 0; s < widget.dataList.length; s++) {
        if (_groupPositionList[s] == null) {
          allCalculated = false;
        }
      }
      if (allCalculated) {
        return;
      }

      ///calculate group positions
      for (int s = 0; s < widget.dataList.length; s++) {
        ///has calculated ,continue
        if (_groupPositionList[s] != null) {
          continue;
        }

        ///get item data
        int groupIndex =
            AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, s);
        AutoScrollTagState<AutoScrollTag>? data =
            widget.controller._scrollController.tagMap[groupIndex];
        RenderBox? itemBox = data?.context.findRenderObject() as RenderBox?;
        Offset? itemTopOffset = itemBox?.localToGlobal(Offset(0.0, 0.0));

        ///calculate data
        if (itemTopOffset != null) {
          double scrollOffset = itemTopOffset.dy -
              listOffset.dy +
              widget.controller._scrollController.position.pixels;
          _groupPositionList[s] =
              GroupPosition(scrollOffset, scrollOffset + itemBox!.size.height);
        }
      }
    }
  }

  ///refresh
  void _refreshGroupAndOffset() {
    ///get pixels
    double scrollOffset = widget.controller.scrollController.position.pixels;

    ///current offset
    double currentOffset = 0;

    /// current group
    int currentIndex = -1;
    for (int s = 0; s < widget.dataList.length; s++) {
      //calculated offset
      GroupPosition? positionFormer = _groupPositionList[s - 1];
      GroupPosition? positionCurrent = _groupPositionList[s];
      if (positionFormer != null && positionCurrent != null) {
        double offsetStart =
            positionCurrent.startPosition - positionFormer.height;
        double offsetEnd = positionCurrent.startPosition;
        if (scrollOffset > offsetStart && scrollOffset < offsetEnd) {
          currentOffset = scrollOffset - offsetStart;
          break;
        }
      }
      //calculated current group index
      if (positionCurrent != null) {
        if (scrollOffset >= positionCurrent.startPosition) {
          currentIndex = s;
        }
        if (scrollOffset < positionCurrent.startPosition) {
          break;
        }
      }
    }

    ///group index changed
    if (_headerController.currentGroup != currentIndex &&
        widget.onGroupSelected != null &&
        currentIndex != -1) {
      widget.onGroupSelected!(currentIndex);
    }

    ///current offset
    if (currentOffset == 0) {
      _headerController.setCurrentGroup(
        currentIndex,
        currentOffset,
      );
    } else {
      _headerController.setCurrentGroup(
        currentIndex,
        currentOffset,
      );
    }
  }
}
