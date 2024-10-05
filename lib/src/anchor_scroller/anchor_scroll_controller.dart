library anchor_scroll_controller;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'anchor_scroll_wrapper.dart';
import 'dart:async';
import 'dart:math';

typedef IndexChanged = void Function(int index, bool userScroll);

class AnchorScrollControllerHelper {
  AnchorScrollControllerHelper({
    required this.scrollController,
    this.fixedItemSize,
    this.onIndexChanged,
    this.anchorOffsetAll,
    this.pinGroupTitleOffset,
  });

  /// [ScrollView] 的 [ScrollController]
  final ScrollController scrollController;

  /// 固定的项目大小
  /// 如果 [ScrollView] 垂直滚动，它应该是项目的固定高度
  /// 如果 [ScrollView] 水平滚动，它应该是项目的固定宽度
  final double? fixedItemSize;

  /// 应用于每个项目顶部的偏移量
  final double? anchorOffsetAll;

  /// 用于计算当前索引的偏移量
  final double? pinGroupTitleOffset;

  /// 通过 [addIndexListener] 添加的索引监听器列表
  final List<IndexChanged> indexListeners = [];

  /// 每次用户滚动到某个元素时调用
  void addIndexListener(IndexChanged indexListener) {
    indexListeners.add(indexListener);
  }

  void removeIndexListener(IndexChanged indexListener) {
    indexListeners.remove(indexListener);
  }

  /// 存储当前视口中项目状态的映射
  final Map<int, AnchorItemWrapperState> _itemMap = {};

  Map<int, AnchorItemWrapperState> get itemMap {
    return _itemMap;
  }

  void addItem(int index, AnchorItemWrapperState state) {
    _itemMap[index] = state;
  }

  void removeItem(int index) {
    _itemMap.remove(index);
  }

  /// 当前索引
  int _currIndex = 0;

  int get currIndex => _currIndex;

  /// 当前索引更改时的回调
  final IndexChanged? onIndexChanged;

  double _lastOffset = 0;

  void notifyIndexChanged() {
    // 如果滚动行为是由用户触发的，通知索引更改
    if (scrollController.hasClients && scrollController.offset >= scrollController.position.minScrollExtent) {
      if (scrollController.offset < scrollController.position.maxScrollExtent ||
          (scrollController.offset == scrollController.position.maxScrollExtent &&
              _lastOffset < scrollController.position.maxScrollExtent)) {
        final index = _getCurrIndex();
        if (index != _currIndex) {
          _currIndex = index;
          onIndexChanged?.call(
            _currIndex,
            scrollController.position.userScrollDirection != ScrollDirection.idle,
          );
          for (var indexListener in indexListeners) {
            indexListener.call(
              _currIndex,
              scrollController.position.userScrollDirection != ScrollDirection.idle,
            );
          }
        }
      }
    }

    if (scrollController.offset >= scrollController.position.minScrollExtent &&
        scrollController.offset <= scrollController.position.maxScrollExtent) {
      _lastOffset = scrollController.offset;
    }
  }

  int _getCurrIndex() {
    int? tmpIndex;
    for (final index in _itemMap.keys.toList()) {
      final RevealedOffset? revealedOffset = _getOffsetToReveal(index);
      if (revealedOffset == null) {
        continue;
      }

      final double totalOffset = _applyAnchorOffset(revealedOffset.offset);
      if (totalOffset <= scrollController.offset && totalOffset + revealedOffset.rect.height > scrollController.offset) {
        tmpIndex = index;
        break;
      }
    }

    // 当前滚动偏移没有项目，这种情况只发生在支持固定的 ScrollView 中。
    // 在这种情况下，我们需要找到一个满足其偏移量加上其高度
    // 小于当前滚动偏移量且当前滚动偏移量
    // 小于下一个项目的偏移量的项目
    if (tmpIndex == null) {
      int index = _currIndex;
      RevealedOffset? revealedOffset = _getOffsetToReveal(index);
      while (revealedOffset != null) {
        if (scrollController.offset > revealedOffset.offset + revealedOffset.rect.height) {
          RevealedOffset? nextRevealedOffset = _getOffsetToReveal(index + 1);
          if (nextRevealedOffset != null) {
            if (scrollController.offset < nextRevealedOffset.offset) {
              break;
            } else {
              index++;
              revealedOffset = _getOffsetToReveal(index);
            }
          } else {
            break;
          }
        } else {
          RevealedOffset? preRevealedOffset = _getOffsetToReveal(index - 1);
          if (preRevealedOffset != null) {
            index--;
            if (scrollController.offset > preRevealedOffset.offset + preRevealedOffset.rect.height) {
              break;
            } else {
              revealedOffset = _getOffsetToReveal(index);
            }
          } else {
            break;
          }
        }
      }

      tmpIndex = index;
    }

    if (pinGroupTitleOffset != null) {
      final nextIndex = tmpIndex + 1;
      if (_itemMap.containsKey(nextIndex)) {
        final RevealedOffset? revealedOffset = _getOffsetToReveal(nextIndex);
        if (revealedOffset != null && (revealedOffset.offset - pinGroupTitleOffset!) < scrollController.offset) {
          tmpIndex = nextIndex;
        }
      }
    }
    return tmpIndex;
  }

