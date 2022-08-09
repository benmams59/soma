import 'package:flutter/material.dart';
import 'package:soma/screens/profile_screen.dart';
import 'package:soma/utils/helpers/helpers.dart' as helpers;

class CategoryFragment extends StatefulWidget {
  CategoryFragment({Key key}) : super(key: key);

  @override
  _CategoryFragmentState createState() => _CategoryFragmentState();
}

class _CategoryFragmentState extends State<CategoryFragment> {
  int _filter = 0;
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 15, bottom: 5),
              alignment: Alignment.centerRight,
              child: DropdownButton(
                onChanged: (v) => setState(() => _filter = v),
                value: _filter,
                icon: Icon(Icons.filter_list),
                items: [
                  DropdownMenuItem(
                    child: Text("Fiction to Non Fiction"),
                    value: 0,
                  ),
                  DropdownMenuItem(
                    child: Text("Non Fiction to Fiction"),
                    value: 1,
                  )
                ],
              ),
            ),
            Column(
              verticalDirection: _filter == 0 ? VerticalDirection.down : VerticalDirection.up,
              children: [
                CustomListView(
                  title: "Fiction",
                  children: helpers.categories["fiction"].map((fiction) => ListTile(
                    onTap: () => {},
                    title: Text(fiction),
                    trailing: Icon(Icons.navigate_next),
                  )).toList(),
                ),
                SizedBox(height: 40,),
                CustomListView(
                  title: "Non Fiction",
                  children: helpers.categories["non-fiction"].map((nFiction) => ListTile(
                    onTap: () => {},
                    title: Text(nFiction),
                    trailing: Icon(Icons.navigate_next),
                  )).toList(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}