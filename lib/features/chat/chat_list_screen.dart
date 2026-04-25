import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/design.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeeUColors.background,
      appBar: AppBar(
        title: Text(
          'Сообщения',
          style: SeeUTypography.title,
        ),
        backgroundColor: SeeUColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '0',
                style: GoogleFonts.fraunces(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                  color: SeeUColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ваши сообщения',
                style: SeeUTypography.title,
              ),
              const SizedBox(height: 8),
              Text(
                'Отправляйте сообщения друзьям.\nНачните общение!',
                textAlign: TextAlign.center,
                style: SeeUTypography.body.copyWith(
                  color: SeeUColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SeeUButton(
                label: 'Начать общение',
                variant: SeeUButtonVariant.ghost,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