  /// 当前是否正在滚动到某个索引
  bool _isScrollingToIndex = false;

  /// 滚动到指定索引
  ///
  /// @param controller: ScrollView 的 ScrollController
  /// @param index: 要滚动到的目标索引项目
  /// @param scrollSpeed: 滚动速度，单位为偏移量/毫秒
  /// @param curve: 滚动动画
  Future<void> scrollToIndex({
    required int index,
    double scrollSpeed = 4,
    Curve curve = Curves.linear,
    double anchorOffset = 0,
  }) async {
    assert(scrollSpeed > 0);

    if (!scrollController.hasClients) {
      return;
    }

    // 如果当前正在滚动到某个索引，停止它并
    // 然后首先计算当前索引
    if (_isScrollingToIndex) {
      _isScrollingToIndex = false;
      // 尚未找到中断滚动的 API。
      // 根据 [ScrollPosition.animateTo] 的描述，
      // 动画将在用户尝试手动滚动时中断，
      // 或者在启动另一个活动时中断，或者在启动另一个活动时中断，
      // 或者在动画到达视口边缘并尝试过度滚动时中断。
      // 因此，创建一个新的滚动行为以停止上一个。
      // 也许有更好的方法来做到这一点。
       await scrollController.animateTo(
        _applyAnchorOffset(scrollController.offset),
        duration: const Duration(milliseconds: 1),
        curve: curve,
      );
      _currIndex = _getCurrIndex();
    }

    _isScrollingToIndex = true;

    if (fixedItemSize != null) {
      // 如果项目大小是固定的，目标偏移量是 index * fixedItemSize
      final targetOffset = _applyAnchorOffset(index * fixedItemSize!) - anchorOffset;
      final int scrollTime = ((scrollController.offset - targetOffset).abs() / scrollSpeed).round();
      final Duration duration = Duration(milliseconds: scrollTime);
      await scrollController.animateTo(targetOffset, duration: duration, curve: curve);
    } else {
      // 如果项目大小不是固定的，需要考虑两种情况。
      // 1. 如果目标索引项目已经在视口中，我们可以直接获取目标偏移量
      // 2. 如果目标索引项目不在视口中，我们应该滚动到视口中的第一个或最后一个项目。
      //    然后我们将在视口中获得一些更接近目标项目的项目。
      //    重复上述步骤，直到目标项目在视口中，然后我们可以获取其偏移量并滚动到它。
      if (_itemMap.containsKey(index)) {
        await _animateToIndexInViewport(
          index,
          scrollSpeed,
          curve,
          anchorOffset: anchorOffset,
        );
        int lastIndex = _currIndex;
        while (_currIndex != index) {
          await _animateToIndexInViewport(
            index,
            scrollSpeed,
            curve,
            anchorOffset: anchorOffset,
          );

          if (_currIndex == lastIndex) {
            break;
          }
          lastIndex = _currIndex;

          if (!_isScrollingToIndex) {
            // 此滚动被中断
            return;
          }
        }
      } else {
        int tmpIndex = _currIndex;
        while (!_itemMap.containsKey(index)) {
          final sortedKeys = _itemMap.keys.toList()..sort((first, second) => first.compareTo(second));
          final targetIndex = (tmpIndex < index) ? sortedKeys.last : sortedKeys.first;
          if (targetIndex == tmpIndex) {
            break;
          }
          tmpIndex = targetIndex;
          double alignment = (tmpIndex < index) ? 1 : 0;
          await _animateToIndexInViewport(
            tmpIndex,
            scrollSpeed,
            curve,
            alignment: alignment,
          );
          if (!_isScrollingToIndex) {
            // 此滚动被中断
            return;
          }
        }

        await _animateToIndexInViewport(
          index,
          scrollSpeed,
          curve,
          anchorOffset: anchorOffset,
        );
      }

      // 有时项目的偏移量可能会改变，例如，项目的高度在重建后改变，
      // 这使得它无法精确滚动到索引。因此，最后跳转到精确的偏移量。
      final targetScrollOffset = _getScrollOffset(index, anchorOffset: anchorOffset);
      if (targetScrollOffset != null && scrollController.offset != targetScrollOffset) {
        scrollController.jumpTo(_applyAnchorOffset(targetScrollOffset));
      }

      _currIndex = index;
      _isScrollingToIndex = false;
    }
  }

