import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/models/trackerTask.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:intl/intl.dart';

class AddTrackerTask extends HookWidget {
  const AddTrackerTask({Key? key, required this.trackerChanged})
      : super(key: key);

  final trackerChanged;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
    final titleController = useTextEditingController(text: '');
    final noteController = useTextEditingController(text: '');
    final dayController = useTextEditingController();
    final rewardController = useTextEditingController();
    final _formKey = GlobalKey<FormState>();
    final isValid = useValueNotifier(false);
    final startDate = useState(DateTime.now());
    final ValueNotifier<List<Map<String, dynamic>>> milestones = useState([]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Daily Tracker"),
        centerTitle: true,
      ),
      body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          maxLength: 30,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(top: 0.0, left: 5.0),
                            labelText: "Title",
                            labelStyle:
                                CustomTheme.lightTheme.textTheme.bodyText2,
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xff35566D))),
                          ),
                          onChanged: (value) =>
                              isValid.value = value.isNotEmpty ? true : false,
                        ),
                        Divider(),
                        TextFormField(
                          controller: noteController,
                          maxLines: 5,
                          maxLength: 300,
                          decoration: InputDecoration(
                            hintText: "Personal Note",
                            contentPadding: EdgeInsets.all(10.0),
                            labelStyle:
                                CustomTheme.lightTheme.textTheme.bodyText2,
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text('Starting Date'),
                                  Ink(
                                    child: InkWell(
                                      child: StyledContainerField(
                                          child: Center(
                                              child: Text(
                                                  DateFormat('dd MMM yy')
                                                              .format(startDate
                                                                  .value) ==
                                                          DateFormat(
                                                                  'dd MMM yy')
                                                              .format(DateTime
                                                                  .now())
                                                      ? 'Today'
                                                      : '${DateFormat('dd MMM yy').format(startDate.value)}',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor)))),
                                      onTap: () {
                                        DatePicker.showDatePicker(context,
                                            currentTime: startDate.value,
                                            minTime: DateTime(
                                                DateTime.now().year - 3),
                                            maxTime: DateTime.now(),
                                            onConfirm: (value) {
                                          bool hasOverlapMilestone = false;
                                          for (var i = 0;
                                              i < milestones.value.length;
                                              i++) {
                                            if (milestones.value[i]['day'] <=
                                                DateTime.now()
                                                    .difference(value)
                                                    .inDays) {
                                              hasOverlapMilestone = true;
                                              break;
                                            }
                                          }
                                          if (hasOverlapMilestone) {
                                            StyledPopup(
                                                    children: [
                                                  Text(
                                                      'If you change the starting date, some milestones will be invalid. Do you want to automatically remove the invalid milestones?')
                                                ],
                                                    title:
                                                        'Remove Invalid Milestones?',
                                                    textButton: TextButton(
                                                        onPressed: () {
                                                          for (var i = 0;
                                                              i <
                                                                  milestones
                                                                      .value
                                                                      .length;
                                                              i++) {
                                                            if (milestones
                                                                        .value[
                                                                    i]['day'] <=
                                                                DateTime.now()
                                                                    .difference(
                                                                        value)
                                                                    .inDays) {
                                                              milestones.value
                                                                  .removeAt(i);
                                                              i--;
                                                            }
                                                          }
                                                          startDate.value =
                                                              value;
                                                          OneContext()
                                                              .popDialog();
                                                        },
                                                        child: Text('Yes')))
                                                .showPopup();
                                          } else {
                                            startDate.value = value;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Starting Streak'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                            '${DateTime.now().difference(startDate.value).inDays}'),
                                        Icon(Icons.brush_sharp)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        MilestoneList(
                          minDay:
                              DateTime.now().difference(startDate.value).inDays,
                          milestones: milestones,
                          dayController: dayController,
                          rewardController: rewardController,
                          startDate: startDate,
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CreateButton(
                            onPressed: () async {
                              var tracker = new TrackerTask(
                                  titleController.text,
                                  noteController.text,
                                  milestones.value,
                                  startDate.value);
                              await Database(uid).addTrackerTask(tracker);
                              trackerChanged.value += 1;
                              Navigator.of(context).pop();
                            },
                            isValid: isValid),
                        const CancelButton()
                      ],
                    ))
              ],
            ),
          )),
    );
  }
}

class MilestoneList extends HookWidget {
  const MilestoneList(
      {Key? key,
      required this.dayController,
      required this.rewardController,
      required this.minDay,
      required this.milestones,
      required this.startDate})
      : super(key: key);

  final milestones;
  final dayController;
  final rewardController;
  final minDay;
  final startDate;

