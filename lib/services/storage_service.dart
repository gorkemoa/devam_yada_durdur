import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class StorageService {
  static const String _conversationsKey = 'conversations';

  // Tüm konuşmaları getir
  Future<List<Conversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? conversationsJson = prefs.getString(_conversationsKey);
    
    if (conversationsJson == null) {
      return [];
    }
    
    final List<dynamic> decodedList = jsonDecode(conversationsJson);
    return decodedList
        .map((item) => Conversation.fromJson(item))
        .toList();
  }

  // Belirli bir konuşmayı ID'ye göre getir
  Future<Conversation?> getConversation(String id) async {
    final conversations = await getConversations();
    try {
      return conversations.firstWhere((conversation) => conversation.id == id);
    } catch (e) {
      return null;
    }
  }

  // Yeni konuşma ekle veya mevcut konuşmayı güncelle
  Future<void> saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Conversation> conversations = await getConversations();
    
    // Mevcut konuşmayı güncelle veya yeni konuşma ekle
    final existingIndex = conversations.indexWhere((c) => c.id == conversation.id);
    if (existingIndex >= 0) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.add(conversation);
    }
    
    // JSON olarak kaydet
    final String encodedList = jsonEncode(
      conversations.map((c) => c.toJson()).toList()
    );
    
    await prefs.setString(_conversationsKey, encodedList);
  }

  // Konuşmayı sil
  Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Conversation> conversations = await getConversations();
    
    conversations.removeWhere((conversation) => conversation.id == id);
    
    final String encodedList = jsonEncode(
      conversations.map((c) => c.toJson()).toList()
    );
    
    await prefs.setString(_conversationsKey, encodedList);
  }

  // Tüm konuşmaları sil
  Future<void> clearAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationsKey);
  }
} 