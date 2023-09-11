///Your list ,maybe a string list
List<String> dataList = List.from({"Alpha","Beta","Gama","Hello","World"});

///generated to list of AlphabetIndexGroup , return your data string which to generate the fist letter tag.
List<AlphabetIndexGroup<String>> generatedList = AlphabetIndexTool.analyzeData(dataList,(data)=>data);

///build your list view
return AlphabetIndexListView(
      stickHeader: true,
      dataList: _groupContactList,
      //sideBarAlphabet: kDefaultAlphabets,
      groupBuilder: (String tag, int groupIndex) {
        return _buildHeaderItem(tag);
      },
      childBuilder: (MemberModel data, int groupIndex, int childIndex) {
        return _buildListsItem(data);
      },
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
);


