part of packme.compiler;

const String RED = '\x1b[31m';
const String GREEN = '\x1b[32m';
const String YELLOW = '\x1b[33m';
const String RESET = '\x1b[0m';

/// Reserved names you can't use as field names or enum values.
const List<String> _reservedNames = <String>[
    'assert', 'bool', 'break', 'case', 'catch', 'class', 'const', 'continue', 'covariant',
    'DateTime', 'default', 'deferred', 'do', 'double', 'else', 'enum', 'export', 'extends',
    'extension', 'external', 'factory', 'false', 'final', 'finally', 'for', 'if', 'in', 'int',
    'is', 'Iterable', 'List', 'Map', 'new', 'Null', 'null', 'PackMe', 'PackMeMessage', 'rethrow',
    'return', 'Set', 'super', 'switch', 'this', 'throw', 'true', 'try', 'values', 'var', 'void',
    'while', 'with', 'hashCode', 'noSuchMethod', 'runtimeType', 'String', 'toString', 'Uint8List'
];

/// Check if name is reserved by Dart language.
bool isReserved(String name) {
    return _reservedNames.contains(name);
}

/// Converts lower case names with underscore to UpperCamelCase (for classes) or
/// lowerCamelCase (for class fields).
String validName(String input, { bool firstCapital = false }) {
    RegExp re = firstCapital ? RegExp(r'^[a-z]|[^a-zA-Z][a-z]') : RegExp(r'[^a-zA-Z\?][a-z]');
    String result = input.replaceAllMapped(re, (Match match) => match.group(0)!.toUpperCase());
    re = RegExp(r'^\??\d+|[^a-zA-Z0-9]');
    result = result.replaceAll(re, '');
    return result;
}

/// Auto indents.
List<String> formatCode(List<String> lines) {
    int indent = 0;
    final RegExp reOpen = RegExp(r'\{[^\}]*$');
    final RegExp reClose = RegExp(r'^[^\{]*\}');
    final RegExp reEmpty = RegExp(r'^\s*$');
    for (int i = 0; i < lines.length; i++) {
        final bool increase = reOpen.hasMatch(lines[i]);
        final bool decrease = reClose.hasMatch(lines[i]);
        if (decrease) indent--;
        if (!reEmpty.hasMatch(lines[i])) lines[i] = '\t' * indent + lines[i];
        if (increase) indent++;
    }
    return lines;
}

/// Plural to singular rules
Map<RegExp, String Function(Match)> _singularRules = <RegExp, String Function(Match)>{
    RegExp(r'men$', caseSensitive: false): (Match m) => 'man',
    RegExp(r'(eau)x?$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r'(child)ren$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r'(pe)(rson|ople)$', caseSensitive: false): (Match m) => '${m.group(1)}rson',
    RegExp(r'(matr|append)ices$', caseSensitive: false): (Match m) => '${m.group(1)}ix',
    RegExp(r'(cod|mur|sil|vert|ind)ices$', caseSensitive: false): (Match m) => '${m.group(1)}ex',
    RegExp(r'(alumn|alg|vertebr)ae$', caseSensitive: false): (Match m) => '${m.group(1)}a',
    RegExp(r'(apheli|hyperbat|periheli|asyndet|noumen|phenomen|criteri|organ|prolegomen|hedr|automat)a$', caseSensitive: false): (Match m) => '${m.group(1)}on',
    RegExp(r'(agend|addend|millenni|dat|extrem|bacteri|desiderat|strat|candelabr|errat|ov|symposi|curricul|quor)a$', caseSensitive: false): (Match m) => '${m.group(1)}um',
    RegExp(r'(alumn|syllab|vir|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)(?:us|i)$', caseSensitive: false): (Match m) => '${m.group(1)}us',
    RegExp(r'(test)(?:is|es)$', caseSensitive: false): (Match m) => '${m.group(1)}is',
    RegExp(r'(movie|twelve|abuse|e[mn]u)s$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r'(analy|diagno|parenthe|progno|synop|the|empha|cri|ne)(?:sis|ses)$', caseSensitive: false): (Match m) => '${m.group(1)}sis',
    RegExp(r'(x|ch|ss|sh|zz|tto|go|cho|alias|[^aou]us|t[lm]as|gas|(?:her|at|gr)o|[aeiou]ris)(?:es)?$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r'(seraph|cherub)im$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r'\b((?:tit)?m|l)ice$', caseSensitive: false): (Match m) => '${m.group(1)}ouse',
    RegExp(r'\b(mon|smil)ies$', caseSensitive: false): (Match m) => '${m.group(1)}ey',
    RegExp(r'\b(l|(?:neck|cross|hog|aun)?t|coll|faer|food|gen|goon|group|hipp|junk|vegg|(?:pork)?p|charl|calor|cut)ies$', caseSensitive: false): (Match m) => '${m.group(1)}ie',
    RegExp(r'(dg|ss|ois|lk|ok|wn|mb|th|ch|ec|oal|is|ck|ix|sser|ts|wb)ies$', caseSensitive: false): (Match m) => '${m.group(1)}ie',
    RegExp(r'ies$', caseSensitive: false): (Match m) => 'y',
    RegExp(r'(ar|(?:wo|[ae])l|[eo][ao])ves$', caseSensitive: false): (Match m) => '${m.group(1)}f',
    RegExp(r'(wi|kni|(?:after|half|high|low|mid|non|night|[^\w]|^)li)ves$', caseSensitive: false): (Match m) => '${m.group(1)}fe',
    RegExp(r'(ss)$', caseSensitive: false): (Match m) => '${m.group(1)}',
    RegExp(r's$', caseSensitive: false): (Match m) => '',
};

/// Return singular form of plural.
String toSingular(String plural) {
    final RegExp isAbbr = RegExp(r'[A-Z0-9]$');
    if (isAbbr.hasMatch(plural)) return plural;
    String singular = plural;
    for (final RegExp re in _singularRules.keys) {
        if (re.hasMatch(plural)) {
            singular = plural.replaceFirstMapped(re, _singularRules[re]!);
            break;
        }
    }
    return singular;
}
