import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

// ── Data model ───────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageLocalPath; // for user-sent food images

  ChatMessage({required this.text, required this.isUser, this.imageLocalPath});
}

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  String get preview =>
      messages.isEmpty ? 'Empty chat' : messages.first.text.length > 40
          ? '${messages.first.text.substring(0, 40)}…'
          : messages.first.text;

  ChatSession({required this.id, required this.messages, required this.createdAt});
}

// ── Controller ───────────────────────────────────────────
class AiController extends ChangeNotifier {
  final AiService _service = AiService();

  // All sessions — persisted in memory for app lifetime
  final List<ChatSession> _sessions = [];
  int _activeSessionIndex = -1; // -1 = no active session yet

  bool _isLoading = false;
  String? _error;

  // ── Getters ───
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ChatMessage> get messages {
    if (_activeSessionIndex < 0 || _activeSessionIndex >= _sessions.length) {
      return [];
    }
    return _sessions[_activeSessionIndex].messages;
  }

  bool get hasActiveSession =>
      _activeSessionIndex >= 0 && _activeSessionIndex < _sessions.length;

  // ── Session management ───
  void startNewChat() {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [],
      createdAt: DateTime.now(),
    );
    _sessions.insert(0, session);
    _activeSessionIndex = 0;
    notifyListeners();
  }

  void switchToSession(int index) {
    if (index >= 0 && index < _sessions.length) {
      _activeSessionIndex = index;
      notifyListeners();
    }
  }

  void deleteSession(int index) {
    if (index < 0 || index >= _sessions.length) return;
    _sessions.removeAt(index);
    if (_sessions.isEmpty) {
      _activeSessionIndex = -1;
    } else if (_activeSessionIndex >= _sessions.length) {
      _activeSessionIndex = _sessions.length - 1;
    }
    notifyListeners();
  }

  void _ensureActiveSession() {
    if (!hasActiveSession) startNewChat();
  }

  void _addMessage(ChatMessage msg) {
    _ensureActiveSession();
    _sessions[_activeSessionIndex].messages.add(msg);
    notifyListeners();
  }

  // ── Send text ───
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _ensureActiveSession();

    _addMessage(ChatMessage(text: text, isUser: true));

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reply = await _service.sendMessage(text);
      _addMessage(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _error = e.toString();
      _addMessage(ChatMessage(text: "⚠️ Error: ${e.toString()}", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Send food image ───
  Future<void> sendFoodImage(File imageFile) async {
    _ensureActiveSession();

    _addMessage(ChatMessage(
      text: '📷 Analyzing food photo…',
      isUser: true,
      imageLocalPath: imageFile.path,
    ));

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.sendFoodImage(imageFile);
      final reply = result['reply'] as String;
      _addMessage(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _error = e.toString();
      _addMessage(ChatMessage(text: "⚠️ Image error: ${e.toString()}", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
