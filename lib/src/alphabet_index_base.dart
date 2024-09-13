import 'package:flutter/material.dart';

///Default Index data.
const List<String> kDefaultAlphabets = const [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

///group scrolled
typedef AlphabetIndexGroupScrolled = Function(int groupIndex);

///provider  interface
abstract class AlphabetHeaderProviderInterface {
  ///index provider
  int provideIndex(int group, {int? child});

  ///total index provider
  int provideIndexTotalGroup();

  ///total index provider
  int provideIndexTotalChild();

  ///height provider
  double provideHeightGroup(int group);

  ///total height provider
  double provideHeightTotalList();

  ///total height header view
  double provideHeightHeaderView();

  ///provider top padding
  double provideHeightTopPadding();
}

///provider
class AlphabetHeaderProvider implements AlphabetHeaderProviderInterface {
  final int Function(int group, {int? child}) provideIndexFunc;
  final int Function() provideIndexTotalGroupFunc;
  final int Function() provideIndexTotalChildFunc;
  final double Function(int group) providerHeightGroupFunc;
  final double Function() providerHeightTotalListFunc;
  final double Function() provideHeightHeaderViewFunc;
  final double Function() provideHeightTopPaddingFunc;

  AlphabetHeaderProvider({
    required this.provideIndexFunc,
    required this.provideIndexTotalGroupFunc,
    required this.provideIndexTotalChildFunc,
    required this.providerHeightGroupFunc,
    required this.providerHeightTotalListFunc,
    required this.provideHeightHeaderViewFunc,
    required this.provideHeightTopPaddingFunc,
  });

  @override
  int provideIndex(int group, {int? child}) {
    return provideIndexFunc(group, child: child);
  }

  @override
  int provideIndexTotalGroup() {
    return provideIndexTotalGroupFunc();
  }

  @override
  int provideIndexTotalChild() {
    return provideIndexTotalChildFunc();
  }

  @override
  double provideHeightGroup(int group) {
    return providerHeightGroupFunc(group);
  }

  @override
  double provideHeightTotalList() {
    return providerHeightTotalListFunc();
  }

  @override
  double provideHeightHeaderView() {
    throw provideHeightHeaderViewFunc();
  }

  @override
  double provideHeightTopPadding() {
    return provideHeightTopPaddingFunc();
  }
}

///none bar
AlphabetIndexGroupBuilder kTipsBarNone = (int groupIndex, String tag) {
  return const SizedBox();
};

///none bar
AlphabetIndexGroupBuilder kTipsBarDefault = (int groupIndex, String tag) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black.withAlpha(50),
      borderRadius: BorderRadius.circular(16),
    ),
    width: 65,
    height: 65,
    alignment: Alignment.center,
    child: Text(
      tag,
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
    ),
  );
};

///align
enum AlphabetIndexSideAlign {
  left,
  right,
}

///align
enum AlphabetIndexTipsAlign {
  center,
  leftFollowSideBar,
  centerFollowSideBar,
  rightFollowSideBar,
}

///group data list
class AlphabetIndexGroup<T> {
  ///this is data list
  List<T> dataList;

  ///this is tag
  String tag;

  AlphabetIndexGroup({
    this.dataList = const [],
    required this.tag,
  });
}

///group position
class GroupPosition {
  double _startPosition = 0;

  double _endPosition = 0;

  double get startPosition => _startPosition;

  double get endPosition => _endPosition;

  double get height {
    return _endPosition - _startPosition;
  }

  GroupPosition(
    double startPosition,
    double endPosition,
  ) {
    _startPosition = double.parse(startPosition.toStringAsFixed(1));
    _endPosition = double.parse(endPosition.toStringAsFixed(1));
  }
}

///index bar group builder
typedef AlphabetIndexGroupBuilder = Widget Function(int groupIndex, String tag);

///index bar group builder
typedef AlphabetIndexChildBuilder<T> = Widget Function(
    int groupIndex, int childIndex, T data);

///index bar group builder
typedef AlphabetIndexSideBuilder = Widget Function(String tag, bool selected);
