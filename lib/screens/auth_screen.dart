import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _autoLogin() async {
    setState(() => _loading = true);
    
    // Заглушка - автоматический вход
    final auth = context.read<AuthProvider>();
    await auth.mockLogin();
    
    setState(() => _loading = false);
    
    // Переходим на главный экран
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Градиентный фон
          Container(
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

          // Контент
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        size: 70,
                        color: Color(0xFF3498DB),
                      ),
                    )
                        .animate()
                        .scale(delay: 100.ms, duration: 600.ms)
                        .fadeIn(delay: 100.ms),

                    SizedBox(height: 32),

                    // Название
                    Text(
                      'Qamqor Clinic',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: -0.2, end: 0),

                    SizedBox(height: 12),

                    Text(
                      'Добро пожаловать!',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: -0.2, end: 0),

                    SizedBox(height: 48),

                    // Карточка с формой
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 12,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: Color(0xFF3498DB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Color(0xFF3498DB),
                              labelStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: const [
                                Tab(text: 'Вход'),
                                Tab(text: 'Регистрация'),
                              ],
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginTab(),
                                  _buildRegisterTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 24),

                    // Кнопка быстрого входа (заглушка)
                    TextButton(
                      onPressed: _autoLogin,
                      child: Text(
                        'Быстрый вход (демо)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),

          // Индикатор загрузки
          if (_loading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Для демо-режима используйте кнопку "Быстрый вход"',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: _autoLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3498DB),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Войти',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Регистрация временно недоступна. Используйте быстрый вход для демо.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: _autoLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3498DB),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Быстрый вход',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
