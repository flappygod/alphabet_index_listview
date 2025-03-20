import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'alphabet_index_tip_side_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///index bar list view
class AlphabetIndexListView<T> extends StatefulWidget {
  //controller
  final AlphabetHeaderViewController<T> controller;

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
  //side bar enable
  final bool indexSideBarEnable;

  final Curve? curve;
  final Duration? duration;

  //index bar list view
  const AlphabetIndexListView({
    super.key,
    required this.controller,
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
    this.indexSideBarEnable = true,
    this.curve,
    this.duration,
  });

  @override
  State<StatefulWidget> createState() {
    return _AlphabetIndexListViewState<T>();
  }
}

///index bar list view
class _AlphabetIndexListViewState<T> extends State<AlphabetIndexListView<T>> {
  ///tips bar controller
  final AlphabetIndexTipBarController _indexTipBarController =
      AlphabetIndexTipBarController();

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
        _buildSideTipsBar(),
      ],
    );
  }

  ///build list view
  Widget _buildListView() {
    return AlphabetHeaderListView<T>(
      onGroupSelected: widget.onGroupSelected,
      stickHeader: widget.stickHeader,
      dataList: widget.dataList,
      controller: widget.controller,
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

  ///build side tips bar
  Widget _buildSideTipsBar() {
    if (widget.indexSideBarEnable) {
      return AlphabetIndexTipSideBar(
        sideBarAlphabet: widget.sideBarAlphabet ??
            widget.dataList.map((e) => e.tag).toList(),
        controller: widget.controller,
        sideBarAlign: widget.sideBarAlign,
        sideBarBuilder: widget.sideBarBuilder,
        tipsBarAlign: widget.tipsBarAlign,
        tipsBuilder: widget.tipsBuilder,
        curve: widget.curve,
        duration: widget.duration,
      );
    } else {
      return const SizedBox();
    }
  }
}
