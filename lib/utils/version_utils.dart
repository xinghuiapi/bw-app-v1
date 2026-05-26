class VersionUtils {
  const VersionUtils._();

  static int compare(String? remote, String? local) {
    final remoteParts = _parse(remote);
    final localParts = _parse(local);
    final maxLength = remoteParts.length > localParts.length
        ? remoteParts.length
        : localParts.length;

    for (var i = 0; i < maxLength; i++) {
      final remoteValue = i < remoteParts.length ? remoteParts[i] : 0;
      final localValue = i < localParts.length ? localParts[i] : 0;
      if (remoteValue != localValue) return remoteValue.compareTo(localValue);
    }
    return 0;
  }

  static bool isRemoteNewer(String? remote, String? local) {
    return compare(remote, local) > 0;
  }

  static String normalize(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '';
    return text.replaceFirst(RegExp(r'^[vV]'), '').trim();
  }

  static List<int> _parse(String? value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return const <int>[];

    return normalized
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList(growable: false);
  }
}
