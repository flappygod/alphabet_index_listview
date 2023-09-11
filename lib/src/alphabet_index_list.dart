import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'alphabet_index_sidebar.dart';

///Default Index data.
const List<String> kDefaultAlphabets = const [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

///none bar
AlphabetIndexGroupBuilder kTipsBarNone = (String tag, int groupIndex) {
  return const SizedBox();
};

///none bar
AlphabetIndexGroupBuilder kTipsBarDefault = (String tag, int groupIndex) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black.withAlpha(50),
      borderRadius: BorderRadius.circular(16),
    ),
    width: 65,
    height: 65,
    alignment: Alignment.center,
    child: Text(
      tag,
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
    ),
  );
};

///align
enum AlphabetIndexSideAlign {
  left,
  right,
}

///align
enum AlphabetIndexTipsAlign {
  center,
  leftFollowSideBar,
  centerFollowSideBar,
  rightFollowSideBar,
}

///group data list
class AlphabetIndexGroup<T> {
  ///this is data list
  List<T> dataList;

  ///this is tag
  String tag;

  AlphabetIndexGroup({
    this.dataList = const [],
    required this.tag,
  });
}

///index bar list view
class AlphabetIndexListView<T> extends StatefulWidget {
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

  //header view
  final Widget? headerView;

  //header view tag
  final String? headerViewTag;

  //alphabet list
  final List<String>? sideBarAlphabet;

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

  //index bar list view
  const AlphabetIndexListView({
    super.key,
    this.headerView,
    this.headerViewTag,
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
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexListViewState<T>();
  }
}

///index bar group builder
typedef AlphabetIndexGroupBuilder = Widget Function(String tag, int groupIndex);

///index bar group builder
typedef AlphabetIndexChildBuilder<T> = Widget Function(T data, int groupIndex, int childIndex);

///index bar group builder
typedef AlphabetIndexSideBuilder = Widget Function(String tag, bool selected);

///index bar list view
class _AlphabetIndexListViewState<T> extends State<AlphabetIndexListView<T>> {
  ///head stick view controller
  late AlphabetHeaderListViewController<T> _alphabetHeaderListViewController;

  ///tips bar controller
  final AlphabetIndexTipBarController _indexTipBarController = AlphabetIndexTipBarController();

  @override
  void initState() {
    _alphabetHeaderListViewController = AlphabetHeaderListViewController();
    super.initState();
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
    List<String> sideBarTags = widget.sideBarAlphabet ?? widget.dataList.map((e) => e.tag).toList();

    ///alphabet index side bar
    return AlphabetIndexSideBar(
      sideBarTags: sideBarTags,
      sideBarAlign: widget.sideBarAlign,
      onChange: (String tag) {},
      onGestureStart: () {
        _indexTipBarController.isGesture = true;
      },
      onGestureEnd: () {
        _indexTipBarController.isGesture = false;
      },
      onPositionChange: (Size currentSize, String currentTag, int currentIndex, double offsetFromCenter) {
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
              widget.sideBarAlign == AlphabetIndexSideAlign.left ? currentSize.width : 0,
              offsetFromCenter,
            );
            break;
          case AlphabetIndexTipsAlign.rightFollowSideBar:
            _indexTipBarController.setGroup(
              currentTag,
              currentIndex,
              widget.sideBarAlign == AlphabetIndexSideAlign.right ? -currentSize.width : 0,
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
    _alphabetHeaderListViewController.scrollToGroup(groupIndex);
  }
}
