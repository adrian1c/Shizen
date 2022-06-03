import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shizen_app/models/todoTask.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/utils/notifications.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:timezone/data/latest.dart' as tz;

class AddToDoTask extends HookWidget {
  const AddToDoTask({Key? key, this.editParams, this.isEdit = false})
      : super(key: key);

  final editParams;
  final isEdit;

  static checkTaskValid(
      ValueNotifier<List> taskList, ValueNotifier<bool> isValid) {
    isValid.value = taskList.value.length > 0 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;

    final TextEditingController titleController = useTextEditingController();
    final TextEditingController taskController = useTextEditingController();
    useEffect(() {
      tz.initializeTimeZones();
      return null;
    }, []);
    final ValueNotifier<bool> isValid =
        useState(editParams != null ? true : false);

    final ValueNotifier<String> title =
        useState(editParams != null ? editParams['title'] : '');
    final ValueNotifier<List> taskList =
        useState(editParams != null ? editParams['desc'] : []);

    final ValueNotifier<List<bool>> recurValue = useState(editParams != null
        ? editParams['recur']
        : [false, false, false, false, false, false, false]);
    final ValueNotifier<DateTime?> reminderValue = useState(editParams != null
        ? editParams['reminder'] != null
            ? DateTime.now().isBefore(editParams['reminder'])
                ? editParams['reminder']
                : null
            : null
        : null);
    final ValueNotifier<bool> isPublic =
        useState(editParams != null ? editParams['isPublic'] : false);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
        centerTitle: true,
      ),
      body: SafeArea(
          minimum: EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                TodoTaskList(
                  titleController: titleController,
                  taskController: taskController,
                  title: title,
                  taskList: taskList,
                  isValid: isValid,
                ),
                Row(
                  children: [
                    Text('Share with Friends'),
                    Switch(
                      value: isPublic.value,
                      onChanged: (value) =>
                          isPublic.value = isPublic.value ? false : true,
                    )
                  ],
                ),
                // RecurButton(
                //   taskList: taskList,
                //   recurValue: recurValue,
                //   isValid: isValid,
                // ),
                ReminderButton(
                    taskList: taskList, reminderValue: reminderValue),
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateButton(
                        onPressed: () async {
                          if (isValid.value) {
                            if (isEdit) {
                              var newTask = ToDoTaskModel(
                                  title.value,
                                  taskList.value,
                                  recurValue.value,
                                  reminderValue.value,
                                  isPublic.value,
                                  true);
                              await LoaderWithToast(
                                      context: context,
                                      api: Database(uid).editToDoTask(
                                          editParams['id'],
                                          newTask,
                                          reminderValue.value),
                                      msg: 'Success',
                                      isSuccess: true)
                                  .show();
                            } else {
                              var newTask = ToDoTaskModel(
                                  title.value,
                                  taskList.value,
                                  recurValue.value,
                                  reminderValue.value,
                                  isPublic.value);
                              await LoaderWithToast(
                                      context: context,
                                      api: Database(uid).addToDoTask(
                                          newTask, reminderValue.value),
                                      msg: 'Success',
                                      isSuccess: true)
                                  .show();
                            }
                            Provider.of<TabProvider>(context, listen: false)
                                .rebuildPage('todo');
                            Navigator.of(context).pop();
                          }
                        },
                        isValid: isValid,
                        buttonLabel: isEdit ? 'Save' : 'Create',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const CancelButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}

class TodoTaskList extends HookWidget {
  const TodoTaskList({
    Key? key,
    required this.titleController,
    required this.taskController,
    required this.title,
    required this.taskList,
    required this.isValid,
  });

  final TextEditingController titleController;
  final TextEditingController taskController;
  final ValueNotifier<String> title;
  final ValueNotifier<List> taskList;
  final ValueNotifier<bool> isValid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              titleController.text = title.value;
              StyledPopup(
                  context: context,
                  title: 'Task Title',
                  children: [
                    TextFormField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: Color(0xff58865C)),
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
                        labelText: "Task Title",
                        labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xff35566D))),
                      ),
                    )
                  ],
                  textButton: TextButton(
                    onPressed: () {
                      title.value = titleController.text;
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  )).showPopup();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    constraints: BoxConstraints(minWidth: 25.w, minHeight: 5.h),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(200),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                          title.value == '' ? 'Enter Title' : title.value,
                          style: Theme.of(context).textTheme.headline4),
                    ))),
              ],
            ),
          ),
          ConstrainedBox(
              constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: CustomTheme.boxShadow,
                  ),
                  child: taskList.value.length == 0
                      ? Container(
                          decoration: BoxDecoration(
                              color: CustomTheme.greyedOutField,
                              borderRadius: BorderRadius.circular(15)),
                          height: 5.h,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.center,
                          child: Text('Add a task',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor)))
                      : ReorderableListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          onReorder: (int oldIndex, int newIndex) {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }

                            final item = taskList.value.removeAt(oldIndex);
                            taskList.value.insert(newIndex, item);
                          },
                          itemCount: taskList.value.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              key: Key('$index'),
                              child: Container(
                                constraints: BoxConstraints(minHeight: 5.h),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    color: taskList.value[index]['status']
                                        ? CustomTheme.completeColor
                                        : Theme.of(context).backgroundColor,
                                    borderRadius: index == 0
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomLeft:
                                                taskList.value.length == 1
                                                    ? Radius.circular(15)
                                                    : Radius.zero,
                                            bottomRight:
                                                taskList.value.length == 1
                                                    ? Radius.circular(15)
                                                    : Radius.zero,
                                          )
                                        : index == taskList.value.length - 1
                                            ? BorderRadius.only(
                                                bottomLeft: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15),
                                              )
                                            : null),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            taskList.value[index]['task'],
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                decoration: taskList
                                                        .value[index]['status']
                                                    ? TextDecoration.lineThrough
                                                    : null)),
                                      ),
                                      InkWell(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Icon(Icons.cancel_rounded,
                                              color: CustomTheme.inactiveIcon),
                                        ),
                                        onTap: () {
                                          StyledPopup(
                                                  context: context,
                                                  title: 'Remove this task?',
                                                  children: [],
                                                  textButton: TextButton(
                                                      onPressed: () {
                                                        taskList.value =
                                                            List.from(
                                                                taskList.value)
                                                              ..removeAt(index);
                                                        AddToDoTask
                                                            .checkTaskValid(
                                                                taskList,
                                                                isValid);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Remove')))
                                              .showPopup();
                                        },
                                      ),
                                    ]),
                              ),
                              onTap: () {
                                taskController.text =
                                    taskList.value[index]['task'];
                                TaskDescPopup(
                                  context: context,
                                  taskController: taskController,
                                  taskList: taskList,
                                  isValid: isValid,
                                  isEdit: true,
                                  index: index,
                                ).showTaskDescPopup();
                              },
                            );
                          }))),
          if (taskList.value.length < 10)
            Align(
                alignment: Alignment.center,
                child: IconButton(
                    onPressed: () {
                      taskController.clear();
                      TaskDescPopup(
                        context: context,
                        taskController: taskController,
                        taskList: taskList,
                        isValid: isValid,
                        isEdit: false,
                      ).showTaskDescPopup();
                    },
                    icon: Icon(Icons.add))),
        ],
      ),
    );
  }
}

