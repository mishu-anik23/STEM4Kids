import 'package:flutter/material.dart';
import '../../models/level_data.dart';

class DragDropWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  const DragDropWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  State<DragDropWidget> createState() => _DragDropWidgetState();
}

class _DragDropWidgetState extends State<DragDropWidget> {
  String? droppedAnswer;
  bool isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.question.questionText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: DragTarget<String>(
            onWillAcceptWithDetails: (data) => !isSubmitted,
            onAcceptWithDetails: (data) {
              setState(() {
                droppedAnswer = data.data;
                isSubmitted = true;
              });
              widget.onAnswerSubmitted(data.data);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  color: droppedAnswer != null
                      ? Colors.blue.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.blue
                        : Colors.grey.shade400,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: Center(
                  child: Text(
                    droppedAnswer ?? '?',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: droppedAnswer != null
                          ? Colors.blue
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Drag the correct answer here:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: options.map((option) {
            final isDragged = droppedAnswer == option;

            if (isDragged && isSubmitted) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                ),
              );
            }

            return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
