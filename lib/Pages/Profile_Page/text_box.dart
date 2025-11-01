import 'package:flutter/material.dart';

class MyTextBox extends StatefulWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  State<MyTextBox> createState() => _MyTextBoxState();
}

class _MyTextBoxState extends State<MyTextBox> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer, // previously Colors.grey[200]
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section name and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.sectionName,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: scheme.onSecondaryContainer,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                onPressed: widget.onPressed,
                icon: Icon(
                  Icons.edit_outlined,
                  color: scheme.primary, // previously Colors.blue.shade900
                ),
              ),
            ],
          ),
          // text value
          Text(
            widget.text,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSecondaryContainer,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
