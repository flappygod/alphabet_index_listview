import 'anchor_scroller/anchor_scroll_controller.dart';
import 'anchor_scroller/anchor_scroll_wrapper.dart';
import 'alphabet_stick_header_stick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'alphabet_index_base.dart';
import 'alphabet_index_tool.dart';
import 'dart:async';

///group list view controller
class AlphabetHeaderListViewController<T> {
  ///scroll controller
  final AnchorScrollController _scrollController;

  ///get scroll controller
  AnchorScrollController get scrollController => _scrollController;

  ///header scroll index provider
  AlphabetHeaderScrollToProvider? _headerScrollToProvider;

  ///header height provider
  AlphabetHeaderHeightProvider? _headerHeightProvider;

  ///create list view controller
  AlphabetHeaderListViewController({
    AnchorScrollController? scrollController,
  }) : _scrollController = scrollController ?? AnchorScrollController();

  ///scroll to group
  Future scrollToGroup(
    int groupIndex, {
    double scrollSpeed = 4,
    Curve curve = Curves.linear,
  }) async {
    if (_headerScrollToProvider != null) {
      int index = _headerScrollToProvider!(groupIndex);
      await _scrollController.scrollToIndex(
        index: index,
        scrollSpeed: scrollSpeed,
        curve: curve,
      );
    }
  }

  ///scroll to child
  Future<void> scrollToChild(
    int groupIndex,
    int childIndex, {
    double scrollSpeed = 4,
    Curve curve = Curves.linear,
  }) async {
    ///childIndex == 0 ,just scroll to group
    if (childIndex == 0) {
      return scrollToGroup(groupIndex);
    }

    ///childIndex != 0 and _headerScrollToProvider is set
    if (_headerScrollToProvider != null) {
      int index = _headerScrollToProvider!(groupIndex, child: childIndex);
      double deltaOffset = (_headerHeightProvider != null)
          ? _headerHeightProvider!(groupIndex)
          : 0;
      await _scrollController.scrollToIndex(
        index: index,
        scrollSpeed: scrollSpeed,
        curve: curve,
        deltaOffset: -deltaOffset,
      );
    }
  }
}

///group list view
class AlphabetHeaderListView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderListViewController<T> controller;

  //group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  //child builder
  final AlphabetIndexChildBuilder<T> childBuilder;

  //data list
  final List<AlphabetIndexGroup<T>> dataList;

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
  final bool instabilityHeaderHeight;

  const AlphabetHeaderListView({
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
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderListViewState<T>();
  }
}

///group list view state
class _AlphabetHeaderListViewState<T> extends State<AlphabetHeaderListView<T>> {
  ///unique str
  final String _uniqueStr =
      "alphabet_index_list_view_stick_header_index_prefix";

  ///scroll key
  final GlobalKey _scrollKey = GlobalKey();

  ///data update listener
  late AlphabetHeaderScrollToProvider _provider;

  ///height provider
  late AlphabetHeaderHeightProvider _heightProvider;

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

    ///set height provider for controller to jump to child index with group height offset
    _heightProvider = (int group) {
      GroupPosition? groupPosition = _groupPositionList[group];
      if (groupPosition != null) {
        return groupPosition.endPosition - groupPosition.startPosition;
      }

      GroupPosition? firstOne = _groupPositionList[0];
      if (firstOne != null) {
        return firstOne.endPosition - firstOne.startPosition;
      }

      return _headerKey.currentContext?.size?.height ?? 0;
    };
    widget.controller._headerHeightProvider = _heightProvider;

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
  void didUpdateWidget(AlphabetHeaderListView<T> oldWidget) {
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _refreshGroupAndOffset();
        return false;
      },
      child: ListView.builder(
        key: _scrollKey,
        controller: widget.controller._scrollController,
        itemCount: AlphabetIndexTool.getItemIndexCount(widget.dataList),
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
        itemBuilder: (context, index) {
          Widget indexItem;
          if (AlphabetIndexTool.isItemIndexGroup(widget.dataList, index)) {
            int groupIndex =
                AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, index);
            indexItem = widget.groupBuilder(
              groupIndex,
              widget.dataList[groupIndex].tag,
            );
          } else {
            int groupIndex =
                AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, index);
            int childIndex =
                AlphabetIndexTool.getItemIndexChildPos(widget.dataList, index);
            AlphabetIndexGroup<T> group = widget.dataList[groupIndex];
            indexItem = widget.childBuilder(
              groupIndex,
              childIndex,
              group.dataList[childIndex],
            );
          }
          return AnchorItemWrapper(
            index: index,
            key: ValueKey(_uniqueStr + "." + index.toString()),
            controller: widget.controller.scrollController,
            child: indexItem,
          );
        },
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
        AnchorItemWrapperState? data =
            widget.controller._scrollController.itemMap[groupIndex];
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
        AnchorItemWrapperState? data =
            widget.controller._scrollController.itemMap[groupIndex];
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
