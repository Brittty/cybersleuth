class NetworkCapture {
  final String id;
  final String timestamp;
  final String sourceIp;
  final String destIp;
  final String protocol;
  final int bytes;
  final String info;

  const NetworkCapture({
    required this.id,
    required this.timestamp,
    required this.sourceIp,
    required this.destIp,
    required this.protocol,
    this.bytes = 0,
    required this.info,
  });
}

class AccessLogEntry {
  final String id;
  final String timestamp;
  final String user;
  final String action;
  final String target;
  final String status;

  const AccessLogEntry({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.action,
    required this.target,
    required this.status,
  });
}

class EmailRecord {
  final String id;
  final String timestamp;
  final String from;
  final String to;
  final String subject;
  final String body;
  final List<String> attachments;
  final Map<String, String> headers;

  const EmailRecord({
    required this.id,
    required this.timestamp,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    this.attachments = const [],
    this.headers = const {},
  });
}
