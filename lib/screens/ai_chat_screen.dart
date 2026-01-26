import 'package:flutter/material.dart';
import 'dart:async';

/// Экран чата с ИИ помощником
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Приветственное сообщение
    _messages.add(ChatMessage(
      text: 'Здравствуйте! Я ваш виртуальный помощник Qamqor Clinic. Чем могу помочь?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Имитация ответа ИИ
    Future.delayed(const Duration(milliseconds: 1000), () {
      _addAiResponse(text);
    });
  }

  void _addAiResponse(String userMessage) {
    String response = _generateAiResponse(userMessage.toLowerCase());
    
    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();
  }

  String _generateAiResponse(String message) {
    // Простая логика ответов (можно заменить на реальный AI API)
    if (message.contains('запись') || message.contains('записаться')) {
      return 'Для записи на прием перейдите на вкладку "Запись" в нижнем меню. Там вы сможете выбрать услугу, дату и время приема.';
    } else if (message.contains('услуг') || message.contains('что вы')) {
      return 'Мы предлагаем широкий спектр медицинских услуг:\n\n'
          '• Консультации врачей (терапевт, кардиолог, невролог)\n'
          '• Диагностика (УЗИ, анализы)\n'
          '• Лечебные процедуры (массаж, физиотерапия)\n\n'
          'Подробнее об услугах можно узнать на главной странице.';
    } else if (message.contains('цена') || message.contains('стоимость') || message.contains('сколько')) {
      return 'Стоимость услуг варьируется:\n\n'
          '• Консультации: от 5000 до 8000 ₸\n'
          '• Диагностика: от 2500 до 7000 ₸\n'
          '• Процедуры: от 5000 ₸\n\n'
          'Точную стоимость можно узнать при выборе услуги.';
    } else if (message.contains('адрес') || message.contains('где') || message.contains('локация')) {
      return 'Наша клиника находится по адресу:\n\n'
          '📍 г. Алматы, ул. Примерная, д. 123\n\n'
          'Мы работаем:\n'
          'Пн-Пт: 9:00 - 18:00\n'
          'Сб: 9:00 - 15:00\n'
          'Вс: Выходной';
    } else if (message.contains('привет') || message.contains('здравствуй')) {
      return 'Здравствуйте! Рад помочь вам. Задайте любой вопрос о наших услугах, записи на прием или работе клиники.';
    } else if (message.contains('спасибо') || message.contains('благодар')) {
      return 'Пожалуйста! Если у вас возникнут еще вопросы, обращайтесь. Будьте здоровы!';
    } else {
      return 'Спасибо за ваш вопрос! Я могу помочь вам с:\n\n'
          '• Информацией об услугах\n'
          '• Записью на прием\n'
          '• Стоимостью услуг\n'
          '• Адресом и режимом работы\n\n'
          'Задайте более конкретный вопрос, и я постараюсь помочь!';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Color(0xFF2E7D32)),
            ),
            SizedBox(width: 12),
            Text('Чат с ИИ помощником'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
