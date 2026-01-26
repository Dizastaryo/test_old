import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String? _selectedService;
  String? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _symptomsController = TextEditingController();

  final List<String> _services = [
    'Терапия',
    'Кардиология',
    'Неврология',
    'Стоматология',
    'Офтальмология',
    'Дерматология',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {'name': 'Др. Айдын Нурланов', 'specialty': 'Терапевт'},
    {'name': 'Др. Айжан Касымова', 'specialty': 'Кардиолог'},
    {'name': 'Др. Ерлан Сабитов', 'specialty': 'Невролог'},
    {'name': 'Др. Мария Ибрагимова', 'specialty': 'Стоматолог'},
  ];

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF3498DB),
            colorScheme: ColorScheme.light(primary: Color(0xFF3498DB)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Сброс времени при смене даты
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 32),
            SizedBox(width: 12),
            Text(
              'Запись создана!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Вы успешно записались на прием. Мы отправили вам подтверждение.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Сброс формы
              setState(() {
                _selectedService = null;
                _selectedDoctor = null;
                _selectedDate = null;
                _selectedTime = null;
                _symptomsController.clear();
              });
            },
            child: Text(
              'ОК',
              style: GoogleFonts.poppins(
                color: Color(0xFF3498DB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          'Запись на прием',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информационная карточка
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3498DB).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Выберите удобное время',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Заполните форму для записи к врачу',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: -0.2, end: 0),

            SizedBox(height: 24),

            // Выбор услуги
            _buildSectionTitle('Выберите услугу')
                .animate()
                .fadeIn(delay: 200.ms),
            SizedBox(height: 12),
            _buildServiceSelector()
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.2, end: 0),

            SizedBox(height: 24),

            // Выбор врача
            _buildSectionTitle('Выберите врача')
                .animate()
                .fadeIn(delay: 400.ms),
            SizedBox(height: 12),
            _buildDoctorSelector()
                .animate()
                .fadeIn(delay: 500.ms)
                .slideX(begin: -0.2, end: 0),

            SizedBox(height: 24),

            // Выбор даты
            _buildSectionTitle('Выберите дату')
                .animate()
                .fadeIn(delay: 600.ms),
            SizedBox(height: 12),
            _buildDateSelector()
                .animate()
                .fadeIn(delay: 700.ms)
                .slideX(begin: -0.2, end: 0),

            SizedBox(height: 24),

            // Выбор времени
            if (_selectedDate != null) ...[
              _buildSectionTitle('Выберите время')
                  .animate()
                  .fadeIn(delay: 800.ms),
              SizedBox(height: 12),
              _buildTimeSelector()
                  .animate()
                  .fadeIn(delay: 900.ms)
                  .slideX(begin: -0.2, end: 0),
              SizedBox(height: 24),
            ],

            // Симптомы/Жалобы
            _buildSectionTitle('Опишите симптомы (необязательно)')
                .animate()
                .fadeIn(delay: 1000.ms),
            SizedBox(height: 12),
            _buildSymptomsField()
                .animate()
                .fadeIn(delay: 1100.ms)
                .slideY(begin: 0.2, end: 0),

            SizedBox(height: 32),

            // Кнопка записи
            _buildSubmitButton()
                .animate()
                .fadeIn(delay: 1200.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _selectedService,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.medical_services, color: Color(0xFF3498DB)),
        ),
        hint: Text('Выберите услугу', style: GoogleFonts.poppins()),
        items: _services.map((service) {
          return DropdownMenuItem(
            value: service,
            child: Text(service, style: GoogleFonts.poppins()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedService = value;
          });
        },
      ),
    );
  }

  Widget _buildDoctorSelector() {
    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _selectedDoctor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person, color: Color(0xFF3498DB)),
        ),
        hint: Text('Выберите врача', style: GoogleFonts.poppins()),
        items: _doctors.map((doctor) {
          return DropdownMenuItem(
            value: doctor['name'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(doctor['name'], style: GoogleFonts.poppins()),
                Text(
                  doctor['specialty'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDoctor = value;
          });
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                    : 'Выберите дату',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _selectedDate != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final time = _timeSlots[index];
          final isSelected = _selectedTime == time;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTime = time;
              });
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF3498DB) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSymptomsField() {
    return Container(
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
      child: TextField(
        controller: _symptomsController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Опишите ваши симптомы или жалобы...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          contentPadding: EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _selectedService != null &&
        _selectedDoctor != null &&
        _selectedDate != null &&
        _selectedTime != null;

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              // Заглушка - просто показываем диалог успеха
              _showSuccessDialog();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3498DB),
        disabledBackgroundColor: Colors.grey[300],
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
      ),
      child: Text(
        'Записаться на прием',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