  /// 滚动到已经在视口中的索引项目
  Future<void> _animateToIndexInViewport(
    int index,
    double scrollSpeed,
    Curve curve, {
    double alignment = 0,
    double anchorOffset = 0,
  }) async {
    final double? targetOffset = _getScrollOffset(
      index,
      alignment: alignment,
      anchorOffset: anchorOffset,
    );
    if (targetOffset == null) {
      return;
    }

    final double totalOffset = _applyAnchorOffset(targetOffset);
    int scrollTime = ((scrollController.offset - totalOffset).abs() / scrollSpeed).ceil();
    scrollTime = max(scrollTime, 35);
    final Duration duration = Duration(milliseconds: scrollTime);
    await scrollController.animateTo(
      totalOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// 获取目标索引的滚动偏移量
  double? _getScrollOffset(
    int index, {
    double alignment = 0,
    double anchorOffset = 0,
  }) {
    final revealOffset = _getOffsetToReveal(index, alignment: alignment);
    if (revealOffset == null) {
      return null;
    }
    return (revealOffset.offset - anchorOffset).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent + (anchorOffsetAll ?? 0),
    );
  }

  /// 获取揭示目标索引的 [RevealedOffset]
  RevealedOffset? _getOffsetToReveal(
    int index, {
    double alignment = 0,
  }) {
    RevealedOffset? offset;

    final context = _itemMap[index]?.context;
    if (context != null) {
      final renderBox = context.findRenderObject();
      final viewport = RenderAbstractViewport.of(renderBox);
      if (renderBox != null) {
        offset = viewport.getOffsetToReveal(renderBox, alignment);
      }
    }

    return offset;
  }

  /// 应用锚点偏移到滚动偏移
  double _applyAnchorOffset(double currentOffset) => currentOffset - (anchorOffsetAll ?? 0);
}

///anchor scroll controller
class AnchorScrollController extends ScrollController {
  AnchorScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    this.onIndexChanged,
    this.fixedItemSize,
    this.anchorOffsetAll,
    double? pinOffset,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        ) {
    _helper = AnchorScrollControllerHelper(
      scrollController: this,
      fixedItemSize: fixedItemSize,
      onIndexChanged: onIndexChanged,
      anchorOffsetAll: anchorOffsetAll,
      pinGroupTitleOffset: pinOffset,
    );
  }

  // 固定的项目大小
  final double? fixedItemSize;

  // 索引更改时的回调
  final IndexChanged? onIndexChanged;

  // 锚点偏移量
  final double? anchorOffsetAll;

  // 帮助类实例
  late final AnchorScrollControllerHelper _helper;

  /// 添加索引监听器
  void addIndexListener(IndexChanged indexListener) {
    _helper.addIndexListener(indexListener);
  }

  /// 移除索引监听器
  void removeIndexListener(IndexChanged indexListener) {
    _helper.removeIndexListener(indexListener);
  }

  /// 添加项目
  void addItem(int index, AnchorItemWrapperState state) {
    _helper.addItem(index, state);
  }

  /// 移除项目
  void removeItem(int index) {
    _helper.removeItem(index);
  }

  /// 获取项目映射
  Map<int, AnchorItemWrapperState> get itemMap {
    return _helper.itemMap;
  }

  @override
  void notifyListeners() {
    // 通知索引更改
    _helper.notifyIndexChanged();
    // 调用父类的通知方法
    super.notifyListeners();
  }

  /// 滚动到指定索引
  Future<void> scrollToIndex({
    required int index,
    double scrollSpeed = 4,
    Curve curve = Curves.linear,
    double anchorOffset = 0,
  }) async {
    await _helper.scrollToIndex(
      index: index,
      scrollSpeed: max(scrollSpeed, 1),
      curve: curve,
      anchorOffset: anchorOffset,
    );
  }
}
