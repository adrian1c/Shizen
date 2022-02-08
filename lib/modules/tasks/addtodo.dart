import 'package:shizen_app/models/todoTask.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddToDoTask extends StatefulWidget {
  AddToDoTask({Key? key}) : super(key: key);

  @override
  _AddToDoTaskState createState() => _AddToDoTaskState();
}

class _AddToDoTaskState extends State<AddToDoTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  ValueNotifier isRecur = ValueNotifier(false);
  ValueNotifier isReminder = ValueNotifier(false);
  ValueNotifier isDeadline = ValueNotifier(false);

  Map<String, bool> validateFields = {
    "titleValid": false,
    "recurValid": true,
    "reminderValid": true,
    "deadlineValid": true,
  };

  List recurListKey = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List recurListValue = [false, false, false, false, false, false, false];

  DateTime? reminderTime;
  DateTime? deadlineDate;

  final ValueNotifier isValid = ValueNotifier(false);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descController.dispose();
  }

  String returnString(values) {
    String output = '';
    values.asMap().forEach((index, element) {
      if (element) {
        output += recurListKey[index] + '\n';
      }
    });
    return output;
  }

  bool checkValidity(Map<String, bool> validateFields) {
    bool isValid = false;
    if (!validateFields.containsValue(false)) {
      isValid = true;
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    print("Built AddToDoTask");
    String uid = Provider.of<UserProvider>(context).uid;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Task"),
          centerTitle: true,
        ),
        body: SafeArea(
            minimum: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: width,
                    height: height * 0.3,
                    color: Colors.amber,
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            titleTextField(),
                            descTextField(),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isButton(
                          width,
                          Icon(Icons.repeat),
                          "Recurring",
                          isRecur,
                          (value) {
                            if (!value) {
                              isRecur.value = value;
                              setState(() => recurListValue = [
                                    false,
                                    false,
                                    false,
                                    false,
                                    false,
                                    false,
                                    false
                                  ]);
                              validateFields["recurValid"] = true;
                              isValid.value = checkValidity(validateFields);
                            } else {
                              isRecur.value = value;
                              validateFields["recurValid"] = false;
                              isValid.value = checkValidity(validateFields);
                            }
                          },
                          () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Text("Recurring Days"),
                                      content: Container(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: recurListKey.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return StatefulBuilder(
                                                builder: (context, _setState) =>
                                                    new CheckboxListTile(
                                                  title: new Text(
                                                      recurListKey[index]),
                                                  value: recurListValue[index],
                                                  onChanged: (value) {
                                                    print(value);
                                                    _setState(() {
                                                      setState(() {
                                                        recurListValue[index] =
                                                            value ?? false;
                                                      });

                                                      if (recurListValue
                                                          .contains(true)) {
                                                        validateFields[
                                                                "recurValid"] =
                                                            true;
                                                        isValid.value =
                                                            checkValidity(
                                                                validateFields);
                                                      } else {
                                                        validateFields[
                                                                "recurValid"] =
                                                            false;
                                                        isValid.value =
                                                            checkValidity(
                                                                validateFields);
                                                      }
                                                    });
                                                  },
                                                ),
                                              );
                                            }),
                                      ),
                                      actions: [
                                        TextButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                      ]);
                                });
                          },
                          returnString(recurListValue),
                        ),
                        isButton(
                          width,
                          Icon(Icons.notifications_active),
                          "Reminder",
                          isReminder,
                          (value) {
                            if (!value) {
                              isReminder.value = value;
                              setState(() => reminderTime = null);
                              validateFields["reminderValid"] = true;
                              isValid.value = checkValidity(validateFields);
                            } else {
                              isReminder.value = value;
                              validateFields["reminderValid"] = false;
                              isValid.value = checkValidity(validateFields);
                            }
                          },
                          () {
                            DatePicker.showDateTimePicker(
                              context,
                              minTime: DateTime.now(),
                              onConfirm: (time) {
                                setState(() => reminderTime = time);
                                validateFields["reminderValid"] = true;
                                isValid.value = checkValidity(validateFields);
                              },
                            );
                          },
                          reminderTime != null
                              ? reminderTime.toString()
                              : "No Time Selected",
                        ),
                        isButton(
                          width,
                          Icon(Icons.timer),
                          "Deadline",
                          isDeadline,
                          (value) {
                            if (!value) {
                              isDeadline.value = value;
                              setState(() => deadlineDate = null);
                              validateFields["deadlineValid"] = true;
                              isValid.value = checkValidity(validateFields);
                            } else {
                              isDeadline.value = value;
                              validateFields["deadlineValid"] = false;
                              isValid.value = checkValidity(validateFields);
                            }
                          },
                          () {
                            DatePicker.showDateTimePicker(context,
                                minTime: DateTime.now(), onConfirm: (date) {
                              setState(() => deadlineDate = date);
                              validateFields["deadlineValid"] = true;
                              isValid.value = checkValidity(validateFields);
                            });
                          },
                          deadlineDate != null
                              ? deadlineDate.toString()
                              : "No Date Selected",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CreateButton(
                          onPressed: !validateFields.containsValue(false)
                              ? () async {
                                  validateFields["title"] = false;
                                  isValid.value = checkValidity(validateFields);
                                  var newTask = ToDoTask(titleController.text,
                                      descController.text, {
                                    "recur": recurListValue,
                                    "reminder": reminderTime,
                                    "deadline": deadlineDate,
                                  });
                                  await Database(uid).addToDoTask(newTask);
                                  Navigator.of(context).pop();
                                }
                              : () {},
                          isValid: isValid,
                        ),
                        const CancelButton(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget titleTextField() {
    print("Built titleTextField");
    return TextFormField(
        controller: titleController,
        style: TextStyle(color: Color(0xff58865C)),
        maxLines: 1,
        maxLength: 30,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
          labelText: "Title",
          labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
          enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Color(0xff35566D))),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            validateFields["titleValid"] = true;
            isValid.value = checkValidity(validateFields);
          } else {
            validateFields["titleValid"] = false;
            isValid.value = checkValidity(validateFields);
          }
        },
        // The validator receives the text that the user has entered.
        validator: (value) {
          String valueString = value as String;
          if (valueString.isEmpty) {
            return "You have not filled anything in";
          } else {
            return null;
          }
        });
  }

  Widget descTextField() {
    print("Built descTextField");

    return TextFormField(
        controller: descController,
        style: TextStyle(color: Color(0xff58865C)),
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        maxLength: 300,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
          labelText: "Description",
          labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
          enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Color(0xff35566D))),
        ),
        // The validator receives the text that the user has entered.
        validator: (value) {
          String valueString = value as String;
          if (valueString.isEmpty) {
            return "You have not filled anything in";
          } else {
            return null;
          }
        });
  }

  Widget isButton(width, icon, text, ValueNotifier isValue,
      Function(bool)? switchFunction, Function()? editFunction, data) {
    return ValueListenableBuilder(
        valueListenable: isValue,
        builder: (context, value, _) {
          return Column(
            children: [
              Container(
                width: width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      icon,
                      Text(text),
                      Switch(
                        value: isValue.value,
                        onChanged: switchFunction,
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                      value == true
                          ? IconButton(
                              onPressed: editFunction, icon: Icon(Icons.edit))
                          : Container(),
                      value == true ? Text(data) : Container(),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
