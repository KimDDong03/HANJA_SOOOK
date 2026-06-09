import 'dart:math' as math;
import 'dart:ui';

class SvgPathParser {
  const SvgPathParser._();

  static Path parse(String pathData) {
    final parser = _SvgPathParser(pathData);
    return parser.parse();
  }

  static Path? tryParse(String pathData) {
    try {
      final path = parse(pathData);
      if (path.computeMetrics().isEmpty) {
        return null;
      }
      return path;
    } on FormatException {
      return null;
    }
  }
}

class _SvgPathParser {
  _SvgPathParser(String pathData) : _tokens = _tokenize(pathData);

  static final RegExp _tokenPattern = RegExp(
    r'[MmLlHhVvCcSsQqTtZz]|[-+]?(?:(?:\d*\.\d+)|(?:\d+\.?))(?:[eE][-+]?\d+)?',
  );

  static List<String> _tokenize(String pathData) {
    return _tokenPattern
        .allMatches(pathData)
        .map((match) => match.group(0)!)
        .toList();
  }

  final List<String> _tokens;
  int _index = 0;
  String? _command;
  double _x = 0;
  double _y = 0;
  double _subPathStartX = 0;
  double _subPathStartY = 0;
  Offset? _lastCubicControlPoint;
  Offset? _lastQuadraticControlPoint;

  bool get _hasMore => _index < _tokens.length;

  Path parse() {
    final path = Path();

    while (_hasMore) {
      if (_isCommand(_peek)) {
        _command = _next;
      }

      final command = _command;
      if (command == null) {
        throw const FormatException('SVG path must start with a command');
      }

      switch (command) {
        case 'M':
        case 'm':
          _moveTo(path, command == 'M');
        case 'L':
        case 'l':
          _lineTo(path, command == 'L');
        case 'H':
        case 'h':
          _horizontalLineTo(path, command == 'H');
        case 'V':
        case 'v':
          _verticalLineTo(path, command == 'V');
        case 'C':
        case 'c':
          _cubicTo(path, command == 'C');
        case 'S':
        case 's':
          _smoothCubicTo(path, command == 'S');
        case 'Q':
        case 'q':
          _quadraticTo(path, command == 'Q');
        case 'T':
        case 't':
          _smoothQuadraticTo(path, command == 'T');
        case 'Z':
        case 'z':
          path.close();
          _x = _subPathStartX;
          _y = _subPathStartY;
          _lastCubicControlPoint = null;
          _lastQuadraticControlPoint = null;
          _command = null;
        default:
          throw FormatException('Unsupported SVG command: $command');
      }
    }

    return path;
  }

  String get _peek => _tokens[_index];

  String get _next => _tokens[_index++];

  bool _isCommand(String token) {
    return token.length == 1 && RegExp(r'[A-Za-z]').hasMatch(token);
  }

  bool _hasNumber() {
    return _hasMore && !_isCommand(_peek);
  }

  double _number() {
    if (!_hasNumber()) {
      throw const FormatException('Expected SVG path number');
    }
    return double.parse(_next);
  }

  Offset _point(bool absolute) {
    final x = _number();
    final y = _number();
    return absolute ? Offset(x, y) : Offset(_x + x, _y + y);
  }

  void _moveTo(Path path, bool absolute) {
    var first = true;
    while (_hasNumber()) {
      final point = _point(absolute);
      if (first) {
        path.moveTo(point.dx, point.dy);
        _subPathStartX = point.dx;
        _subPathStartY = point.dy;
        first = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
      _x = point.dx;
      _y = point.dy;
    }
    _command = absolute ? 'L' : 'l';
    _clearControls();
  }

  void _lineTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final point = _point(absolute);
      path.lineTo(point.dx, point.dy);
      _x = point.dx;
      _y = point.dy;
    }
    _clearControls();
  }

  void _horizontalLineTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final x = _number();
      _x = absolute ? x : _x + x;
      path.lineTo(_x, _y);
    }
    _clearControls();
  }

  void _verticalLineTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final y = _number();
      _y = absolute ? y : _y + y;
      path.lineTo(_x, _y);
    }
    _clearControls();
  }

  void _cubicTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final point1 = _point(absolute);
      final point2 = _point(absolute);
      final point3 = _point(absolute);
      path.cubicTo(
        point1.dx,
        point1.dy,
        point2.dx,
        point2.dy,
        point3.dx,
        point3.dy,
      );
      _x = point3.dx;
      _y = point3.dy;
      _lastCubicControlPoint = point2;
      _lastQuadraticControlPoint = null;
    }
  }

  void _smoothCubicTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final reflected = _reflect(_lastCubicControlPoint);
      final point2 = _point(absolute);
      final point3 = _point(absolute);
      path.cubicTo(
        reflected.dx,
        reflected.dy,
        point2.dx,
        point2.dy,
        point3.dx,
        point3.dy,
      );
      _x = point3.dx;
      _y = point3.dy;
      _lastCubicControlPoint = point2;
      _lastQuadraticControlPoint = null;
    }
  }

  void _quadraticTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final point1 = _point(absolute);
      final point2 = _point(absolute);
      path.quadraticBezierTo(point1.dx, point1.dy, point2.dx, point2.dy);
      _x = point2.dx;
      _y = point2.dy;
      _lastQuadraticControlPoint = point1;
      _lastCubicControlPoint = null;
    }
  }

  void _smoothQuadraticTo(Path path, bool absolute) {
    while (_hasNumber()) {
      final reflected = _reflect(_lastQuadraticControlPoint);
      final point = _point(absolute);
      path.quadraticBezierTo(reflected.dx, reflected.dy, point.dx, point.dy);
      _x = point.dx;
      _y = point.dy;
      _lastQuadraticControlPoint = reflected;
      _lastCubicControlPoint = null;
    }
  }

  Offset _reflect(Offset? controlPoint) {
    if (controlPoint == null) {
      return Offset(_x, _y);
    }
    return Offset(2 * _x - controlPoint.dx, 2 * _y - controlPoint.dy);
  }

  void _clearControls() {
    _lastCubicControlPoint = null;
    _lastQuadraticControlPoint = null;
  }
}

extension HanjaPathBounds on Iterable<Path> {
  Rect combinedBounds() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return const Rect.fromLTWH(0, 0, 109, 109);
    }

    var bounds = iterator.current.getBounds();
    while (iterator.moveNext()) {
      bounds = bounds.expandToInclude(iterator.current.getBounds());
    }

    if (bounds.isEmpty || bounds.width == 0 || bounds.height == 0) {
      return const Rect.fromLTWH(0, 0, 109, 109);
    }
    return bounds.inflate(math.max(bounds.width, bounds.height) * 0.08);
  }
}
