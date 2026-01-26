import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    final username = currentUser != null ? currentUser['username'] : 'Пользователь';
    final email = currentUser != null ? currentUser['email'] : 'user@qamqor.kz';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar с градиентом
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF2C3E50),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Профиль',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C3E50),
                      Color(0xFF34495E),
                      Color(0xFF3498DB),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Профиль пользователя
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3498DB).withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(delay: 100.ms, duration: 400.ms)
                      .fadeIn(delay: 100.ms),
                  SizedBox(height: 20),
                  Text(
                    username,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),

          // Мои записи
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'Мои записи',
                Icons.calendar_today,
                Color(0xFF3498DB),
                () {
                  // TODO: Навигация к записям
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Мои записи (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),

          // История посещений
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'История посещений',
                Icons.history,
                Color(0xFF9B59B6),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('История посещений (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Медицинские документы
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'Медицинские документы',
                Icons.folder,
                Color(0xFF27AE60),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Медицинские документы (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Настройки
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'Настройки',
                Icons.settings,
                Color(0xFFE67E22),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Настройки (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Политика конфиденциальности
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'Политика конфиденциальности',
                Icons.privacy_tip_outlined,
                Color(0xFF95A5A6),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Политика конфиденциальности (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Связаться с нами
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuItem(
                context,
                'Связаться с нами',
                Icons.support_agent,
                Color(0xFFE74C3C),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Связаться с нами (в разработке)')),
                  );
                },
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms)
                .slideX(begin: -0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Кнопка выхода
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout(context);
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Выйти из аккаунта',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE74C3C),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideY(begin: 0.2, end: 0),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
