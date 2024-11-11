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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                genre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedGenre == genre
                      ? Colors.white
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
              selected: selectedGenre == genre,
              backgroundColor: Colors.grey[300],
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selectedGenre == genre
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400]!,
                ),
              ),
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
