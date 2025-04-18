import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';

class ConversationList extends ConsumerWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationProvider);
    final notifier = ref.read(conversationProvider.notifier);

    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz konuşma yok',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.startNewConversation(),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Konuşma Başlat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ConversationTile(
          conversation: conversation,
          isActive: state.activeConversation?.id == conversation.id,
        );
      },
    );
  }
}

class ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  final bool isActive;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(conversationProvider.notifier);
    final dateFormatter = DateFormat('dd MMM, HH:mm');
    
    return ListTile(
      title: Text(
        conversation.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        dateFormatter.format(conversation.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      leading: CircleAvatar(
        backgroundColor: isActive 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.surfaceVariant,
        child: Icon(
          Icons.chat_bubble_outline,
          color: isActive 
              ? Theme.of(context).colorScheme.onPrimary 
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      selected: isActive,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () => notifier.selectConversation(conversation.id),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konuşmayı Sil'),
              content: const Text('Bu konuşmayı silmek istediğinizden emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    notifier.deleteConversation(conversation.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Sil'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 