import '../models/user.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/notification_model.dart';
import '../models/medical_record.dart';
import '../models/promotion.dart';

class MockData {
  // Моковые врачи
  static List<Doctor> getDoctors() {
    return [
      Doctor(
        id: '1',
        name: 'Доктор Айбек Нурланов',
        specialization: 'Терапевт',
        description: 'Опытный терапевт с 15-летним стажем. Специализируется на лечении заболеваний внутренних органов.',
        rating: 4.8,
        experienceYears: 15,
        languages: ['Қазақша', 'Русский', 'English'],
      ),
      Doctor(
        id: '2',
        name: 'Доктор Алия Смагулова',
        specialization: 'Кардиолог',
        description: 'Врач-кардиолог высшей категории. Эксперт в области диагностики и лечения сердечно-сосудистых заболеваний.',
        rating: 4.9,
        experienceYears: 12,
        languages: ['Қазақша', 'Русский'],
      ),
      Doctor(
        id: '3',
        name: 'Доктор Нурлан Касымов',
        specialization: 'Невролог',
        description: 'Специалист по заболеваниям нервной системы. Лечение головных болей, мигреней, неврологических расстройств.',
        rating: 4.7,
        experienceYears: 10,
        languages: ['Қазақша', 'Русский', 'English'],
      ),
      Doctor(
        id: '4',
        name: 'Доктор Мадина Абдуллаева',
        specialization: 'Педиатр',
        description: 'Детский врач с большим опытом работы. Специализируется на лечении детей всех возрастов.',
        rating: 4.9,
        experienceYears: 8,
        languages: ['Қазақша', 'Русский'],
      ),
      Doctor(
        id: '5',
        name: 'Доктор Ерлан Токтаров',
        specialization: 'Хирург',
        description: 'Хирург общей практики. Выполняет операции различной сложности.',
        rating: 4.6,
        experienceYears: 18,
        languages: ['Қазақша', 'Русский'],
      ),
      Doctor(
        id: '6',
        name: 'Доктор Айгуль Нуржанова',
        specialization: 'Гинеколог',
        description: 'Врач-гинеколог с опытом работы более 10 лет. Специализируется на женском здоровье.',
        rating: 4.8,
        experienceYears: 11,
        languages: ['Қазақша', 'Русский'],
      ),
    ];
  }

  // Моковые записи
  static List<Appointment> getAppointments(String userId) {
    final now = DateTime.now();
    return [
      Appointment(
        id: '1',
        userId: userId,
        doctorId: '1',
        doctorName: 'Доктор Айбек Нурланов',
        doctorSpecialization: 'Терапевт',
        dateTime: now.add(const Duration(days: 3)),
        status: 'scheduled',
        notes: 'Плановый осмотр',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: '2',
        userId: userId,
        doctorId: '2',
        doctorName: 'Доктор Алия Смагулова',
        doctorSpecialization: 'Кардиолог',
        dateTime: now.add(const Duration(days: 7)),
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '3',
        userId: userId,
        doctorId: '1',
        doctorName: 'Доктор Айбек Нурланов',
        doctorSpecialization: 'Терапевт',
        dateTime: now.subtract(const Duration(days: 10)),
        status: 'completed',
        notes: 'Консультация пройдена',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  // Моковые уведомления
  static List<AppNotification> getNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: '1',
        title: 'Напоминание о записи',
        message: 'У вас запись на завтра в 10:00 к доктору Айбек Нурланов',
        type: 'appointment',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Результаты анализов готовы',
        message: 'Ваши анализы крови готовы. Можете забрать в регистратуре.',
        type: 'analysis',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'Акция! Скидка 20%',
        message: 'Специальное предложение на консультацию кардиолога до конца месяца',
        type: 'promotion',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Запись подтверждена',
        message: 'Ваша запись на 15 января подтверждена',
        type: 'appointment',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }

  // Моковые медицинские записи
  static List<MedicalRecord> getMedicalRecords(String userId) {
    final now = DateTime.now();
    return [
      MedicalRecord(
        id: '1',
        userId: userId,
        doctorId: '1',
        doctorName: 'Доктор Айбек Нурланов',
        visitDate: now.subtract(const Duration(days: 30)),
        diagnosis: 'ОРВИ',
        symptoms: 'Повышенная температура, кашель, насморк',
        treatment: 'Постельный режим, обильное питье, симптоматическое лечение',
        analyses: [
          AnalysisResult(
            id: '1',
            name: 'Общий анализ крови',
            type: 'blood',
            date: now.subtract(const Duration(days: 30)),
            results: {
              'Гемоглобин': '140 г/л',
              'Лейкоциты': '6.5 × 10⁹/л',
              'Эритроциты': '4.5 × 10¹²/л',
            },
            notes: 'Показатели в норме',
          ),
        ],
      ),
      MedicalRecord(
        id: '2',
        userId: userId,
        doctorId: '2',
        doctorName: 'Доктор Алия Смагулова',
        visitDate: now.subtract(const Duration(days: 60)),
        diagnosis: 'Гипертония',
        symptoms: 'Повышенное артериальное давление',
        treatment: 'Медикаментозная терапия, контроль давления',
        analyses: [
          AnalysisResult(
            id: '2',
            name: 'ЭКГ',
            type: 'other',
            date: now.subtract(const Duration(days: 60)),
            results: {
              'Ритм': 'Синусовый',
              'ЧСС': '72 уд/мин',
              'Заключение': 'Без патологий',
            },
          ),
        ],
      ),
      MedicalRecord(
        id: '3',
        userId: userId,
        doctorId: '3',
        doctorName: 'Доктор Нурлан Касымов',
        visitDate: now.subtract(const Duration(days: 90)),
        diagnosis: 'Мигрень',
        symptoms: 'Головные боли, светобоязнь',
        treatment: 'Обезболивающие препараты, режим дня',
        analyses: null,
      ),
    ];
  }

  // Моковые акции
  static List<Promotion> getPromotions() {
    final now = DateTime.now();
    return [
      Promotion(
        id: '1',
        title: 'Скидка 20% на консультацию кардиолога',
        description: 'Специальное предложение для новых пациентов. Акция действует до конца месяца.',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        discount: 20.0,
      ),
      Promotion(
        id: '2',
        title: 'Комплексное обследование со скидкой',
        description: 'Полное медицинское обследование со скидкой 15%. Включает консультации специалистов и анализы.',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 28)),
        discount: 15.0,
      ),
      Promotion(
        id: '3',
        title: 'Бесплатная консультация терапевта',
        description: 'Для пенсионеров - бесплатная первичная консультация терапевта.',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
        discount: 100.0,
      ),
    ];
  }

  // Моковый пользователь
  static User getCurrentUser() {
    return User(
      id: 'user_1',
      name: 'Нурлан Абдуллаев',
      email: 'nurlan@example.com',
      phone: '+7 (777) 123-45-67',
      age: 35,
      gender: 'Мужской',
      role: 'patient',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }
}
