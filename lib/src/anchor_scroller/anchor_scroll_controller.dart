library anchor_scroll_controller;

import 'package:flutter/widgets.dart';
import 'anchor_scroll_wrapper.dart';

/// Anchor scroll controller
class AnchorScrollController extends ScrollController {
  /// 存储当前视口中项目状态的映射
  final Map<int, AnchorItemWrapperState> _itemMap = {};

  /// 存储监听器列表
  final List<VoidCallback> _listeners = [];

  AnchorScrollController({
    double? pinOffset,
    super.initialScrollOffset,
    super.debugLabel,
    super.keepScrollOffset,
  });

  /// 添加项目
  void addItem(int index, AnchorItemWrapperState state) {
    _itemMap[index] = state;
  }

  /// 移除项目
  void removeItem(int index, AnchorItemWrapperState state) {
    if (_itemMap[index] == state) {
      _itemMap.remove(index);
    }
  }

  /// 获取项目映射
  Map<int, AnchorItemWrapperState> get itemMap {
    return _itemMap;
  }

  /// 添加监听器
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除监听器
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listeners.remove(listener);
  }

  /// 获取当前所有监听器
  List<VoidCallback> getListeners() {
    return List.unmodifiable(_listeners);
  }
}
