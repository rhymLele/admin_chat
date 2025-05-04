class Message {
  final String chatId;
  final DateTime time;
  final String receiverId;
  final String senderId;
  final String message;
  final String? senderName;
  final String? senderImage;

  Message({
    required this.chatId,
    required this.time,
    required this.receiverId,
    required this.senderId,
    required this.message,
    this.senderName,
    this.senderImage,
  });

 factory Message.fromRTDB(String key, Map<String, dynamic> data) {
  final rawTime = data['dateTime'];
  late DateTime dateTime;

  if (rawTime is int || rawTime is double) {
    dateTime = DateTime.fromMillisecondsSinceEpoch(rawTime.toInt());
  } else if (rawTime is Map && rawTime.containsKey('time')) {
    final timestamp = rawTime['time'];
    if (timestamp is int || timestamp is double) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    } else {
      dateTime = DateTime.now(); // fallback
    }
  } else {
    dateTime = DateTime.now(); // fallback
  }

  return Message(
    chatId: key,
    time: dateTime,
    receiverId: data['receiverID'] ?? '',
    senderId: data['senderID'] ?? '',
    message: data['message'] ?? '',
    senderName: data['senderName'],
    senderImage: data['senderImage'],
  );
}

}
