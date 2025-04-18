import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  const ChatMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Görseldeki mesaj renkleri
    final Color userMessageColor = const Color(0xFF6A5CF5); // Mor
    final Color aiMessageColor = Colors.white;
    final Color userTextColor = Colors.white;
    final Color aiTextColor = Colors.black87;

    return Align(
      alignment: message.isUserMessage 
          ? Alignment.centerRight 
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isUserMessage ? userMessageColor : aiMessageColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUserMessage ? userTextColor : aiTextColor,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.4,
                locale: const Locale('tr', 'TR'),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "09:${message.isUserMessage ? "31" : "30"}", // Görseldeki saat bilgisi
                style: TextStyle(
                  fontSize: 12,
                  color: message.isUserMessage ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 