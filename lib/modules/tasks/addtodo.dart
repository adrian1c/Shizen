import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/models/todoTask.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';

class AddToDoTask extends HookWidget {
  static final List recurListKey = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final _formKey = GlobalKey<FormState>();

  static String returnString(values) {
    String output = '';
    values.asMap().forEach((index, element) {
      if (element) {
        output += AddToDoTask.recurListKey[index] + '\n';
      }
    });
    return output;
  }

  static bool checkValidity(Map<String, bool> validateFields) {
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

    final TextEditingController titleController = useTextEditingController();
    final TextEditingController descController = useTextEditingController();

    final ValueNotifier isRecur = useValueNotifier(false);
    final ValueNotifier isReminder = useValueNotifier(false);
    final ValueNotifier isDeadline = useValueNotifier(false);
    final ValueNotifier isValid = useValueNotifier(false);

    final ValueNotifier reminderTime = useValueNotifier(null);
    final ValueNotifier deadlineDate = useValueNotifier(null);

    final ValueNotifier recurListValue =
        useState([false, false, false, false, false, false, false]);

    final ValueNotifier displayText1 = useState('');
    final ValueNotifier displayText2 = useState('');
    final ValueNotifier displayText3 = useState('');

    final ValueNotifier validateFields = useState({
      "titleValid": false,
      "recurValid": true,
      "reminderValid": true,
      "deadlineValid": true,
    });

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
                    width: 100.w,
                    height: 30.h,
                    color: Colors.amber,
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TitleTextField(
                              controller: titleController,
                              validateFields: validateFields,
                              isValid: isValid,
                            ),
                            DescTextField(controller: descController),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ToggleEditButton1(
                          isRecur,
                          recurListValue,
                          validateFields,
                          isValid,
                          displayText1,
                        ),
                        ToggleEditButton2(
                          switchValue: isReminder,
                          reminderTime: reminderTime,
                          validateFields: validateFields,
                          isValid: isValid,
                          displayText: displayText2,
                        ),
                        ToggleEditButton3(
                          switchValue: isDeadline,
                          deadlineDate: deadlineDate,
                          validateFields: validateFields,
                          isValid: isValid,
                          displayText: displayText3,
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
                          onPressed: () async {
                            if (!validateFields.value.containsValue(false)) {
                              var newTask = ToDoTask(
                                  titleController.text, descController.text, {
                                "recur": recurListValue.value,
                                "reminder": reminderTime.value,
                                "deadline": deadlineDate.value,
                              });
                              await Database(uid).addToDoTask(newTask);
                              Navigator.of(context).pop();
                            } else {
                              print('Faile');
                              print(validateFields.value);
                            }
                          },
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
}

class ToggleEditButton1 extends StatelessWidget {
  const ToggleEditButton1(this.isValue, this.recurListValue,
      this.validateFields, this.isValid, this.displayText);

  final isValue;
  final recurListValue;
  final validateFields;
  final isValid;
  final displayText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isValue,
        builder: (context, value, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 25.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(Icons.repeat),
                      Text("Recurring"),
                      Switch(
                        value: isValue.value,
                        onChanged: (value) {
                          if (!value) {
                            isValue.value = value;
                            recurListValue.value = [
                              false,
                              false,
                              false,
                              false,
                              false,
                              false,
                              false
                            ];
                            displayText.value = '';
                            validateFields.value["recurValid"] = true;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          } else {
                            isValue.value = value;
                            validateFields.value["recurValid"] = false;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          }
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                      value == true
                          ? IconButton(
                              onPressed: () {
                                StyledPopup(
                                        title: 'Recurring Days',
                                        children: [
                                          Container(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: AddToDoTask
                                                    .recurListKey.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return StatefulBuilder(
                                                    builder: (context, _) =>
                                                        CheckboxListTile(
                                                      title: new Text(
                                                          AddToDoTask
                                                                  .recurListKey[
                                                              index]),
                                                      value: recurListValue
                                                          .value[index],
                                                      onChanged: (value) {
                                                        _(() => recurListValue
                                                                .value[index] =
                                                            value ?? false);
                                                        displayText.value =
                                                            AddToDoTask
                                                                .returnString(
                                                                    recurListValue
                                                                        .value);
                                                        if (recurListValue.value
                                                            .contains(true)) {
                                                          validateFields.value[
                                                                  "recurValid"] =
                                                              true;
                                                          isValid.value = AddToDoTask
                                                              .checkValidity(
                                                                  validateFields
                                                                      .value);
                                                        } else {
                                                          validateFields.value[
                                                                  "recurValid"] =
                                                              false;
                                                          isValid.value = AddToDoTask
                                                              .checkValidity(
                                                                  validateFields
                                                                      .value);
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ],
                                        cancelText: 'Done')
                                    .showPopup();
                              },
                              icon: Icon(Icons.edit))
                          : Container(),
                      value == true ? Text(displayText.value) : Container(),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class ToggleEditButton2 extends StatelessWidget {
  const ToggleEditButton2(
      {Key? key,
      required this.switchValue,
      required this.reminderTime,
      required this.validateFields,
      required this.isValid,
      required this.displayText});

  final switchValue;
  final reminderTime;
  final validateFields;
  final isValid;
  final displayText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: switchValue,
        builder: (context, value, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 25.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_active),
                      Text("Reminder"),
                      Switch(
                        value: switchValue.value,
                        onChanged: (value) {
                          if (!value) {
                            switchValue.value = value;
                            reminderTime.value = null;
                            displayText.value = '';
                            validateFields.value["reminderValid"] = true;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          } else {
                            switchValue.value = value;
                            validateFields.value["reminderValid"] = false;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          }
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                      value == true
                          ? IconButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  minTime: DateTime.now(),
                                  onConfirm: (time) {
                                    reminderTime.value = time;
                                    displayText.value =
                                        '${DateFormat('dd MMM yy hh:mm a').format(time)}';
                                    validateFields.value["reminderValid"] =
                                        true;
                                    isValid.value = AddToDoTask.checkValidity(
                                        validateFields.value);
                                  },
                                );
                              },
                              icon: Icon(Icons.edit))
                          : Container(),
                      value == true
                          ? displayText.value != ''
                              ? Text(
                                  displayText.value,
                                  textAlign: TextAlign.center,
                                )
                              : Text('No Time Selected')
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class ToggleEditButton3 extends StatelessWidget {
  const ToggleEditButton3(
      {Key? key,
      required this.switchValue,
      required this.deadlineDate,
      required this.validateFields,
      required this.isValid,
      required this.displayText});

  final switchValue;
  final deadlineDate;
  final validateFields;
  final isValid;
  final displayText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: switchValue,
        builder: (context, value, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 25.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(Icons.timer),
                      Text("Deadline"),
                      Switch(
                        value: switchValue.value,
                        onChanged: (value) {
                          if (!value) {
                            switchValue.value = value;
                            deadlineDate.value = null;
                            displayText.value = '';
                            validateFields.value["deadlineValid"] = true;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          } else {
                            switchValue.value = value;
                            validateFields.value["deadlineValid"] = false;
                            isValid.value =
                                AddToDoTask.checkValidity(validateFields.value);
                          }
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                      value == true
                          ? IconButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(context,
                                    minTime: DateTime.now(), onConfirm: (date) {
                                  deadlineDate.value = date;
                                  displayText.value =
                                      '${DateFormat('dd MMM yy hh:mm a').format(date)}';
                                  validateFields.value["deadlineValid"] = true;
                                  isValid.value = AddToDoTask.checkValidity(
                                      validateFields.value);
                                });
                              },
                              icon: Icon(Icons.edit))
                          : Container(),
                      value == true
                          ? Text(
                              displayText.value != ''
                                  ? displayText.value
                                  : 'No Time Selected',
                              textAlign: TextAlign.center,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField(
      {Key? key,
      required this.controller,
      required this.validateFields,
      required this.isValid})
      : super(key: key);

  final controller;
  final validateFields;
  final isValid;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
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
            validateFields.value["titleValid"] = true;
            isValid.value = AddToDoTask.checkValidity(validateFields.value);
          } else {
            validateFields.value["titleValid"] = false;
            isValid.value = AddToDoTask.checkValidity(validateFields.value);
          }
        },
        validator: (value) {
          String valueString = value as String;
          if (valueString.isEmpty) {
            return "You have not filled anything in";
          } else {
            return null;
          }
        });
  }
}

class DescTextField extends StatelessWidget {
  const DescTextField({Key? key, required this.controller}) : super(key: key);

  final controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
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
        validator: (value) {
          String valueString = value as String;
          if (valueString.isEmpty) {
            return "You have not filled anything in";
          } else {
            return null;
          }
        });
  }
}
