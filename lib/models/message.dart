class Message {
  final String content;
  final bool isUserMessage;

  Message({required this.content, required this.isUserMessage});
  
  // JSON serileştirme için yardımcı metodlar
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUserMessage': isUserMessage,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      isUserMessage: json['isUserMessage'],
    );
  }
} 