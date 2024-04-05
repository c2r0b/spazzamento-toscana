import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/search.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? typeAheadController;
  final Function? onSelected;

  const SearchBarWidget(
      {super.key, required this.typeAheadController, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, // This aligns the search bar below the status bar
      left: 8,
      right: 8,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Material(
          color: Theme.of(context).colorScheme.surface, // Force
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
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.primary),
                      hintText:
                          '${AppLocalizations.of(context)!.searchStreet}...'),
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
                if (onSelected != null) {
                  onSelected!(suggestion);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
