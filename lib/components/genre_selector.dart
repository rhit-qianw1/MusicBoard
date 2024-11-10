import 'package:flutter/material.dart';

class GenreSelector extends StatelessWidget {
  final String selectedGenre;
  final Function(String) onGenreSelected;
  final List<String> genres = ['All', 'Classic', 'Popular', 'Country', 'Electronic'];

  GenreSelector({super.key, required this.selectedGenre, required this.onGenreSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(genre),
              selected: selectedGenre == genre,
              onSelected: (selected) {
                if (selected) {
                  onGenreSelected(genre);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
