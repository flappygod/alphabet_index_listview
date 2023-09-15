import 'package:scroll_to_index/scroll_to_index.dart';
import 'alphabet_stick_header_stick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'alphabet_index_base.dart';
import 'alphabet_index_tool.dart';

typedef AlphabetHeaderScrollToProvider = int Function(int group, {int child});

///group list view controller
class AlphabetHeaderListViewController<T> {
  ///scroll controller
  final AutoScrollController _scrollController;

  ///get scroll controller
  AutoScrollController get scrollController => _scrollController;

  ///provider
  AlphabetHeaderScrollToProvider? _headerScrollToProvider;

  ///create list view controller
  AlphabetHeaderListViewController({
    AutoScrollController? scrollController,
  }) : _scrollController = scrollController ?? AutoScrollController();

  ///scroll to group
  void scrollToGroup(
    int groupIndex, {
    Duration? scrollAnimationDuration,
    AutoScrollPosition? preferPosition,
  }) {
    if (_headerScrollToProvider != null) {
      int index = _headerScrollToProvider!(groupIndex);
      _scrollController.scrollToIndex(
        index,
        duration: scrollAnimationDuration ?? Duration(milliseconds: 20),
        preferPosition: preferPosition ?? AutoScrollPosition.begin,
      );
    }
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
class AlphabetHeaderListView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderListViewController<T> controller;

  //group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  //child builder
  final AlphabetIndexChildBuilder<T> childBuilder;

  //data list
  final List<AlphabetIndexGroup<T>> dataList;

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

  const AlphabetHeaderListView({
    super.key,
    required this.dataList,
    required this.controller,
    required this.groupBuilder,
    required this.childBuilder,
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
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetHeaderListViewState<T>();
  }
}

///group list view state
class _AlphabetHeaderListViewState<T> extends State<AlphabetHeaderListView<T>> {
  ///unique str
  final String _uniqueStr = "alphabet_index_list_view_stick_header_index_prefix";

  ///scroll key
  final GlobalKey _scrollKey = GlobalKey();

  ///data update listener
  late AlphabetHeaderScrollToProvider _provider;

  ///header controller
  final AlphabetHeaderListViewGroupController _headerController = AlphabetHeaderListViewGroupController();

  ///header key
  final GlobalKey _headerKey = GlobalKey();

  ///init state
  void initState() {
    _provider = (int group, {int? child}) {
      if (child == null) {
        return AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, group);
      } else {
        return AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, group) + child + 1;
      }
    };
    widget.controller._headerScrollToProvider = _provider;
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
        _refreshTopBar();
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
            int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, index);
            indexItem = AlphabetHeaderListViewOffsetView(
              dataList: widget.dataList,
              controller: _headerController,
              groupIndex: groupIndex,
              builder: widget.groupBuilder,
            );
          } else {
            int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, index);
            int childIndex = AlphabetIndexTool.getItemIndexChildPos(widget.dataList, index);
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
    );
  }

  ///refresh top bar
  void _refreshTopBar() {
    ///get list render box
    RenderBox? listRenderBox = _scrollKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? listOffset = listRenderBox?.localToGlobal(const Offset(0.0, 0.0));
    if (listOffset == null) {
      return;
    }

    ///get total count
    int totalCount = AlphabetIndexTool.getItemIndexCount(widget.dataList);

    ///scroll offset default zero
    double? scrollOffset;
    int? scrollIndex;
    RenderBox? headerRenderBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    double? headerRenderBoxHeight = headerRenderBox?.size.height ?? 0;

    ///check for all
    for (int key = 0; key < totalCount; key++) {
      ///get item data
      AutoScrollTagState<AutoScrollTag>? data = widget.controller._scrollController.tagMap[key];
      RenderBox? itemBox = data?.context.findRenderObject() as RenderBox?;

      ///get offset top and bottom
      Offset? itemTopOffset = itemBox?.localToGlobal(Offset(0.0, 0.0));
      Offset? itemBottomOffset = itemTopOffset != null ? Offset(itemTopOffset.dx, itemTopOffset.dy + itemBox!.size.height) : null;

      ///calculate current scroll index
      if (key == 0 && itemTopOffset != null && itemTopOffset.dy - listOffset.dy > 0) {
        scrollIndex = -1;
      }
      if (itemBottomOffset != null && itemBottomOffset.dy - listOffset.dy > 0 && scrollIndex == null) {
        scrollIndex = AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, key);
      }

      ///calculate offset if any item must offset
      if (itemTopOffset != null &&
          headerRenderBoxHeight != 0 &&
          itemTopOffset.dy - listOffset.dy > 0 &&
          itemTopOffset.dy - listOffset.dy < headerRenderBoxHeight) {
        if (AlphabetIndexTool.isItemIndexGroup(widget.dataList, key) && scrollOffset == null) {
          scrollOffset = itemTopOffset.dy - listOffset.dy - headerRenderBoxHeight;
        }
      }

      ///scrollIndex had set and scroll over
      if (itemTopOffset != null && itemTopOffset.dy - listOffset.dy > headerRenderBoxHeight && scrollIndex != null) {
        break;
      }
    }

    ///scroll and set current state
    int currentIndex = scrollIndex ?? -1;
    double currentOffset = scrollOffset ?? 0;
    if (currentOffset < -headerRenderBoxHeight || currentOffset > 0) {
      currentOffset = 0;
    }

    ///current offset
    if (currentOffset == 0) {
      _headerController.setCurrentGroup(
        currentIndex,
        false,
      );
    } else {
      _headerController.setCurrentGroup(
        currentIndex,
        true,
      );
    }
  }
}
