import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/models/todoTask.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';

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

    final ValueNotifier<bool> isValid =
        useState(editParams != null ? true : false);

    final ValueNotifier<String> title =
        useState(editParams != null ? editParams['title'] : '');
    final ValueNotifier<List> taskList =
        useState(editParams != null ? editParams['desc'] : []);

    final ValueNotifier<List<bool>> recurValue = useState(editParams != null
        ? editParams['recur']
        : [false, false, false, false, false, false, false]);
    final ValueNotifier<DateTime?> reminderValue =
        useState(editParams != null ? editParams['reminder'] : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
        centerTitle: true,
      ),
      body: SafeArea(
          minimum: EdgeInsets.all(20),
          child: SingleChildScrollView(
              child: Column(
            children: [
              TodoTaskList(
                titleController: titleController,
                taskController: taskController,
                title: title,
                taskList: taskList,
                isValid: isValid,
              ),
              RecurButton(
                taskList: taskList,
                recurValue: recurValue,
                isValid: isValid,
              ),
              ReminderButton(taskList: taskList, reminderValue: reminderValue),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CreateButton(
                      onPressed: () async {
                        if (isValid.value) {
                          var newTask = ToDoTaskModel(
                              title.value,
                              taskList.value,
                              recurValue.value,
                              reminderValue.value);
                          isEdit
                              ? await LoaderWithToast(
                                      context: context,
                                      api: Database(uid).editToDoTask(
                                          editParams['id'], newTask),
                                      msg: 'Success',
                                      isSuccess: true)
                                  .show()
                              : await LoaderWithToast(
                                      context: context,
                                      api: Database(uid).addToDoTask(newTask),
                                      msg: 'Success',
                                      isSuccess: true)
                                  .show();

                          Provider.of<TabProvider>(context, listen: false)
                              .rebuildPage('todo');
                          Provider.of<TabProvider>(context, listen: false)
                              .changeTabPage(0);
                          Navigator.of(context).pop();
                        }
                      },
                      isValid: isValid,
                      buttonLabel: isEdit ? 'Save' : 'Create',
                    ),
                    const CancelButton(),
                  ],
                ),
              ),
            ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    constraints: BoxConstraints(minWidth: 25.w),
                    height: 5.h,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child:
                          Text(title.value == '' ? 'Enter Title' : title.value),
                    ))),
              ],
            ),
          ),
          ConstrainedBox(
              constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber[200],
                    border: Border.all(color: Colors.amber, width: 5),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5)),
                  ),
                  child: taskList.value.length == 0
                      ? Container(
                          decoration: BoxDecoration(color: Colors.grey[400]),
                          height: 5.h,
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.center,
                          child: Text('Add a task',
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: taskList.value.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 5.h,
                              child: InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: taskList.value[index]['status']
                                          ? Colors.lightGreen[400]
                                          : null),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(taskList.value[index]['task'],
                                            softWrap: false,
                                            style: TextStyle(
                                                decoration: taskList
                                                        .value[index]['status']
                                                    ? TextDecoration.lineThrough
                                                    : null)),
                                        IconButton(
                                          color: Colors.red[400],
                                          constraints:
                                              BoxConstraints(maxHeight: 20),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            StyledPopup(
                                                    context: context,
                                                    title: 'Remove this task?',
                                                    children: [],
                                                    textButton: TextButton(
                                                        onPressed: () {
                                                          taskList.value = List
                                                              .from(taskList
                                                                  .value)
                                                            ..removeAt(index);
                                                          AddToDoTask
                                                              .checkTaskValid(
                                                                  taskList,
                                                                  isValid);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Remove')))
                                                .showPopup();
                                          },
                                          icon: Icon(Icons.delete),
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
                              ),
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
              maxLength: 30,
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
                        ? Colors.grey[400]
                        : Colors.blueGrey),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recurring Days',
                        style: TextStyle(color: Colors.white)),
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
                              child: Text(recurDay[index][0],
                                  style: TextStyle(
                                      color: recurValue.value[index]
                                          ? Colors.lightGreenAccent[400]
                                          : Colors.grey[400])),
                            ));
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
                        minTime: DateTime.now(),
                        currentTime: reminderValue.value,
                        onConfirm: (time) {
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
                        ? Colors.grey[400]
                        : Colors.blueGrey),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reminder', style: TextStyle(color: Colors.white)),
                    Text(
                        reminderValue.value == null
                            ? 'No Time Selected'
                            : '${DateFormat('dd MMM yy hh:mm a').format(reminderValue.value!)}',
                        style: TextStyle(
                            color: reminderValue.value == null
                                ? Colors.grey[400]
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
