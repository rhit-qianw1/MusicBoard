import 'package:flutter/material.dart';
import '../models/music_item.dart';

class MusicBoardFormDialog extends StatefulWidget {
  final MusicItem? musicItem;
  final Future<void> Function(MusicItem) onSubmit;

  MusicBoardFormDialog({this.musicItem, required this.onSubmit});

  @override
  _MusicBoardFormDialogState createState() => _MusicBoardFormDialogState();
}

class _MusicBoardFormDialogState extends State<MusicBoardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String artist;
  late String genre;
  late String imageUrl;
  late String description;
  String? creatorId;
  bool _isSubmitting = false;
  final List<String> genres = ['Classic', 'Popular', 'Country', 'Electronic'];

  @override
  void initState() {
    super.initState();
    name = widget.musicItem?.name ?? '';
    artist = widget.musicItem?.artist ?? '';
    genre = widget.musicItem?.genre ?? genres.first;
    imageUrl = widget.musicItem?.imageUrl ?? '';
    description = widget.musicItem?.description ?? '';
    creatorId = widget.musicItem?.creatorId;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final newItem = MusicItem(
      name: name,
      artist: artist,
      genre: genre,
      imageUrl: imageUrl,
      description: description,
      creatorId: creatorId!,
    );

    try {
      await widget.onSubmit(newItem);
      Navigator.pop(context);
    } catch (e) {
      print("Error submitting data: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.musicItem == null ? 'Create Music Item' : 'Edit Music Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: artist,
                decoration: InputDecoration(labelText: 'Artist'),
                onChanged: (value) => artist = value,
              ),
              DropdownButtonFormField<String>(
                value: genre,
                decoration: InputDecoration(labelText: 'Genre'),
                items: genres.map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      genre = value;
                    });
                  }
                },
              ),
              TextFormField(
                initialValue: imageUrl,
                decoration: InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => imageUrl = value,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? CircularProgressIndicator(strokeWidth: 2)
              : Text('Submit'),
        ),
      ],
    );
  }
}