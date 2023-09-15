
import 'package:flutter/material.dart';

///observe height listener
typedef ObserveHeightListener = Function(Size height);

///Observe widget height
class ObserveWidget extends StatefulWidget {
  //child
  final Widget child;

  //listener
  final ObserveHeightListener listener;

  const ObserveWidget({
    Key? key,
    required this.listener,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ObserveWidgetState();
  }
}

class _ObserveWidgetState extends State<ObserveWidget> {
  //globalKey
  final GlobalKey _globalKey = GlobalKey();

  //size
  Size? size;

  //addPostFrameCallback
  void _setListener() {
    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_globalKey.currentContext?.size != null &&
          (_globalKey.currentContext?.size?.width != size?.width || _globalKey.currentContext?.size?.height != size?.height)) {
        size = _globalKey.currentContext?.size;
        widget.listener(_globalKey.currentContext!.size!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _setListener();
    return Offstage(
      child: SizedBox(
        key: _globalKey,
        child: widget.child,
      ),
    );
  }
}