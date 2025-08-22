import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photos/models/photo.dart';
import 'package:photos/providers/photos_provider.dart';

class EditPhotoInfoDialog extends ConsumerStatefulWidget {

  final Photo photo;

  const EditPhotoInfoDialog({super.key, required this.photo});

  @override
  ConsumerState<EditPhotoInfoDialog> createState() => _EditPhotoInfoDialogState();
}

class _EditPhotoInfoDialogState extends ConsumerState<EditPhotoInfoDialog> {

  late final titleController = TextEditingController(text: widget.photo.title);
  late final commentController = TextEditingController(text: widget.photo.note);
  late var date = widget.photo.date;

  @override
  void dispose() {
    titleController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? width;

    if (App.isWideScreen(context)) {
      width = 400;
    }

    return Dialog(
      child: SizedBox(
        width: width,
        height: 400,
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () {
                      Navigator.pop(context);
                    }, icon: const Icon(Icons.cancel_outlined, size: 20,)),
                    IconButton(onPressed: () {
                      Navigator.pop(context);
                      widget.photo.title = titleController.text;
                      widget.photo.date = date;
                      widget.photo.note = commentController.text;
                      ref.read(photosProvider.notifier).insertPhoto(widget.photo);
                    }, icon: const Icon(Icons.check_circle_outline, size: 20,)),
                  ],)),
            Positioned(
                left: 8,
                right: 8,
                top: 48,
                bottom: 8,
                child: ListView(children: [
                  TextField(
                    controller: titleController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: "your title",
                        contentPadding: const EdgeInsets.all(8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                                style: BorderStyle.solid,
                                width: 2),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .scaffoldBackgroundColor,
                              style: BorderStyle.solid,),
                            borderRadius: BorderRadius.circular(5)
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final lastDate = DateTime(now.year + 50, 1, 1);
                      final dateTime = await showDatePicker(
                          context: context, firstDate: DateTime(1800, 1, 1), lastDate: lastDate, initialDate: date);

                      if (dateTime != null) {
                        setState(() {
                          date = dateTime;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat.yMMMMEEEEd().format(date)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay(hour: date.hour, minute: date.minute));

                      if (timeOfDay != null) {
                        setState(() {
                          date = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat.jm().format(date)),
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    minLines: 9,
                    maxLines: 9,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get("@hint_photo_note"),
                        contentPadding: const EdgeInsets.all(8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                                style: BorderStyle.solid,
                                width: 2),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme
                                  .of(context)
                                  .scaffoldBackgroundColor,
                              style: BorderStyle.solid,),
                            borderRadius: BorderRadius.circular(5)
                        )
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }
}
