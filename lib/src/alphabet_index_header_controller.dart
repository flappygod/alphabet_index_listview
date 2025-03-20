import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/material.dart';
import 'dart:math';

///group list view controller
class AlphabetHeaderViewController<T> {
  ///anchor scroll controller controller
  final AnchorScrollController _listViewController;

  ///get scroll controller
  AnchorScrollController get listviewController => _listViewController;

  ///index provider
  AlphabetHeaderProviderInterface? _headerProvider;

  ///prefer group widget height
  final double? _preferGroupHeight;

  ///prefer child widget height
  final double? _preferChildHeight;

  ///scroll speed
  final Duration _indexedScrollDuration;
  final Curve _indexedScrollCurve;

  ///create list view controller
  AlphabetHeaderViewController({
    double? preferGroupHeight,
    double? preferChildHeight,
    Duration? indexedScrollDuration,
    Curve? indexedScrollCurve,
    required AnchorScrollController listViewController,
  })  : _preferGroupHeight = preferGroupHeight,
        _preferChildHeight = preferChildHeight,
        _indexedScrollDuration =
            (preferGroupHeight != null && preferChildHeight != null)
                ? Duration.zero
                : (indexedScrollDuration ?? const Duration(milliseconds: 50)),
        _indexedScrollCurve = indexedScrollCurve ?? Curves.linear,
        _listViewController = listViewController;

  ///scroll to group
  Future scrollToGroup(int groupIndex) async {
    if (_headerProvider == null) {
      return;
    }

    ///get group index
    int index = _headerProvider!.provideIndex(groupIndex);

    ///if group height prefer set
    if (_preferGroupHeight != null &&
        _preferGroupHeight != 0 &&
        _preferChildHeight != null &&
        _preferChildHeight != 0) {
      ///get group index
      double maxHeight =
          _headerProvider!.provideIndexTotalGroup() * _preferGroupHeight! +
              _headerProvider!.provideIndexTotalChild() * _preferChildHeight! +
              _headerProvider!.provideHeightHeaderView() +
              _headerProvider!.provideHeightFooterView() +
              _headerProvider!.provideHeightTopPadding() +
              _headerProvider!.provideHeightBottomPadding() -
              _headerProvider!.provideHeightTotalList();
      double height = groupIndex * _preferGroupHeight! +
          (index - groupIndex) * _preferChildHeight! +
          _headerProvider!.provideHeightHeaderView() +
          _headerProvider!.provideHeightTopPadding();
      listviewController.jumpTo(min(height, max(maxHeight, 0)));
    }

    ///if group height prefer not set
    else {
      await listviewController.scrollToIndex(
        index: index,
        duration: _indexedScrollDuration,
        curve: _indexedScrollCurve,
      );
    }
  }

  ///scroll to child
  Future scrollToChild(
    int groupIndex,
    int childIndex, {
    Duration duration = Duration.zero,
    Curve curve = Curves.linear,
  }) async {
    ///childIndex == 0 ,just scroll to group
    if (childIndex == 0) {
      return scrollToGroup(groupIndex);
    }

    ///get index
    int index = _headerProvider!.provideIndex(groupIndex, child: childIndex);

    ///if group height prefer set
    if (_preferGroupHeight != null &&
        _preferGroupHeight != 0 &&
        _preferChildHeight != null &&
        _preferChildHeight != 0 &&
        duration == Duration.zero) {
      ///get total index
      double maxHeight =
          _headerProvider!.provideIndexTotalGroup() * _preferGroupHeight! +
              _headerProvider!.provideIndexTotalChild() * _preferChildHeight! -
              _headerProvider!.provideHeightTotalList() +
              _headerProvider!.provideHeightHeaderView() +
              _headerProvider!.provideHeightFooterView() +
              _headerProvider!.provideHeightTopPadding() +
              _headerProvider!.provideHeightBottomPadding();
      double height = groupIndex * _preferGroupHeight! +
          (index - groupIndex) * _preferChildHeight! +
          _headerProvider!.provideHeightHeaderView() +
          _headerProvider!.provideHeightTopPadding();
      listviewController.jumpTo(min(height, max(maxHeight, 0)));
    }

    ///if group height prefer not set
    else {
      double anchorOffset = _headerProvider!.provideHeightGroup(groupIndex);
      await listviewController.scrollToIndex(
        index: index,
        duration: duration,
        curve: curve,
        anchorOffset: anchorOffset,
      );
    }
  }
}
