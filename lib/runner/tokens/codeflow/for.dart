part of arrow_tokens;

class ArrowForToken extends ArrowToken {
  String varname;
  ArrowToken toIter;
  ArrowToken body;

  ArrowForToken(this.varname, this.toIter, this.body, super.vm, super.file, super.line);

  @override
  List<String> dependencies(List<String> toIgnore) {
    final l = <String>[];

    l.addAll(toIter.dependencies(toIgnore));
    l.addAll(body.dependencies([...toIgnore, varname]));

    return l;
  }

  @override
  ArrowResource get(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace) {
    run(locals, globals, stackTrace);
    return ArrowNull();
  }

  @override
  String get name => "for($varname in ${toIter.name}) <${body.name}>";

  @override
  void run(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace) {
    final size = locals.size;

    final l = toIter.get(locals, globals, stackTrace);

    if (l is ArrowList) {
      for (var element in l.elements) {
        locals.define(varname, element);
        stackTrace.push(ArrowStackTraceElement("For Loop Body", file, line));
        body.run(locals, globals, stackTrace);
        if (locals.has("")) break;
        stackTrace.pop();
        locals.removeAmount(1);
      }
    } else if (l is ArrowMap) {
      l.map.forEach((key, value) {
        locals.define(varname, value);
        stackTrace.push(ArrowStackTraceElement("For Loop Body", file, line));
        body.run(locals, globals, stackTrace);
        if (locals.has("")) return;
        stackTrace.pop();
        locals.removeAmount(1);
      });
    } else {
      stackTrace.crash(ArrowStackTraceElement("Attempt to iterate value with no iterator", file, line));
    }

    final returned = locals.getByName("");
    locals.removeAmount(locals.size - size);
    if (returned != null) locals.define("", returned);
  }

  @override
  void set(ArrowLocals locals, ArrowGlobals globals, ArrowStackTrace stackTrace, ArrowResource other) {
    run(locals, globals, stackTrace);
  }

  @override
  ArrowToken get optimized => ArrowForToken(varname, toIter.optimized, body.optimized, vm, file, line);
}
