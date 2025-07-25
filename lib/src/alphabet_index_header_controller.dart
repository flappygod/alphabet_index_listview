import 'package:alphabet_index_listview/alphabet_index_listview.dart';
import 'package:flutter/cupertino.dart';
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

  ///scroll key
  GlobalKey _scrollKey = GlobalKey();

  ///group key
  GlobalKey _groupKey = GlobalKey();

  ///header key
  final GlobalKey _headerKey = GlobalKey();

  ///footer key
  final GlobalKey _footerKey = GlobalKey();

  GlobalKey get groupKey => _groupKey;

  GlobalKey get scrollKey => _scrollKey;

  GlobalKey get headerKey => _headerKey;

  GlobalKey get footerKey => _footerKey;

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

  ///reinit list view controller to fix bugs when data changed
  ///在某些情况下，因为数据发生改变可能导致滚动位置变化而造成stickView出现不正常的情况，可以调用这个方法修复
  void rebuildListViewController() {
    _scrollKey = GlobalKey();
    _groupKey = GlobalKey();
    AnchorScrollController anchorScrollController = AnchorScrollController(
      initialScrollOffset: listViewController.position.pixels,
    );
    listViewController.getListeners().forEach((listener) {
      anchorScrollController.addListener(listener);
    });
    _listViewController = anchorScrollController;
  }
}
