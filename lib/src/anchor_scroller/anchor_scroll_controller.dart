library anchor_scroll_controller;

import 'package:flutter/widgets.dart';
import 'anchor_scroll_wrapper.dart';

///anchor scroll controller
class AnchorScrollController extends ScrollController {
  /// 存储当前视口中项目状态的映射
  final Map<int, AnchorItemWrapperState> _itemMap = {};

  AnchorScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    double? pinOffset,
  });

  ///添加项目
  void addItem(int index, AnchorItemWrapperState state) {
    _itemMap[index] = state;
  }

  ///移除项目
  void removeItem(int index, AnchorItemWrapperState state) {
    if (_itemMap[index] == state) {
      _itemMap.remove(index);
    }
  }

  ///获取项目映射
  Map<int, AnchorItemWrapperState> get itemMap {
    return _itemMap;
  }
}
