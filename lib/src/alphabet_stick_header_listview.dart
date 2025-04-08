import '../alphabet_index_listview.dart';
import 'anchor_scroller/anchor_scroll_wrapper.dart';
import 'alphabet_stick_header_stick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

///group list view
class AlphabetHeaderListView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderViewController<T> controller;

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
  GlobalKey _scrollKey = GlobalKey();

  ///header key
  GlobalKey _groupKey = GlobalKey();

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
        return _scrollKey.currentContext?.size?.height ?? 0;
      },

      ///provide header height
      provideHeightHeaderViewFunc: () {
        return 0;
      },

      ///provide footer height
      provideHeightFooterViewFunc: () {
        return 0;
      },

      ///provide top padding
      provideHeightTopPaddingFunc: () {
        return widget.padding?.top ?? 0;
      },

      ///provide bottom padding
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

  ///init state
  void initState() {
    _initControllers();
    super.initState();
  }

  ///controller has changed
  void didUpdateWidget(AlphabetHeaderListView<T> oldWidget) {
    ///remove former listener and add current
    if (oldWidget.controller != widget.controller) {
      widget.controller.headerProvider = _headerProvider;
    }
    if (widget.stickHeader) {
      _scrollKey = GlobalKey();
      _groupKey = GlobalKey();
      AnchorScrollController anchorScrollController = AnchorScrollController(
        initialScrollOffset:
            oldWidget.controller.listViewController.position.pixels,
      );
      oldWidget.controller.listViewController
          .getListeners()
          .forEach((listener) {
        anchorScrollController.addListener(listener);
      });
      widget.controller.listViewController = anchorScrollController;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupPositionList.clear();
      _refreshGroupPositions();
      _refreshGroupAndOffset();
    });
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
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
            key: _groupKey,
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _refreshGroupAndOffset();
        return false;
      },
      child: ListView.builder(
        key: _scrollKey,
        controller: widget.controller.listViewController,
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
            controller: widget.controller.listViewController,
            child: indexItem,
          );
        },
      ),
    );
  }

  ///get the list view render box
  Offset? _getListViewOffset() {
    ///get list render box
    RenderBox? listRenderBox =
        _scrollKey.currentContext?.findRenderObject() as RenderBox?;
    return listRenderBox?.localToGlobal(const Offset(0.0, 0.0));
  }

  ///get the group item offset
  Rect? _getGroupItemRect(int index, double listViewHeight) {
    ///get item data
    int groupIndex =
        AlphabetIndexTool.getItemIndexFromGroupPos(widget.dataList, index);
    AnchorItemWrapperState? data =
        widget.controller.listViewController.itemMap[groupIndex];
    RenderBox? itemBox = data?.context.findRenderObject() as RenderBox?;
    Offset? offset = itemBox?.localToGlobal(Offset(0.0, 0.0));
    if (offset != null && itemBox != null) {
      return Rect.fromLTWH(
        offset.dx,
        offset.dy -
            listViewHeight +
            widget.controller.listViewController.position.pixels,
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
    ///get pixels
    double scrollOffset = widget.controller.listViewController.position.pixels;

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
