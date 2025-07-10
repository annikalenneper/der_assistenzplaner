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
  void initState() {
    super.initState();
    // Trigger callback mit der anfänglichen Farbe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onColorSelected(selectedColor['color']);
    });
  }

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


