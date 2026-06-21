import 'package:jsonld/schema_value.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class SchemaEntity {
  SchemaEntity({
    required this.id,
    required this.type,
    required this.properties,
    this.name = 'Untitled Document',
  });

  final String id;

  String type;

  final Map<String, List<SchemaValue>> properties;

  String name;

  Map<String, dynamic> toJsonLd({bool isRoot = false}) {
    final Map<String, dynamic> result = {};
    if (isRoot) {
      result['@context'] = 'https://schema.org';
    }
    final String typeName = type.startsWith('schema:')
        ? type.substring(7)
        : type;
    result['@type'] = typeName;
    properties.forEach((propId, values) {
      if (values.isEmpty) {
        return;
      }
      final propName = propId.startsWith('schema:')
          ? propId.substring(7)
          : propId;
      final List<dynamic> jsonValues = [];
      for (var val in values) {
        if (val.value is SchemaEntity) {
          jsonValues.add((val.value as SchemaEntity).toJsonLd(isRoot: false));
        } else if (val.value is Map && (val.value as Map).containsKey('@id')) {
          jsonValues.add({'@id': '#${(val.value as Map)['@id']}'});
        } else {
          jsonValues.add(val.value);
        }
      }
      if (jsonValues.isNotEmpty) {
        result[propName] = jsonValues.length == 1
            ? jsonValues.first
            : jsonValues;
      }
    });
    return result;
  }

  SchemaEntity clone() {
    final Map<String, List<SchemaValue>> clonedProps = {};
    properties.forEach((key, list) {
      clonedProps[key] = list.map((v) {
        final val = v.value;
        return SchemaValue(
          id: v.id,
          value: val is SchemaEntity
              ? val.clone()
              : (val is Map ? Map.from(val) : val),
        );
      }).toList();
    });
    return SchemaEntity(
      id: id,
      type: type,
      properties: clonedProps,
      name: '${name} (Copy)',
    );
  }

  static SchemaEntity fromJsonLd(
    Map<String, dynamic> json, {
    String? defaultType,
    String? docName,
  }) {
    final String type =
        json['@type'].toString() ?? defaultType ?? 'schema:Thing';
    final String normalizedType = type.contains(':') ? type : 'schema:${type}';
    final Map<String, List<SchemaValue>> properties = {};
    json.forEach((key, val) {
      if (key == '@context' || key == '@type') {
        return;
      }
      final String propId = key.contains(':') ? key : 'schema:${key}';
      final List<SchemaValue> values = [];
      @NowaGenerated()
      void parseValue(dynamic singleVal) {
        if (singleVal is Map<String, dynamic>) {
          if (singleVal.containsKey('@id')) {
            final refId = singleVal['@id'].toString().replaceAll('#', '');
            values.add(
              SchemaValue(
                id:
                    DateTime.now().microsecondsSinceEpoch.toString() +
                    '_' +
                    singleVal.hashCode.toString(),
                value: {
                  '@id': refId,
                  'docName':
                      '${refId.replaceAll('doc_', 'Document ')} Reference',
                },
              ),
            );
          } else {
            values.add(
              SchemaValue(
                id:
                    DateTime.now().microsecondsSinceEpoch.toString() +
                    '_' +
                    singleVal.hashCode.toString(),
                value: SchemaEntity.fromJsonLd(singleVal),
              ),
            );
          }
        } else if (singleVal != null) {
          values.add(
            SchemaValue(
              id:
                  DateTime.now().microsecondsSinceEpoch.toString() +
                  '_' +
                  singleVal.hashCode.toString(),
              value: singleVal,
            ),
          );
        }
      }

      if (val is List) {
        for (var item in val) {
          parseValue(item);
        }
      } else {
        parseValue(val);
      }
      if (values.isNotEmpty) {
        properties[propId] = values;
      }
    });
    return SchemaEntity(
      id:
          DateTime.now().microsecondsSinceEpoch.toString() +
          '_' +
          json.hashCode.toString(),
      type: normalizedType,
      properties: properties,
      name: docName ?? '${type.split(':').last} Markup',
    );
  }
}
