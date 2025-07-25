import '../alphabet_index_listview.dart';
import 'anchor_scroller/anchor_scroll_wrapper.dart';
import 'alphabet_stick_header_stick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///group list view
class AlphabetHeaderSliverView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderViewController<T> controller;

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

  ///provider
  late AlphabetHeaderProviderInterface _headerProvider;

  ///frame update callback
  late VoidCallback _frameUpdateListener;

  ///header controller
  final AlphabetHeaderListViewGroupController _headerController =
      AlphabetHeaderListViewGroupController();

  ///calculated group position list
  Map<int, GroupPosition> _groupPositionList = {};

  ///init controllers
  void _initControllers() {
    ///set index provider for controller to known which index to jumpc
    _headerProvider = AlphabetHeaderProvider(
      ///index provider
      provideIndexFunc: (int group, {int? child}) {
        if (child == null) {
          return AlphabetIndexTool.getItemIndexFromGroupPos(
              widget.dataList, group);
        } else {
          return AlphabetIndexTool.getItemIndexFromGroupPos(
                  widget.dataList, group) +
              child;
        }
      },

      ///total group count
      provideIndexTotalGroupFunc: () {
        return AlphabetIndexTool.getItemTotalGroupCount(widget.dataList);
      },

      ///total child count
      provideIndexTotalChildFunc: () {
        return AlphabetIndexTool.getItemTotalChildCount(widget.dataList);
      },

      ///provide total list height
      provideHeightTotalListFunc: () {
        return widget.controller.scrollKey.currentContext?.size?.height ?? 0;
      },

      ///provide header height
      provideHeightHeaderViewFunc: () {
        return _getHeaderHeight();
      },

      ///provide footer height
      provideHeightFooterViewFunc: () {
        return _getFooterHeight();
      },

      ///provide padding
      provideHeightTopPaddingFunc: () {
        return widget.padding?.top ?? 0;
      },
      provideHeightBottomPaddingFunc: () {
        return widget.padding?.bottom ?? 0;
      },
    );
    widget.controller.headerProvider = _headerProvider;

    ///update frame and calculate all groups position if need
    _frameUpdateListener = () {
      _refreshGroupPositions();
    };
    UpdateFrameTool.instance.addFrameListener(_frameUpdateListener);
  }

  double _getHeaderHeight() {
    return widget.controller.headerKey.currentContext?.size?.height ?? 0;
  }

  double _getFooterHeight() {
    return widget.controller.footerKey.currentContext?.size?.height ?? 0;
  }

  ///init state
  @override
  void initState() {
    _initControllers();
    super.initState();
  }

  ///controller has changed
  @override
  void didUpdateWidget(AlphabetHeaderSliverView<T> oldWidget) {
    ///remove former listener and add current
    if (oldWidget.controller != widget.controller) {
      widget.controller.headerProvider = _headerProvider;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupPositionList.clear();
      _refreshGroupPositions();
      _refreshGroupAndOffset();
    });
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  @override
  void dispose() {
    UpdateFrameTool.instance.removeFrameListener(_frameUpdateListener);
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
            key: widget.controller.groupKey,
            stickOffsetController: _headerController,
            groupBuilder: widget.groupBuilder,
            dataList: widget.dataList,
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
        key: widget.controller.scrollKey,
        controller: widget.controller.listViewController,
        physics: widget.physics,
        cacheExtent: widget.cacheExtent,
        dragStartBehavior: widget.dragStartBehavior,
        semanticChildCount: widget.semanticChildCount,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        slivers: [
          SliverPadding(
            padding: widget.padding != null
                ? EdgeInsets.fromLTRB(widget.padding!.left, widget.padding!.top,
                    widget.padding!.right, 0)
                : EdgeInsets.zero,
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                key: widget.controller.headerKey,
                child: widget.headerView,
              ),
            ),
          ),
          SliverPadding(
            padding: widget.padding != null
                ? EdgeInsets.fromLTRB(
                    widget.padding!.left, 0, widget.padding!.right, 0)
                : EdgeInsets.zero,
            sliver: SliverList.builder(
              itemCount: AlphabetIndexTool.getItemIndexCount(widget.dataList),
              findChildIndexCallback: widget.findChildIndexCallback,
              addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
              addRepaintBoundaries: widget.addRepaintBoundaries,
              addSemanticIndexes: widget.addSemanticIndexes,
              itemBuilder: (context, index) {
                Widget indexItem;
                if (AlphabetIndexTool.isItemIndexGroup(
                    widget.dataList, index)) {
                  int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(
                      widget.dataList, index);
                  indexItem = widget.groupBuilder(
                    groupIndex,
                    widget.dataList[groupIndex].tag,
                  );
                } else {
                  int groupIndex = AlphabetIndexTool.getItemIndexGroupPos(
                      widget.dataList, index);
                  int childIndex = AlphabetIndexTool.getItemIndexChildPos(
                      widget.dataList, index);
                  AlphabetIndexGroup<T> group = widget.dataList[groupIndex];
                  indexItem = widget.childBuilder(
                    groupIndex,
                    childIndex,
                    group.dataList[childIndex],
                  );
                }
                return AnchorItemWrapper(
                  index: index,
                  key: ValueKey("$_uniqueStr.$index"),
                  controller: widget.controller.listviewController,
                  child: indexItem,
                );
              },
            ),
          ),
          SliverPadding(
            padding: widget.padding != null
                ? EdgeInsets.fromLTRB(widget.padding!.left, 0,
                    widget.padding!.right, widget.padding!.bottom)
                : EdgeInsets.zero,
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                key: widget.controller.footerKey,
                child: widget.footerView,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///get the list view render box
  Offset? _getListViewOffset() {
    ///get list render box
    RenderBox? listRenderBox = widget.controller.scrollKey.currentContext
        ?.findRenderObject() as RenderBox?;
    return listRenderBox?.localToGlobal(const Offset(0.0, 0.0));
  }

  ///get the group item offset
  Rect? _getGroupItemRect(int index, double listViewHeight) {
    ///get item data
    int groupIndex =
        AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, index);
    AnchorItemWrapperState? data =
        widget.controller.listviewController.itemMap[groupIndex];

    RenderBox? itemBox = data?.context.findRenderObject() as RenderBox?;
    Offset? offset = itemBox?.localToGlobal(const Offset(0.0, 0.0));
    if (offset != null && itemBox != null) {
      return Rect.fromLTWH(
        offset.dx,
        offset.dy -
            listViewHeight +
            widget.controller.listviewController.position.pixels,
        itemBox.size.width,
        itemBox.size.height,
      );
    } else {
      return null;
    }
  }

  ///get the group item prefer offset
  Rect? _getGroupItemPreferRect(int index) {
    if (widget.controller.preferGroupHeight != null &&
        widget.controller.preferChildHeight != null) {
      ///calculate prefer height offset
      double top = index * widget.controller.preferGroupHeight! +
          (AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, index) -
                  index) *
              widget.controller.preferChildHeight!;

      ///offset
      double offset = (widget.padding?.top ?? 0);

      return Rect.fromLTWH(
        0,
        top + offset,
        MediaQuery.of(context).size.width,
        widget.controller.preferGroupHeight!,
      );
    }
    return null;
  }

  ///refresh top stick
  void _refreshGroupPositions() {
    //get list render box
    Offset? listOffset = _getListViewOffset();
    if (listOffset == null) {
      return;
    }

    //get the actual rect on screen
    Map<int, GroupPosition> actualMap = {};
    for (int s = 0; s < widget.dataList.length; s++) {
      Rect? itemGroupRect = _getGroupItemRect(s, listOffset.dy);
      if (itemGroupRect != null) {
        double scrollOffset = itemGroupRect.top;
        actualMap[s] = GroupPosition(
          scrollOffset,
          scrollOffset + itemGroupRect.size.height,
        );
      }
    }

    //if we set the prefer child height and prefer group height, just calculate all offsets
    if (widget.controller.preferChildHeight != null &&
        widget.controller.preferGroupHeight != null) {
      Map<int, GroupPosition> preferMap = {};
      for (int s = 0; s < widget.dataList.length; s++) {
        Rect? itemGroupRect = _getGroupItemPreferRect(s);
        if (itemGroupRect != null) {
          double scrollOffset = itemGroupRect.top;
          preferMap[s] = GroupPosition(
            scrollOffset,
            scrollOffset + itemGroupRect.size.height,
          );
        }
      }
      //calculate the offset actual and prefer
      if (actualMap.isNotEmpty) {
        int key = actualMap.keys.first;
        double offset = (preferMap[key]?.startPosition ?? 0) -
            (actualMap[key]?.startPosition ?? 0);
        //if they are the same
        if (offset == 0) {
          _groupPositionList = preferMap;
        }
        //correct to the actual display offset
        else {
          for (int key in preferMap.keys) {
            preferMap[key] = GroupPosition(
                preferMap[key]!.startPosition - offset,
                preferMap[key]!.endPosition - offset);
          }
          _groupPositionList = preferMap;
        }
      } else {
        _groupPositionList = preferMap;
      }
    } else {
      _groupPositionList.addAll(actualMap);
    }
  }

  ///refresh
  void _refreshGroupAndOffset() {
    if (!widget.controller.listviewController.hasClients) {
      return;
    }

    ///get pixels
    double scrollOffset = widget.controller.listviewController.position.pixels;

    ///current offset
    double currentOffset = 0;

    /// current group
    int currentIndex = -1;
    for (int s = 0; s < widget.dataList.length; s++) {
      ///calculated offset
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

      ///calculated current group index
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
    _headerController.setCurrentGroup(
      currentIndex,
      currentOffset,
    );
  }
}
