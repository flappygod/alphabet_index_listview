import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'anchor_scroll_controller.dart';

/// 包装器小部件，用于帮助获取项目的偏移量
/// 如果项目的大小是固定的，则无需将小部件包装到项目中
class AnchorItemWrapper extends StatefulWidget {
  AnchorItemWrapper({
    required this.index,
    required this.child,
    this.controller,
    this.scrollViewWrapper,
    Key? key,
  })  : assert(
          controller != null || scrollViewWrapper != null,
          "必须有 AnchorScrollController 或 AnchorScrollViewWrapper",
        ),
        super(key: key ?? ValueKey(index));

  //可选的 AnchorScrollController
  final AnchorScrollController? controller;

  //项目的索引
  final int index;

  //子小部件
  final Widget child;

  //可选的 AnchorScrollViewWrapper
  final AnchorScrollViewWrapper? scrollViewWrapper;

  @override
  AnchorItemWrapperState createState() => AnchorItemWrapperState();
}

class AnchorItemWrapperState extends State<AnchorItemWrapper> {
  @override
  void initState() {
    super.initState();
    //添加项目到控制器或包装器
    _addItem(widget.index);
  }

  @override
  void dispose() {
    //从控制器或包装器中移除项目
    _removeItem(widget.index);
    super.dispose();
  }

  @override
  void didUpdateWidget(AnchorItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    //如果索引或键发生变化，更新项目
    if (oldWidget.index != widget.index || oldWidget.key != widget.key) {
      _removeItem(oldWidget.index);
      _addItem(widget.index);
    }
  }

  //添加项目到控制器或包装器
  void _addItem(int index) {
    if (widget.controller != null) {
      widget.controller!.addItem(index, this);
    } else if (widget.scrollViewWrapper != null) {
      widget.scrollViewWrapper!.addItem(index, this);
    }
  }

  //从控制器或包装器中移除项目
  void _removeItem(int index) {
    if (widget.controller != null) {
      widget.controller!.removeItem(index);
    } else if (widget.scrollViewWrapper != null) {
      widget.scrollViewWrapper!.removeItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    //返回子小部件
    return widget.child;
  }
}

class AnchorScrollViewWrapper extends InheritedWidget {
  AnchorScrollViewWrapper({
    required this.controller,
    required super.child,
    this.anchorOffset = 0,
    this.fixedItemSize,
    this.onIndexChanged,
    double? pinGroupTitleOffset,
    super.key,
  }) {
    //初始化帮助类
    _helper = AnchorScrollControllerHelper(
      scrollController: controller,
      fixedItemSize: fixedItemSize,
      onIndexChanged: onIndexChanged,
      anchorOffsetAll: anchorOffset,
      pinGroupTitleOffset: pinGroupTitleOffset,
    );
    //初始化滚动监听器
    _scrollListener = () {
      _helper.notifyIndexChanged();
    };
  }

  //滚动控制器
  final ScrollController controller;

  //锚点偏移量
  final double anchorOffset;

  //固定的项目大小
  final double? fixedItemSize;

  //索引更改时的回调
  final IndexChanged? onIndexChanged;

  //帮助类实例
  late final AnchorScrollControllerHelper _helper;

  //滚动监听器
  late final VoidCallback _scrollListener;

  //添加项目
  void addItem(int index, AnchorItemWrapperState state) {
    _helper.addItem(index, state);
  }

  //移除项目
  void removeItem(int index) {
    _helper.removeItem(index);
  }

  //添加索引监听器
  void addIndexListener(IndexChanged indexListener) {
    _helper.addIndexListener(indexListener);
  }

  //移除索引监听器
  void removeIndexListener(IndexChanged indexListener) {
    _helper.removeIndexListener(indexListener);
  }

  //获取当前上下文的 AnchorScrollViewWrapper 实例
  static AnchorScrollViewWrapper? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AnchorScrollViewWrapper>();
  }

  @override
  bool updateShouldNotify(AnchorScrollViewWrapper oldWidget) {
    //移除旧的滚动监听器
    oldWidget._removeScrollListener();
    //添加新的滚动监听器
    _addScrollListener();
    return false;
  }

  @override
  InheritedElement createElement() {
    //添加滚动监听器
    _addScrollListener();
    return super.createElement();
  }

  //添加滚动监听器
  void _addScrollListener() {
    controller.addListener(_scrollListener);
  }

  //移除滚动监听器
  void _removeScrollListener() {
    controller.removeListener(_scrollListener);
  }

  //滚动到指定索引
  Future<void> scrollToIndex({
    required int index,
    double scrollSpeed = 4,
    Curve curve = Curves.linear,
    double anchorOffset = 0,
  }) async {
    _helper.scrollToIndex(
      index: index,
      scrollSpeed: scrollSpeed,
      curve: curve,
      anchorOffset: anchorOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ScrollController>(
        'controller',
        controller,
        ifNull: '无控制器',
        showName: false,
      ),
    );
  }
}
