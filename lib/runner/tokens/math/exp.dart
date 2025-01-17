part of arrow_tokens;

class ArrowExpToken extends ArrowToken {
  ArrowToken left;
  ArrowToken right;

  ArrowExpToken(this.left, this.right, super.vm, super.file, super.line);

  @override
  List<String> dependencies(List<String> toIgnore) {
    return {...left.dependencies(toIgnore), ...right.dependencies(toIgnore)}.toList();
  }

  @override
  ArrowResource get(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace) {
    final l = left.get(locals, globals, stackTrace);
    final r = right.get(locals, globals, stackTrace);

    stackTrace.push(ArrowStackTraceElement("Power", file, line));
    final result = l.power(r, stackTrace, file, line);
    stackTrace.pop();

    return result;
  }

  @override
  String get name => "power";

  @override
  void run(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace) {
    get(locals, globals, stackTrace);
  }

  @override
  void set(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace, ArrowResource other) {
    get(locals, globals, stackTrace);
  }

  @override
  ArrowToken get optimized {
    final oleft = left.optimized;
    final oright = right.optimized;

    if (oleft is ArrowNumberToken && oright is ArrowNumberToken) {
      return ArrowNumberToken(pow(oleft.n, oright.n).toDouble(), vm, file, line);
    }

    return ArrowAdditionToken(oleft, oright, vm, file, line);
  }
}
