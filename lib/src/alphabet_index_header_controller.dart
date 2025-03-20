import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/animation.dart';
import 'dart:math';

///group list view controller
class AlphabetHeaderViewController<T> {
  ///anchor scroll controller controller
  AnchorScrollController _listViewController = AnchorScrollController();

  ///get scroll controller
  AnchorScrollController get listviewController => _listViewController;

  ///index provider
  AlphabetHeaderProviderInterface? _headerProvider;

  ///prefer group widget height
  final double _preferGroupHeight;

  ///prefer child widget height
  final double _preferChildHeight;

  ///create list view controller
  AlphabetHeaderViewController({
    required double groupHeight,
    required double childHeight,
  })  : _preferGroupHeight = groupHeight,
        _preferChildHeight = childHeight;

  ///scroll to group
  Future scrollToGroup(
    int groupIndex, {
    Curve? curve,
    Duration? duration,
  }) async {
    if (_headerProvider == null) {
      return;
    }

    ///get group index
    int index = _headerProvider!.provideIndex(groupIndex);

    ///if group height prefer set
    if (_preferGroupHeight != 0 && _preferChildHeight != 0) {
      ///get group index
      double maxHeight =
          _headerProvider!.provideIndexTotalGroup() * _preferGroupHeight +
              _headerProvider!.provideIndexTotalChild() * _preferChildHeight +
              _headerProvider!.provideHeightHeaderView() +
              _headerProvider!.provideHeightFooterView() +
              _headerProvider!.provideHeightTopPadding() +
              _headerProvider!.provideHeightBottomPadding() -
              _headerProvider!.provideHeightTotalList();
      double height = groupIndex * _preferGroupHeight +
          (index - groupIndex) * _preferChildHeight +
          _headerProvider!.provideHeightHeaderView() +
          _headerProvider!.provideHeightTopPadding();
      if (curve != null && duration != null) {
        await listviewController.animateTo(
          min(height, max(maxHeight, 0)),
          curve: curve,
          duration: duration,
        );
      } else {
        listviewController.jumpTo(
          min(height, max(maxHeight, 0)),
        );
      }
    }
  }

  ///scroll to child
  Future scrollToChild(
    int groupIndex,
    int childIndex, {
    Curve? curve,
    Duration? duration,
  }) async {
    ///childIndex == 0 ,just scroll to group
    if (childIndex == 0) {
      return scrollToGroup(groupIndex);
    }

    ///get index
    int index = _headerProvider!.provideIndex(groupIndex, child: childIndex);

    ///if group height prefer set
    if (_preferGroupHeight != 0 && _preferChildHeight != 0) {
      ///get total index
      double maxHeight =
          _headerProvider!.provideIndexTotalGroup() * _preferGroupHeight +
              _headerProvider!.provideIndexTotalChild() * _preferChildHeight -
              _headerProvider!.provideHeightTotalList() +
              _headerProvider!.provideHeightHeaderView() +
              _headerProvider!.provideHeightFooterView() +
              _headerProvider!.provideHeightTopPadding() +
              _headerProvider!.provideHeightBottomPadding();
      double height = groupIndex * _preferGroupHeight +
          (index - groupIndex) * _preferChildHeight +
          _headerProvider!.provideHeightHeaderView() +
          _headerProvider!.provideHeightTopPadding();

      if (curve != null && duration != null) {
        await listviewController.animateTo(
          min(height, max(maxHeight, 0)),
          curve: curve,
          duration: duration,
        );
      } else {
        listviewController.jumpTo(min(height, max(maxHeight, 0)));
      }
    }
  }

  ///set header provider
  set headerProvider(AlphabetHeaderProviderInterface? value) {
    _headerProvider = value;
  }

  set listViewController(AnchorScrollController value) {
    _listViewController = value;
  }

  AnchorScrollController get listViewController => _listViewController;

  double? get preferChildHeight => _preferChildHeight;

  double? get preferGroupHeight => _preferGroupHeight;
}