class TaskDescPopup {
  const TaskDescPopup(
      {Key? key,
      required this.context,
      required this.taskController,
      required this.taskList,
      required this.isValid,
      required this.isEdit,
      this.index});

  final context;
  final TextEditingController taskController;
  final ValueNotifier<List> taskList;
  final ValueNotifier<bool> isValid;
  final bool isEdit;
  final index;

  showTaskDescPopup() {
    var _formKey = GlobalKey<FormState>();
    StyledPopup(
      context: context,
      title: 'Add Task',
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
              controller: taskController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Color(0xff58865C)),
              maxLines: 1,
              maxLength: 100,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
                labelText: "Task Description",
                labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
                enabledBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xff35566D))),
              ),
              validator: (value) {
                String valueString = value as String;
                if (valueString.isEmpty) {
                  return "You have not filled anything in";
                } else {
                  return null;
                }
              }),
        )
      ],
      textButton: TextButton(
        child: Text('Add'),
        onPressed: () {
          if (_formKey.currentState!.validate() && !isEdit) {
            taskList.value = List.from(taskList.value)
              ..add({'task': taskController.text, 'status': false});
            AddToDoTask.checkTaskValid(taskList, isValid);
            taskController.clear();
            Navigator.pop(context);
          }
          if (_formKey.currentState!.validate() && isEdit) {
            taskList.value[index]['task'] = taskController.text;
            taskList.value = List.from(taskList.value);
            taskController.clear();
            Navigator.pop(context);
          }
        },
      ),
      cancelFunction: () {
        taskController.clear();
        Navigator.pop(context);
      },
    ).showPopup();
  }
}

