import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/search.dart';

class SearchBarWidget extends StatelessWidget {
  final typeAheadController;
  final onSelected;

  const SearchBarWidget(
      {super.key, required this.typeAheadController, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, // This aligns the search bar below the status bar
      left: 8,
      right: 8,
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Material(
          color: Colors.white, // Force
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TypeAheadField(
              controller: typeAheadController,
              errorBuilder: (context, error) => const Text('Errore!'),
              hideOnLoading: true,
              hideOnEmpty: true,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: false,
                  style: DefaultTextStyle.of(context).style,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                      hintText: 'Cerca una strada...'),
                );
              },
              suggestionsCallback: (pattern) async {
                if (pattern.length < 3) {
                  return [];
                }
                return await getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(
                    '${suggestion['properties']['name'] ?? 'Unknown name'}, ${suggestion['properties']['city'] ?? 'Unknown city'}',
                  ),
                  subtitle: Text('${suggestion['properties']['state']}'),
                );
              },
              onSelected: (suggestion) {
                onSelected(suggestion);
              },
            ),
          ),
        ),
      ),
    );
  }
}