part of packme.compiler;

const String RED = '\x1b[31m';
const String RESET = '\x1b[0m';

void fatal(String message) {
    print('$RED$message$RESET');
    exit(-1);
}

/// How many bytes required to store.

Map<String, int> sizeOf = <String, int>{
    'bool': 1,
    'int8': 1,
    'uint8': 1,
    'int16': 2,
    'uint16': 2,
    'int32': 4,
    'uint32': 4,
    'int64': 8,
    'uint64': 8,
    'float': 4,
    'double': 8,
    'datetime': 8,
};

/// Converts lower case names with underscore to UpperCamelCase (for classes) or
/// lowerCamelCase (for class fields).

String validName(String input, {bool firstCapital = false}) {
    RegExp re = firstCapital ? RegExp(r'^[a-z]|[^a-zA-Z][a-z]') : RegExp(r'[^a-zA-Z\?][a-z]');
    String result = input.replaceAllMapped(re, (Match match) => match.group(0)!.toUpperCase());
    re = RegExp(r'[^a-zA-Z0-9]');
    result = result.replaceAll(re, '');
    return result;
}

List<String> format(List<String> lines) {
    int indent = 0;
    final RegExp reOpen = RegExp(r'\{');
    final RegExp reClose = RegExp(r'\}');
    for (int i = 0; i < lines.length; i++) {
        final int change = indent += reOpen.allMatches(lines[i]).length - reClose.allMatches(lines[i]).length;
        if (change < 0) indent += change;
        lines[i] = '\t' * indent + lines[i];
        if (change > 0) indent += change;
    }
    return lines;
}