import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'alphabet_index_header.dart';
import 'alphabet_index_base.dart';
import 'alphabet_index_tool.dart';

typedef AlphabetHeaderScrollToProvider = int Function(int group, {int child});

///group list view controller
class AlphabetHeaderSliverViewController<T> {
  ///scroll controller
  final AutoScrollController _scrollController;

  ///get scroll controller
  AutoScrollController get scrollController => _scrollController;

  ///provider
  AlphabetHeaderScrollToProvider? _headerScrollToProvider;

  ///create list view controller
  AlphabetHeaderSliverViewController({
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
class AlphabetHeaderSliverView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderSliverViewController<T> controller;

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

  const AlphabetHeaderSliverView({
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
    return _AlphabetHeaderSliverViewState<T>();
  }
}

///group list view state
class _AlphabetHeaderSliverViewState<T> extends State<AlphabetHeaderSliverView<T>> {
  //unique str
  final String _uniqueStr = "alphabet_index_list_view_stick_header_index_prefix";

  //scroll key
  final GlobalKey _scrollKey = GlobalKey();

  //data update listener
  late AlphabetHeaderScrollToProvider _provider;

  ///init state
  void initState() {
    _provider = (int group, {int? child}) {
      if (child == null) {
        return AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, group);
      } else {
        return AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, group) + child + 1;
      }
    };
    assert(
      widget.controller._headerScrollToProvider == null,
      "Don't set controller for multi listviews",
    );
    widget.controller._headerScrollToProvider = _provider;
    super.initState();
  }

  ///controller has changed
  void didUpdateWidget(AlphabetHeaderSliverView<T> oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._headerScrollToProvider = null;
      widget.controller._headerScrollToProvider = _provider;
    }
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  void dispose() {
    widget.controller._headerScrollToProvider = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stickHeader) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _buildListView(),
          RepaintBoundary(
            child: AlphabetIndexHeader(
              scrollCurrentOffset: widget.padding?.top ?? 0,
              scrollController: widget.controller._scrollController,
              listviewKey: _scrollKey,
              groupBuilder: widget.groupBuilder,
              dataList: widget.dataList,
              indexPrefix: _uniqueStr,
            ),
          ),
        ],
      );
    } else {
      return _buildListView();
    }
  }

  ///build list view
  Widget _buildListView() {
    return CustomScrollView(
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
        SliverList.builder(
          itemCount: AlphabetIndexTool.getItemIndexCount(widget.dataList),
          findChildIndexCallback: widget.findChildIndexCallback,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          itemBuilder: (context, index) {
            Widget indexItem;
            if (AlphabetIndexTool.isItemIndexGroup(widget.dataList, index)) {
              int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(widget.dataList, index);
              AlphabetIndexGroup<T> group = widget.dataList[groupIndex];
              indexItem = widget.groupBuilder(group.tag, groupIndex);
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
      ],
    );
  }
}