  static bool checkDuplicate(List milestoneList, value) {
    var isValid = true;
    print(milestoneList);
    for (var i = 0; i < milestoneList.length; i++) {
      if (milestoneList[i]['day'].toString() == value) {
        isValid = false;
      }
    }
    print(isValid);
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(alignment: Alignment.topLeft, child: Text('Milestones')),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: milestones.value.length,
            itemBuilder: (context, index) {
              return MilestoneTile(
                milestones: milestones.value[index],
                milestonesList: milestones,
                index: index,
                dayController: dayController,
                rewardController: rewardController,
                minDay: DateTime.now().difference(startDate.value).inDays,
              );
            }),
        IconButton(
            onPressed: () {
              OneContext().showDialog(
                  barrierDismissible: false,
                  builder: (_) {
                    final _formKey2 = GlobalKey<FormState>();
                    return AlertDialog(
                      title: Text('Add New Milestone'),
                      content: Form(
                        key: _formKey2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Day'),
                            TextFormField(
                              controller: dayController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'^0+')),
                              ],
                              validator: (value) {
                                String valueString = value as String;
                                if (valueString.isEmpty) {
                                  return "Enter a day";
                                } else if (int.parse(valueString) <= minDay ||
                                    !MilestoneList.checkDuplicate(
                                        milestones.value, valueString)) {
                                  return "The milestone must be higher than the current streak or must contain no duplicates";
                                }
                              },
                            ),
                            Text('Text'),
                            TextFormField(
                              controller: rewardController,
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            child: Text('Add'),
                            onPressed: () {
                              if (_formKey2.currentState!.validate()) {
                                milestones.value.add({
                                  'day': int.parse(dayController.text),
                                  'reward': rewardController.text,
                                  'isComplete': false,
                                });
                                milestones.value =
                                    List<Map<String, dynamic>>.from(
                                        milestones.value);
                                List<Map<String, dynamic>> tempList =
                                    milestones.value.toList();
                                tempList.sort(
                                    (a, b) => a['day'].compareTo(b['day']));
                                milestones.value = tempList.toList();
                                dayController.clear();
                                rewardController.clear();
                                OneContext().popDialog();
                              }
                            }),
                        TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              dayController.clear();
                              rewardController.clear();
                              OneContext().popDialog();
                            }),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.add))
      ],
    );
  }
}

class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    Key? key,
    required this.milestones,
    required this.milestonesList,
    required this.index,
    required this.dayController,
    required this.rewardController,
    required this.minDay,
  }) : super(key: key);

  final milestones;
  final milestonesList;
  final index;
  final dayController;
  final rewardController;
  final minDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 30.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(child: Text('Day ${milestones['day']}'))),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Icon(Icons.delete),
                  ),
                  onTap: () {
                    StyledPopup(
                      title: 'Delete Milestone?',
                      children: [],
                      textButton: TextButton(
                          child: Text('Delete'),
                          onPressed: () {
                            milestonesList.value.removeAt(index);
                            milestonesList.value =
                                List<Map<String, dynamic>>.from(
                                    milestonesList.value);
                            OneContext().popDialog();
                          }),
                    ).showPopup();
                  },
                ),
              ],
            ),
            Container(
                width: 100.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: Colors.amber[200],
                  border: Border.all(color: Colors.amber, width: 5),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(milestones['reward'])),
                )),
          ],
        ),
        onTap: () {
          dayController.text = milestones['day'].toString();
          rewardController.text = milestones['reward'];
          OneContext().showDialog(
              barrierDismissible: false,
              builder: (_) {
                final _formKey3 = GlobalKey<FormState>();
                return AlertDialog(
                  title: Text('Edit Milestone'),
                  content: Form(
                    key: _formKey3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Day'),
                        TextFormField(
                          controller: dayController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                          ],
                          validator: (value) {
                            String valueString = value as String;
                            if (valueString.isEmpty) {
                              return "Enter a day";
                            } else if (int.parse(valueString) < minDay) {
                              return "The milestone must be higher than the current streak";
                            }
                          },
                        ),
                        Text('Text'),
                        TextFormField(
                          controller: rewardController,
                          maxLength: 100,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_formKey3.currentState!.validate()) {
                            milestonesList.value[index]['day'] =
                                int.parse(dayController.text);
                            milestonesList.value[index]['reward'] =
                                rewardController.text;
                            milestonesList.value =
                                List<Map<String, dynamic>>.from(
                                    milestonesList.value);
                            List<Map<String, dynamic>> tempList =
                                milestonesList.value.toList();
                            tempList
                                .sort((a, b) => a['day'].compareTo(b['day']));
                            milestonesList.value = tempList.toList();
                            dayController.clear();
                            rewardController.clear();
                            OneContext().popDialog();
                          }
                        }),
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          dayController.clear();
                          rewardController.clear();
                          OneContext().popDialog();
                        }),
                  ],
                );
              });
        },
      ),
    );
  }
}
