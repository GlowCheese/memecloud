Map ignoreNullValuesOfMap(Map map) {
  return Map.fromEntries(
    map.entries.where((e) => e.value != null),
  ).cast<String, dynamic>();
}
