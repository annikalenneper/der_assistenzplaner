


import 'package:der_assistenzplaner/styles/styles.dart';
import 'package:flutter/material.dart';


class SelectableWrapper<T> extends StatelessWidget {
  final T entity; // generic entity
  final Widget child; // widget
  final void Function(T)? onSelect; // callback function

  const SelectableWrapper({
    super.key,
    required this.entity,
    required this.child,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect != null ? () => onSelect!(entity) : null,
      child: child,
    );
  }
}





//------------------------- TimePicker -------------------------


Future<void> pickTime({
  required BuildContext context, 
  required TimeOfDay initialTime, 
  required void Function(TimeOfDay) onTimeSelected
  }) async {

  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.input,
  );
  /// callback function to handle returned time
  if (pickedTime != null) {
    onTimeSelected(pickedTime);
  }
}


// combines two dropdown windows for minutes and hours selection
class CustomDropDownTimePicker extends StatefulWidget {
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final TimeOfDay? initialTime;

  const CustomDropDownTimePicker({
    super.key,
    this.onTimeChanged,
    this.initialTime,
  });

  @override
  State<CustomDropDownTimePicker> createState() => CustomDropDownTimePickerState();
}

class CustomDropDownTimePickerState extends State<CustomDropDownTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    // set initial values
    _selectedHour = widget.initialTime?.hour ?? 0;
    _selectedMinute = widget.initialTime?.minute ?? 0;
  }

  // generate hours options
  List<DropdownMenuItem<int>> get _hourItems {
    return List.generate(24, (index) {
      return DropdownMenuItem(
        value: index,
        child: Text(index.toString().padLeft(2, '0')),
      );
    });
  }

  // generate minute options
  List<DropdownMenuItem<int>> get _minuteItems {
    return List.generate(60, (index) {
      return DropdownMenuItem(
        value: index,
        child: Text(index.toString().padLeft(2, '0')),
      );
    });
  }

  // keep values in sync with selection
  void _onHourChanged(int? newHour) {
    if (newHour != null) {
      setState(() {
        _selectedHour = newHour;
      });
      _notifyTimeChanged();
    }
  }

  void _onMinuteChanged(int? newMinute) {
    if (newMinute != null) {
      setState(() {
        _selectedMinute = newMinute;
      });
      _notifyTimeChanged();
    }
  }

  void _notifyTimeChanged() {
    if (widget.onTimeChanged != null) {
      widget.onTimeChanged!(TimeOfDay(hour: _selectedHour, minute: _selectedMinute));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // hours dropdown
          IntrinsicWidth(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedHour,
              items: _hourItems,
              onChanged: _onHourChanged,
            ),
          ),
          SizedBox(width: 12),
          Text(':'),
          SizedBox(width: 12,),
          // minutes dropdown
          IntrinsicWidth(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedMinute,
              items: _minuteItems,
              onChanged: _onMinuteChanged,
            ),
          ),
          SizedBox(width: 12,),
          Text('Uhr'),
        ],
      ),
    );
  }
}



//------------------------- Dropdown menus -------------------------

/// generic dropdown widget 
class DropDownOptionPicker<T> extends StatefulWidget {
  final List<T> options; 
  final ValueChanged<T> onOptionSelected; 
  final T? initialValue; 

  const DropDownOptionPicker({super.key, required this.options, required this.onOptionSelected, this.initialValue});

  @override
  State<DropDownOptionPicker<T>> createState() => _DropDownOptionPickerState<T>();
}

class _DropDownOptionPickerState<T> extends State<DropDownOptionPicker<T>> {
  late T selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialValue ?? widget.options.first; 
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: selectedOption,
      isExpanded: true,
      items: widget.options.map((option) {
        return DropdownMenuItem<T>(
          value: option,
          /// use enum name if option is enum, else use toString
          child: Text(
            option is Enum ? option.name : option.toString(), 
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedOption = value;
          });
          widget.onOptionSelected(value);
        }
      },
    );
  }
}


class DropDownColorPicker extends StatefulWidget {
  final List<Map<String, dynamic>> colors = ModernBusinessTheme.assistantColors;

  final ValueChanged<Color> onColorSelected;

  DropDownColorPicker({super.key, required this.onColorSelected});

  @override
  State<DropDownColorPicker> createState() => DropDownColorPickerState();
}

class DropDownColorPickerState extends State<DropDownColorPicker> {
  late Map<String, dynamic> selectedColor = widget.colors.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Map<String, dynamic>>(
      value: selectedColor,
      isExpanded: true, 
      items: widget.colors.map((colorData) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: colorData,
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: colorData['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 8), 
              Text(colorData['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedColor = value;
            widget.onColorSelected(value['color']);
          });
        }
      },
    );
  }
}


