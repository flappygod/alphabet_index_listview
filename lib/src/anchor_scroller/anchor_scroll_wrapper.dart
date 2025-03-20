import 'package:flutter/material.dart';
import 'anchor_scroll_controller.dart';

/// 包装器小部件，用于帮助获取项目的偏移量
/// 如果项目的大小是固定的，则无需将小部件包装到项目中
class AnchorItemWrapper extends StatefulWidget {
  AnchorItemWrapper({
    required this.index,
    required this.child,
    required this.controller,
    Key? key,
  }) : super(key: key ?? ValueKey(index));

  //可选的 AnchorScrollController
  final AnchorScrollController? controller;

  //项目的索引
  final int index;

  //子小部件
  final Widget child;

  @override
  AnchorItemWrapperState createState() => AnchorItemWrapperState();
}

class AnchorItemWrapperState extends State<AnchorItemWrapper> {
  @override
  void initState() {
    super.initState();
    _addItem(widget.index);
  }

  @override
  void dispose() {
    _removeItem(widget.index);
    super.dispose();
  }

  @override
  void didUpdateWidget(AnchorItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.key != widget.key) {
      _removeItem(oldWidget.index);
      _addItem(widget.index);
    }
  }

  void _addItem(int index) {
    if (widget.controller != null) {
      widget.controller!.addItem(index, this);
    }
  }

  void _removeItem(int index) {
    if (widget.controller != null) {
      widget.controller!.removeItem(index, this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
