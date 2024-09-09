import 'package:lpinyin/lpinyin.dart';

import 'alphabet_index_base.dart';

///index bar name provider
typedef AlphabetIndexNameProvider<T> = String Function(T data);

///index bar tool
class AlphabetIndexTool {
  ///analyze data to IndexBarGroup list
  static List<AlphabetIndexGroup<T>> analyzeData<T>(
    List<T> dataList,
    AlphabetIndexNameProvider<T> provider, {
    String unknownAlphabet = "#",
  }) {
    ///get all alphabets
    List<String> alphabets = [];
    for (T member in dataList) {
      String alphabet = PinyinHelper.getFirstWordPinyin(provider(member));
      if (alphabet.isNotEmpty) {
        alphabet = alphabet.substring(0, 1).toUpperCase();
      } else {
        alphabet = unknownAlphabet;
      }
      if (!alphabets.contains(alphabet)) {
        alphabets.add(alphabet);
      }
    }

    ///sort alphabets
    alphabets.sort((String one, String two) {
      return one.codeUnitAt(0) > two.codeUnitAt(0) ? 1 : -1;
    });

    ///alphabets to IndexBarGroup list
    return alphabets.map((e) {
      List<T> retList = [];
      for (T member in dataList) {
        String alphabet = PinyinHelper.getFirstWordPinyin(provider(member));
        if (alphabet.isNotEmpty) {
          alphabet = alphabet.substring(0, 1).toUpperCase();
        } else {
          alphabet = unknownAlphabet;
        }
        if (alphabet == e) {
          retList.add(member);
        }
      }
      AlphabetIndexGroup<T> group = AlphabetIndexGroup<T>(
        tag: e,
        dataList: retList,
      );
      return group;
    }).toList();
  }

  ///get item count
  static int getItemIndexCount(List<AlphabetIndexGroup> dataList) {
    int count = 0;
    for (AlphabetIndexGroup group in dataList) {
      count = count + group.dataList.length + 1;
    }
    return count;
  }

  ///check is index group
  static bool isItemIndexGroup(List<AlphabetIndexGroup> dataList, int index) {
    int count = 0;
    if (index == 0) {
      return true;
    }
    for (AlphabetIndexGroup group in dataList) {
      count = count + group.dataList.length + 1;
      if (index == count) {
        return true;
      }
    }
    return false;
  }

  ///get group index
  static int getItemIndexGroupPos(
      List<AlphabetIndexGroup> dataList, int index) {
    int count = 0;
    int groupIndex = 0;
    for (AlphabetIndexGroup group in dataList) {
      count = count + group.dataList.length + 1;
      if (index < count) {
        return groupIndex;
      }
      groupIndex++;
    }
    return groupIndex;
  }

  ///get child index
  static int getItemIndexChildPos(
      List<AlphabetIndexGroup> dataList, int index) {
    int count = 0;
    for (AlphabetIndexGroup group in dataList) {
      count = count + group.dataList.length + 1;
      if (index < count) {
        return group.dataList.length - count + index;
      }
    }
    return 0;
  }

  ///get index for group
  static int getItemIndexFromGroupPos(
      List<AlphabetIndexGroup> dataList, int group) {
    int count = 0;
    for (int s = 0; s < dataList.length && s < group; s++) {
      count = count + dataList[s].dataList.length + 1;
    }
    return count;
  }

  ///total group count
  static int getItemTotalGroupCount(List<AlphabetIndexGroup> dataList) {
    return dataList.length;
  }

  ///total child count
  static int getItemTotalChildCount(List<AlphabetIndexGroup> dataList) {
    int count = 0;
    for (int s = 0; s < dataList.length; s++) {
      count = count + dataList[s].dataList.length;
    }
    return count;
  }
}
