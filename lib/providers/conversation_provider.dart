import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/storage_service.dart';
import '../services/openai_service.dart';

// Konuşma durumu
class ConversationState {
  final List<Conversation> conversations;
  final Conversation? activeConversation;
  final bool isLoading;

  ConversationState({
    this.conversations = const [],
    this.activeConversation,
    this.isLoading = false,
  });

  ConversationState copyWith({
    List<Conversation>? conversations,
    Conversation? activeConversation,
    bool? isLoading,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Konuşma Notifier
class ConversationNotifier extends StateNotifier<ConversationState> {
  final StorageService _storageService;
  final OpenAIService _openAIService;
  final _uuid = const Uuid();

  ConversationNotifier(this._storageService, this._openAIService)
      : super(ConversationState()) {
    _loadConversations();
  }

  // Konuşmaları yükle
  Future<void> _loadConversations() async {
    final conversations = await _storageService.getConversations();
    state = state.copyWith(conversations: conversations);
  }

  // Yeni konuşma başlat
  Future<void> startNewConversation() async {
    final newConversation = Conversation(
      id: _uuid.v4(),
      title: '',
      createdAt: DateTime.now(),
      messages: [
        Message(
          content: "Ürün fikrini anlat. Tek satırlık açıklama, hedef kullanıcı ve nasıl para kazanacağını söyle. Romantikleştirme.",
          isUserMessage: false,
        ),
      ],
    );

    await _storageService.saveConversation(newConversation);
    await _loadConversations();
    state = state.copyWith(activeConversation: newConversation);
  }

  // Konuşma seç
  Future<void> selectConversation(String conversationId) async {
    final conversation = await _storageService.getConversation(conversationId);
    state = state.copyWith(activeConversation: conversation);
  }

  // Kullanıcı mesajını gönder ve AI cevabını al
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Aktif konuşma yoksa yeni oluştur
    if (state.activeConversation == null) {
      await startNewConversation();
    }
    
    final currentConversation = state.activeConversation!;
    
    // Kullanıcı mesajını ekle
    final userMessage = Message(content: content, isUserMessage: true);
    
    final updatedMessages = [...currentConversation.messages, userMessage];
    final updatedConversation = Conversation(
      id: currentConversation.id,
      title: currentConversation.title,
      createdAt: currentConversation.createdAt,
      messages: updatedMessages,
    );
    
    // Durum güncelleme
    state = state.copyWith(
      activeConversation: updatedConversation,
      isLoading: true,
    );
    
    await _storageService.saveConversation(updatedConversation);
    
    try {
      // AI cevabını al
      final response = await _openAIService.generateProductEvaluation(content);
      
      // AI mesajını ekle
      final aiMessage = Message(content: response, isUserMessage: false);
      final finalMessages = [...updatedMessages, aiMessage];
      
      final finalConversation = Conversation(
        id: currentConversation.id,
        title: currentConversation.title.isEmpty ? _generateTitle(content) : currentConversation.title,
        createdAt: currentConversation.createdAt,
        messages: finalMessages,
      );
      
      // Durum güncelleme
      state = state.copyWith(
        activeConversation: finalConversation,
        isLoading: false,
      );
      
      await _storageService.saveConversation(finalConversation);
      await _loadConversations();
    } catch (e) {
      // Hata mesajı ekle
      final errorMessage = Message(
        content: "Bir hata oluştu: $e",
        isUserMessage: false,
      );
      
      final finalMessages = [...updatedMessages, errorMessage];
      
      final finalConversation = Conversation(
        id: currentConversation.id,
        title: currentConversation.title,
        createdAt: currentConversation.createdAt,
        messages: finalMessages,
      );
      
      state = state.copyWith(
        activeConversation: finalConversation,
        isLoading: false,
      );
      
      await _storageService.saveConversation(finalConversation);
    }
  }

  // Konuşmayı sil
  Future<void> deleteConversation(String conversationId) async {
    await _storageService.deleteConversation(conversationId);
    
    // Eğer aktif konuşma silindiyse, aktif konuşmayı null yap
    if (state.activeConversation?.id == conversationId) {
      state = state.copyWith(activeConversation: null);
    }
    
    await _loadConversations();
  }
  
  // Konuşma başlığı oluştur
  String _generateTitle(String content) {
    if (content.length <= 30) return content;
    return '${content.substring(0, 27)}...';
  }
}

// Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

final conversationProvider = StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final openAIService = ref.watch(openAIServiceProvider);
  return ConversationNotifier(storageService, openAIService);
}); 