import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/ai_controller.dart';
import '../widgets/auth_background.dart';
import '../core/widgets/glass_container.dart';

class AiAgentPage extends StatefulWidget {
  const AiAgentPage({super.key});

  @override
  State<AiAgentPage> createState() => _AiAgentPageState();
}

class _AiAgentPageState extends State<AiAgentPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<AiController>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1024,
    );
    if (picked == null || !mounted) return;
    await context.read<AiController>().sendFoodImage(File(picked.path));
    _scrollToBottom();
  }

  void _showImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Log Food from Photo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF5B3FE8)),
              title: Text('Take a Photo', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF5B3FE8)),
              title: Text('Choose from Gallery', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showHistoryDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HistoryDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiCtrl = context.watch<AiController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    const lime = Color(0xFFCCFF00);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('FitSync AI Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          // History button
          IconButton(
            icon: Icon(Icons.history_rounded, color: isDark ? lime : purple),
            tooltip: 'Chat history',
            onPressed: _showHistoryDrawer,
          ),
          // New chat button
          IconButton(
            icon: Icon(Icons.add_comment_rounded, color: isDark ? lime : purple),
            tooltip: 'New chat',
            onPressed: () {
              context.read<AiController>().startNewChat();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AuthBackground(
          child: Column(
            children: [
              // ── Messages ──
              if (aiCtrl.messages.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          color: isDark ? lime : purple,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'How can I help you today?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask about nutrition, workouts,\nor tap 📷 to log food from a photo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: aiCtrl.messages.length,
                    itemBuilder: (context, index) {
                      final msg = aiCtrl.messages[index];
                      return _ChatBubble(message: msg);
                    },
                  ),
                ),

              // ── Loading indicator ──
              if (aiCtrl.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFCCFF00),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FitSync AI is thinking…',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Input row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  borderRadius: BorderRadius.circular(30),
                  blur: isDark ? 15 : 0,
                  opacity: isDark ? 0.12 : 0,
                  child: Row(
                    children: [
                      // Camera / gallery button
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          color: isDark ? lime.withValues(alpha: 0.8) : purple.withValues(alpha: 0.7),
                        ),
                        onPressed: aiCtrl.isLoading ? null : _showImageSourceSheet,
                        tooltip: 'Log food from photo',
                      ),
                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Ask your AI coach…',
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      // Send button
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: isDark ? lime : purple),
                        onPressed: aiCtrl.isLoading ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Chat bubble
// ──────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Image thumbnail if present
            if (message.imageLocalPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(message.imageLocalPath!),
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.imageLocalPath != null) const SizedBox(height: 6),
            // Text bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? (isDark ? const Color(0xFFCCFF00).withValues(alpha: 0.9) : const Color(0xFF5B3FE8))
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? (isDark ? Colors.black87 : Colors.white)
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Chat history drawer (bottom sheet)
// ──────────────────────────────────────────────
class _HistoryDrawer extends StatelessWidget {
  const _HistoryDrawer();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AiController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chat History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ctrl.startNewChat();
                  },
                  icon: const Icon(Icons.add_comment_rounded, size: 16),
                  label: const Text('New Chat'),
                  style: TextButton.styleFrom(foregroundColor: purple),
                ),
              ],
            ),
          ),
          const Divider(),
          // Session list
          ctrl.sessions.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      'No conversations yet.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: ctrl.sessions.length,
                    itemBuilder: (context, index) {
                      final session = ctrl.sessions[index];
                      final isActive = ctrl.sessions.indexOf(session) == 0 &&
                          ctrl.messages == session.messages;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? (isDark ? const Color(0xFFCCFF00) : purple)
                              : Colors.grey.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 16,
                            color: isActive
                                ? (isDark ? Colors.black87 : Colors.white)
                                : (isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                        title: Text(
                          session.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _formatTime(session.createdAt),
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: Colors.red.withValues(alpha: 0.7), size: 20),
                          onPressed: () {
                            ctrl.deleteSession(index);
                            if (ctrl.sessions.isEmpty) Navigator.pop(context);
                          },
                        ),
                        onTap: () {
                          ctrl.switchToSession(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
