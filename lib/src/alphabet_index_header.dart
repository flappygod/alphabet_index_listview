import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/cupertino.dart';
import 'alphabet_index_base.dart';
import 'alphabet_index_tool.dart';

///index tips bar
class AlphabetIndexHeader<T> extends StatefulWidget {
  ///scroll controller
  final AutoScrollController scrollController;

  ///group builder
  final AlphabetIndexGroupBuilder groupBuilder;

  ///listview key
  final GlobalKey listviewKey;

  ///tags list
  final List<AlphabetIndexGroup<T>> dataList;

  ///prefix index
  final String? indexPrefix;

  ///current offset
  final double scrollCurrentOffset;

  const AlphabetIndexHeader({
    super.key,
    required this.scrollController,
    required this.groupBuilder,
    required this.listviewKey,
    required this.dataList,
    this.scrollCurrentOffset = 0,
    this.indexPrefix,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexHeaderState<T>();
  }
}

///tips bar state
class _AlphabetIndexHeaderState<T> extends State<AlphabetIndexHeader<T>> {
  ///listener
  late VoidCallback _listener;

  //header key
  GlobalKey _headerKey = GlobalKey();

  //scroll index
  int _scrollCurrentIndex = 0;

  //current offset
  double _scrollCurrentOffset = 0;

  ///init state
  void initState() {
    _scrollCurrentOffset = widget.scrollCurrentOffset;
    _listener = () async {
      _refreshTopBar();
      await Future.delayed(Duration(milliseconds: 20));
      _refreshTopBar();
    };
    widget.scrollController.addListener(_listener);
    super.initState();
  }

  ///update to reset listener
  void didUpdateWidget(AlphabetIndexHeader<T> oldWidget) {
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_listener);
      widget.scrollController.addListener(_listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  ///dispose
  void dispose() {
    widget.scrollController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollCurrentIndex == -1 && widget.dataList.isNotEmpty) {
      return const SizedBox();
    }
    return ClipRect(
      key: _headerKey,
      clipBehavior: Clip.hardEdge,
      child: Transform.translate(
        offset: Offset(0, _scrollCurrentOffset),
        child: widget.groupBuilder(
          widget.dataList.map((e) => e.tag).toList()[_scrollCurrentIndex],
          _scrollCurrentIndex,
        ),
      ),
    );
  }

  ///refresh top bar
  void _refreshTopBar() {
    ///get list render box
    RenderBox? listRenderBox = widget.listviewKey.currentContext?.findRenderObject() as RenderBox?;
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
      AutoScrollTagState<AutoScrollTag>? data = widget.scrollController.tagMap[key];
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

    ///set flag
    bool flagOne = _setScrollCurrentIndex(scrollIndex ?? -1);
    bool flagTwo = _setScrollOffset(scrollOffset ?? 0, headerRenderBoxHeight);
    if (flagOne || flagTwo) {
      setState(() {});
    }
  }

  ///set scroll offset
  bool _setScrollOffset(double scrollOffset, double headerRenderBoxHeight) {
    ///set scroll offset
    if (scrollOffset < -headerRenderBoxHeight) {
      scrollOffset = 0;
    }
    if (scrollOffset > 0) {
      scrollOffset = 0;
    }
    if (_scrollCurrentOffset != scrollOffset) {
      _scrollCurrentOffset = scrollOffset;
      return true;
    }
    return false;
  }

  ///set current index
  bool _setScrollCurrentIndex(int index) {
    if (_scrollCurrentIndex != index) {
      _scrollCurrentIndex = index;
      return true;
    }
    return false;
  }
}
