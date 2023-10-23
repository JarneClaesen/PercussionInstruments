import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchResultsText extends StatelessWidget {
  final String? searchTerm;
  final String? description;
  final String? french;
  final String? german;
  final String? italian;
  final String? spanish;


  const SearchResultsText({
    Key? key,
    required this.searchTerm,
    required this.description,
    required this.french,
    required this.german,
    required this.italian,
    required this.spanish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null || searchTerm!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              size: 64,
            ),
            Text(
              'Start searching',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      );
    }

    /*return Padding(
      padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
      child: Text(
        '$searchTerm',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )
      ),

    );*/

    String printDescription() {

      var buffer = StringBuffer();

      if (description == null || description!.isEmpty || description == ".") {
      } else {
        buffer.write('Description: $description\n\n');
      }
      if (french == null || french!.isEmpty || french == ".") {
      } else {
        buffer.write('French: $french\n\n');
      }
      if (german == null || german!.isEmpty || german == ".") {
      } else {
        buffer.write('German: $german\n\n');
      }
      if (italian == null || italian!.isEmpty || italian == ".") {
      } else {
        buffer.write('Italian: $italian\n\n');
      }
      if (spanish == null || spanish!.isEmpty || spanish == ".") {
      } else {
        buffer.write('Spanish: $spanish\n\n');
      }
      return buffer.toString();
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 120, bottom: 0, left: 20, right: 20),
      children: [
        Container(
          height: 50,
          child: Text('$searchTerm',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 0, left: 0, right: 0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15), // kleur
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15), // kleur
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: LimitedBox(
              maxWidth: 150,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 4, left: 10, right: 10),
                child: Text(printDescription(),
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );


    /*return ListView(
      children: List.generate(
        50,
            (index) => ListTile(
          title: Text('$searchTerm search result'),
          subtitle: Text(index.toString()),
        ),
      ),
    );*/
  }
}