class RecurButton extends HookWidget {
  const RecurButton(
      {Key? key,
      required this.taskList,
      required this.recurValue,
      required this.isValid})
      : super(key: key);

  final taskList;
  final recurValue;
  final isValid;

  final recurDay = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final selectedValue = useState(recurValue.value.toList());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: taskList.value.length == 0
                  ? () {}
                  : () {
                      selectedValue.value = recurValue.value.toList();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Recurring Days'),
                            content: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Container(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: recurDay.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return StatefulBuilder(
                                            builder: (context, _) =>
                                                CheckboxListTile(
                                              dense: true,
                                              title: new Text(recurDay[index]),
                                              value: selectedValue.value[index],
                                              onChanged: (value) {
                                                _(() =>
                                                    selectedValue.value[index] =
                                                        value ?? false);
                                              },
                                            ),
                                          );
                                        }),
                                  )
                                ])),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  recurValue.value =
                                      selectedValue.value.toList();
                                  Navigator.pop(context);
                                },
                                child: Text('Save'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'))
                            ],
                          );
                        },
                      );
                    },
              child: Container(
                width: 100.w,
                height: 7.h,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: taskList.value.length == 0
                        ? CustomTheme.greyedOutField
                        : Theme.of(context).primaryColor.withAlpha(200)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recurring Days',
                      style:
                          TextStyle(color: Theme.of(context).backgroundColor),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: recurValue.value.length,
                      itemBuilder: (context, index) {
                        return Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Text(
                                  recurDay[index][0],
                                  style: TextStyle(
                                      color: recurValue.value[index]
                                          ? Colors.lightGreenAccent[400]
                                          : Theme.of(context)
                                              .backgroundColor
                                              .withAlpha(150)),
                                )));
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
              width: 5.h,
              height: 5.h,
              child: InkWell(
                  onTap: recurValue.value.contains(true)
                      ? () {
                          StyledPopup(
                                  context: context,
                                  title:
                                      'Do you want to remove all existing recurring days?',
                                  children: [],
                                  textButton: TextButton(
                                      onPressed: () {
                                        selectedValue.value = [
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false
                                        ];
                                        recurValue.value = [
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false,
                                          false
                                        ];
                                        Navigator.pop(context);
                                      },
                                      child: Text('Remove')))
                              .showPopup();
                        }
                      : () {},
                  child: Icon(Icons.cancel_outlined)))
        ],
      ),
    );
  }
}

class ReminderButton extends HookWidget {
  const ReminderButton(
      {Key? key, required this.taskList, required this.reminderValue})
      : super(key: key);

  final ValueNotifier<List> taskList;
  final ValueNotifier<DateTime?> reminderValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: taskList.value.length == 0
                  ? () {}
                  : () {
                      DatePicker.showDateTimePicker(
                        context,
                        minTime: DateTime.now().add(Duration(minutes: 2)),
                        currentTime:
                            reminderValue.value?.add(Duration(minutes: 1)),
                        onConfirm: (time) {
                          print(time);
                          reminderValue.value = time;
                        },
                      );
                    },
              child: Container(
                width: 100.w,
                height: 7.h,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: taskList.value.length == 0
                        ? CustomTheme.greyedOutField
                        : Theme.of(context).primaryColor.withAlpha(200)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reminder',
                        style: TextStyle(
                            color: Theme.of(context).backgroundColor)),
                    Text(
                        reminderValue.value == null
                            ? 'No Time Selected'
                            : '${DateFormat('dd MMM yy hh:mm a').format(reminderValue.value!)}',
                        style: TextStyle(
                            color: reminderValue.value == null
                                ? Theme.of(context)
                                    .backgroundColor
                                    .withAlpha(150)
                                : Colors.lightGreenAccent[400]))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
              width: 5.h,
              height: 5.h,
              child: InkWell(
                  onTap: reminderValue.value != null
                      ? () {
                          StyledPopup(
                                  context: context,
                                  title: 'Do you want to remove this reminder?',
                                  children: [],
                                  textButton: TextButton(
                                      onPressed: () {
                                        reminderValue.value = null;
                                        Navigator.pop(context);
                                      },
                                      child: Text('Remove')))
                              .showPopup();
                        }
                      : () {},
                  child: Icon(Icons.cancel_outlined)))
        ],
      ),
    );
  }
}
