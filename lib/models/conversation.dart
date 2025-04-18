import 'dart:convert';
import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  // JSON serileştirme için yardımcı metodlar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      messages: (json['messages'] as List)
          .map((item) => Message.fromJson(item))
          .toList(),
    );
  }

  // Başlık olmaması durumunda ilk kullanıcı mesajının kısaltılmış halini kullan
  String get displayTitle {
    if (title.isNotEmpty) return title;
    
    final firstUserMessage = messages.firstWhere(
      (message) => message.isUserMessage, 
      orElse: () => Message(content: 'Yeni Konuşma', isUserMessage: true)
    );
    
    if (firstUserMessage.content.length > 30) {
      return '${firstUserMessage.content.substring(0, 27)}...';
    }
    return firstUserMessage.content;
  }
} 