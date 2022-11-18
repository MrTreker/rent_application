class MessageException implements Exception {
  String _message;
  MessageException(this._message);

  @override
  toString() => _message;

  String get message => _message;
}
