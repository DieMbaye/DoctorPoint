import 'package:doctor_point/calls/call_ended_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../home/home_screen.dart';
class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  const ChatScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> messages = [
    {
      'text': 'Bonjour, comment puis-je vous aider ?',
      'sender': 'doctor',
      'time': '10:00',
    },
    {
      'text': 'Bonjour Docteur, j\'ai des maux de tête persistants.',
      'sender': 'user',
      'time': '10:02',
    },
  ];

  Future<void> _endChat() async {
    await _firestore.collection('notifications').add({
      'userId': _auth.currentUser!.uid,
      'title': 'Discussion terminée',
      'message': 'Votre discussion avec ${widget.doctorName} est terminée avec succès.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallEndedScreen(
          doctorName: widget.doctorName,
          type: 'message',
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;

    final newMessage = {
      'text': _msgCtrl.text.trim(),
      'sender': 'user',
      'time': DateFormat('HH:mm').format(DateTime.now()),
    };

    setState(() {
      messages.add(newMessage);
      _msgCtrl.clear();
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate doctor reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          messages.add({
            'text': 'Je comprends. Pouvez-vous me décrire la douleur ?',
            'sender': 'doctor',
            'time': DateFormat('HH:mm').format(DateTime.now()),
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: widget.doctorPhoto.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.doctorPhoto),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: widget.doctorPhoto.isEmpty
                  ? Center(
                      child: Text(
                        widget.doctorName[0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.call_rounded, size: 22),
            onPressed: () {
              // TODO: Initiate call
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam_rounded, size: 22),
            onPressed: () {
              // TODO: Initiate video call
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'end') _endChat();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'end',
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('Terminer la discussion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          /// Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: widget.doctorPhoto.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(widget.doctorPhoto),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                          child: widget.doctorPhoto.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.doctorName[0],
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time'],
                                style: TextStyle(
                                  color: isUser ? Colors.white.withOpacity(0.8) : AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'U',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          /// Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file_rounded, color: AppColors.primary),
                  onPressed: () {
                    // TODO: Attach file
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}