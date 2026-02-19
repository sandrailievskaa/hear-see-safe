# Hear & See Safe
### Имплементирани функции (9 екрани)

1. **Picture Book** - Мултимедијална сликовница со големи слики, звуци и вибрации
2. **Number Games** - Игри со аудио читање и интерактивен фидбек
3. **Camera Recognition** - Распознавање на валути, бои и објекти преку камера
4. **Spatial Orientation** - Просторна ориентација со аудио инструкции
5. **Sound Identification** - Идентификација на звуци со гласовен/текстуален внес
6. **Braille Learning** - Интерактивни вежби за учење на Брајова азбука (A-Z)
7. **Cyber Safety** - Сајбер безбедност квизови со гласовни инструкции
8. **Sound Memory** - Игра на звуци
9. **Voice Pong** - Аудио базирана Понг игра

### Технички карактеристики

- **Мултијазичност**: Англиски, Македонски, Албански
- **Пристапност**: Висок контраст, голем текст, аудио фидбек (TTS), вибрации
- **State Management**: Provider
- **Cross-platform**: Web, Android, iOS, Windows, Linux, macOS
- **Services**: Voice Assistant со Web и Mobile имплементации
- **Settings Screen**: Подесувања за пристапност

## Како да се стартува
### Предуслови

1. Инсталирај Flutter SDK (3.0.0 или повисоко)
2. Провери инсталацијата:
```bash
flutter doctor
```

### Стартување на Browser (Chrome)

```bash
# Инсталирај зависности
flutter pub get

# Стартувај на Chrome
flutter run -d chrome
```

Апликацијата ќе се отвори автоматски во Google Chrome.

### Стартување на Android

#### 1. Инсталирај Android SDK

- Инсталирај [Android Studio](https://developer.android.com/studio)
- Отвори Android Studio → SDK Manager
- Инсталирај:
  - Android SDK Platform-Tools
  - Android SDK Build-Tools
  - Android SDK Platform (API 21 или повисоко)
- Прифати лиценци: `flutter doctor --android-licenses`

#### 2. Конфигурирај Android 

**Опција A**
- Овозможи Developer Options на Android телефонот
- Овозможи USB Debugging
- Поврзи го телефонот со компјутерот

**Опција B**
- Отвори Android Studio → AVD Manager
- Креирај нов виртуелен уред
- Стартувај го емулаторот

#### 3. Стартувај апликација

```bash
# Инсталирај зависности
flutter pub get

# Провери дали Android устройството е поврзано
flutter devices

# Стартувај на Android
flutter run -d android
```

### Стартување на iOS (само на macOS)

#### 1. Инсталирај Xcode

- Отвори App Store на macOS
- Инсталирај Xcode
- Отвори Xcode и прифати лиценци
- Инсталирај дополнителни компоненти ако се побарано

#### 2. Инсталирај CocoaPods

```bash
sudo gem install cocoapods
```

#### 3. Инсталирај iOS зависности

```bash
cd ios
pod install
cd ..
```

#### 4. Стартувај апликација

**Опција A: Симулатор**
```bash
# Отвори симулатор
open -a Simulator

# Стартувај апликацијата
flutter run -d ios
```

**Опција B**
- Поврзи го iPhone/iPad со Mac
- Довери го уредот во Xcode
- Стартувај: `flutter run -d ios`

## Зависности

Главни пакети:
- `flutter_tts` - Text-to-Speech
- `speech_to_text` - Speech-to-Text
- `camera` - Камера функционалност
- `provider` - State management
- `easy_localization` - Мултијазичност
- `vibration` - Вибрациски фидбек

## Структура на проектот

```
lib/
├── main.dart                    # Влезна точка
├── providers/                   # State management
├── services/                    # Voice Assistant services
├── screens/                     # 9 feature screens + settings
└── utils/                       # Accessibility utilities

assets/
├── translations/               # EN, MK, SQ преводи
├── images/                     # Слики
├── audio/                      # Аудио фајлови
└── sounds/                     # Звучни ефекти
```

## Забелешки

- **Web**: Целосно функционална, некои функции (камера, вибрации) имаат ограничувања
- **Android**: Потребен е Android SDK
- **iOS**: Работи само на macOS со Xcode

