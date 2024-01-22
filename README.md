<p>///Your list ,maybe a string list.</p>

<p>List<String> dataList = List.from({"Alpha","Beta","Gama","Hello","World"});</p>

<p>///generated AlphabetIndexGroup list, return your data string which used to get the fist letter tag.</p>

<p>List<AlphabetIndexGroup<String>> generatedList = AlphabetIndexTool.analyzeData(dataList,(data)=>data);</p>

<p>///build your list view.</p>

<p>return AlphabetIndexListView(<br />
 stickHeader: true,<br />
 dataList: _groupContactList,<br />
 //sideBarAlphabet: kDefaultAlphabets,<br />
 groupBuilder: (String tag, int groupIndex) {<br />
 return _buildHeaderItem(tag);<br />
 },<br />
 childBuilder: (MemberModel data, int groupIndex, int childIndex) {<br />
 return _buildListsItem(data);<br />
 },<br />
 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),<br />
);</p>

<p>
</p>