import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const List<Locale> supportedLocales = [Locale('ru'), Locale('kk')];

  static AppLocalizations load(Locale locale) {
    return AppLocalizations(locale);
  }

  bool get isKk => locale.languageCode == 'kk';
  String get appTitle => isKk ? 'Жергілікті қызметтер' : 'Местные услуги';
  String get start => isKk ? 'Бастау' : 'Начать';
  String get login => isKk ? 'Кіру' : 'Войти';
  String get phoneNumber => isKk ? 'Телефон нөмірі' : 'Номер телефона';
  String get getCode => isKk ? 'Код алу' : 'Получить код';
  String get enterCode => isKk ? 'Кодты енгізіңіз' : 'Введите код';
  String get confirm => isKk ? 'Растау' : 'Подтвердить';
  String get home => isKk ? 'Басты' : 'Главная';
  String get categories => isKk ? 'Санаттар' : 'Категории';
  String get myBookings => isKk ? 'Менің брондарым' : 'Мои брони';
  String get profile => isKk ? 'Профиль' : 'Профиль';
  String get search => isKk ? 'Іздеу' : 'Поиск';
  String get recommended => isKk ? 'Ұсынылады' : 'Рекомендуемые';
  String get popularProviders => isKk ? 'Танымал провайдерлер' : 'Популярные поставщики';
  String get book => isKk ? 'Брондау' : 'Забронировать';
  String get price => isKk ? 'Бағасы' : 'Цена';
  String get duration => isKk ? 'Ұзақтығы' : 'Длительность';
  String get min => isKk ? 'мин' : 'мин';
  String get reviews => isKk ? 'Пікірлер' : 'Отзывы';
  String get allReviews => isKk ? 'Барлық пікірлер' : 'Все отзывы';
  String get chooseDate => isKk ? 'Күнді таңдаңыз' : 'Выберите дату';
  String get chooseTime => isKk ? 'Уақытты таңдаңыз' : 'Выберите время';
  String get proceedToPay => isKk ? 'Төлемге өту' : 'Перейти к оплате';
  String get pay => isKk ? 'Төлеу' : 'Оплатить';
  String get cardNumber => isKk ? 'Карта нөмірі' : 'Номер карты';
  String get expiry => isKk ? 'Мерзімі (АА/ЖЖ)' : 'Срок (MM/ГГ)';
  String get cvv => 'CVV';
  String get cardHolder => isKk ? 'Карта иесі' : 'Держатель карты';
  String get bookingSuccess => isKk ? 'Брондау сәтті жасалды!' : 'Бронь успешно оформлена!';
  String get myBookingsBtn => isKk ? 'Менің брондарым' : 'Мои брони';
  String get toHome => isKk ? 'Басты бетке' : 'На главную';
  String get addToCalendar => isKk ? 'Күнтізбеге қосу' : 'Добавить в календарь';
  String get upcoming => isKk ? 'Алдағы' : 'Предстоящие';
  String get past => isKk ? 'Өткен' : 'Прошедшие';
  String get cancelled => isKk ? 'Бас тартылған' : 'Отменённые';
  String get cancel => isKk ? 'Болдырмау' : 'Отменить';
  String get cancelBooking => isKk ? 'Бронды болдырмау' : 'Отменить бронь';
  String get contactProvider => isKk ? 'Провайдерге хабарласу' : 'Связаться с поставщиком';
  String get leaveReview => isKk ? 'Пікір қалдыру' : 'Оставить отзыв';
  String get rating => isKk ? 'Баға' : 'Оценка';
  String get comment => isKk ? 'Пікір' : 'Комментарий';
  String get send => isKk ? 'Жіберу' : 'Отправить';
  String get name => isKk ? 'Аты' : 'Имя';
  String get language => isKk ? 'Тіл' : 'Язык';
  String get darkTheme => isKk ? 'Қараңғы тақырып' : 'Тёмная тема';
  String get notifications => isKk ? 'Хабарландырулар' : 'Уведомления';
  String get support => isKk ? 'Қолдау' : 'Поддержка';
  String get logout => isKk ? 'Шығу' : 'Выйти';
  String get bonusPoints => isKk ? 'Бонус ұпайлары' : 'Бонусные баллы';
  String get useBonus => isKk ? 'Бонусты қолдану' : 'Использовать бонусы';
  String get total => isKk ? 'Жиыны' : 'Итого';
  String get bookingDetails => isKk ? 'Брондау мәліметтері' : 'Детали брони';
  String get service => isKk ? 'Қызмет' : 'Услуга';
  String get provider => isKk ? 'Провайдер' : 'Поставщик';
  String get dateTime => isKk ? 'Күні және уақыты' : 'Дата и время';
  String get status => isKk ? 'Күйі' : 'Статус';
  String get pending => isKk ? 'Күтуде' : 'Ожидает';
  String get confirmed => isKk ? 'Расталды' : 'Подтверждена';
  String get completed => isKk ? 'Аяқталды' : 'Завершена';
  String get retry => isKk ? 'Қайталау' : 'Повторить';
  String get error => isKk ? 'Қате' : 'Ошибка';
  String get loading => isKk ? 'Жүктелуде...' : 'Загрузка...';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'kk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
