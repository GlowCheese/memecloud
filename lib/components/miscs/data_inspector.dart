import 'package:flutter/material.dart';

class DataInspector extends StatelessWidget {
  final dynamic value;
  final String? name;

  const DataInspector(this.value, {super.key, this.name});

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Text('${name ?? 'Value'}: null');
    }

    if (value is num || value is String || value is bool) {
      return Text(
        '${name ?? 'Value'}: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (value is Map<String, dynamic>) {
      return ExpansionTile(
        title: Text(name ?? 'Object'),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children:
            (value as Map<String, dynamic>).entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: DataInspector(e.value, name: e.key),
              );
            }).toList(),
      );
    }

    if (value is List) {
      return ExpansionTile(
        title: Text(name ?? 'List'),
        children:
            (value as List).asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: DataInspector(e.value, name: '[${e.key}]'),
              );
            }).toList(),
      );
    }

    return Text('${name ?? 'Value'}: ${value.toString()}');
  }
}
