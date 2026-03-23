# Hear & See Safe

## Како да ја тестираш

Потребно: **Flutter SDK** (3.0+) инсталиран. Провери:

```bash
flutter doctor
```

Поправки ги правиш според пораките од `flutter doctor`. Потоа во папката на проектот:

```bash
flutter pub get
```

Далнее избираш една од трите варијанти.

---

### Варијанта 1: Chrome 

Најбрзо за тест на лаптоп.

1. Затвори ги другите Chrome прозорци со локални адреси (ако ги има).
2. Во терминал во папката на проектот:

```bash
flutter run -d chrome
```

3. Чекај да се компајлира и ќе се отвори Chrome со апликацијата.

**Напомена:** Камера и вибрации на веб не работат како на телефон. **Гласовниот асистент (TTS)** на македонски и албански често **не е достапен во Chrome** – прелистувачот поддржува ограничен број јазици. За целосна поддршка на македонски/албански TTS, користете ја **Android** апликацијата и осигурајте се дека македонскиот/албанскиот јазичен пакет е инсталиран (Поставки → Јазици и внесување → Text-to-speech).

---

### Варијанта 2: Android (телефон или емулатор)

Со **лаптоп** можеш да пуштиш апликација на Android телефон или на емулатор.

#### А) Физички Android телефон

1. На телефонот: **Поставки → За телефонот** (или Слично) → 7 пати тапни на **Број на верзија** → се појавува „Развивач“.
2. **Поставки → Систем → За развивачи** → вклучи **USB debugging**.
3. Поврзи го телефонот со лаптопот со USB кабел. На телефонот прифати „Дали да дозволиш USB debugging?“.
4. Во терминал:

```bash
flutter devices
```

Провери дали се појавува твојот телефон. Потоа:

```bash
flutter run -d android
```

Ако имаш повеќе уреди, избери го Android уредот кога Flutter понуди листа.

#### Б) Android емулатор (без телефон)

1. Инсталирај [Android Studio](https://developer.android.com/studio).
2. Android Studio → **More Actions** (или **Tools**) → **Device Manager** → **Create Device** → избери телефон (на пр. Pixel 6) → **Next** → избери системска слика (на пр. API 34) → **Download** ако треба → **Finish**.
3. Стартувај го емулаторот со копче **Run** (зелената стрелка).
4. На лаптопот во папката на проектот:

```bash
flutter run -d android
```

Ако прв пат користиш Android SDK, прифати лиценци:

```bash
flutter doctor --android-licenses
```

#### Телефонот не се појавува во `flutter devices`?

На Windows често лаптопот не го препознава телефонот. Пробај по овој ред:

1. **Дали е Android SDK инсталиран?**  
   Изврши:
   ```bash
   flutter doctor -v
   ```
   Под „Android toolchain“ треба да пишува „Android license status accepted“. Ако пишува „Unable to locate Android SDK“ или слична грешка:
   - Инсталирај [Android Studio](https://developer.android.com/studio).
   - Во Android Studio: **File → Settings** (или **Android Studio → Preferences** на Mac) → **Languages & Frameworks → Android SDK** → забележи го патот за **Android SDK location**.
   - Во терминал: `flutter doctor --android-licenses` и прифати ги лиценците со `y`.

2. **Дали adb го гледа телефонот?**  
   Отвори **нов** терминал и провери (adb е во папката на Android SDK, на пр. `C:\Users\ТвоетоИме\AppData\Local\Android\Sdk\platform-tools\adb.exe`):
   ```bash
   adb devices
   ```
   Ако `adb` не е во PATH, прво отвори Android Studio → **Tools → Device Manager** (или **SDK Manager**), па **SDK Tools** и провери дали е штиклирано **Android SDK Platform-Tools** и инсталирај. Потоа во терминал користи полн пат, на пр.:
   ```bash
   "C:\Users\Lenovo\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
   ```
   - Ако листата е **празна** или пишува „unauthorized“, видете чекор 3 и 4.
   - Ако телефонот се појавува како „device“, тогаш повтори `flutter devices` — треба да се појави и во Flutter.

3. **На телефонот:**  
   - Отклучи го екранот и остави го отклучено додека е поврзан.  
   - Кога прв пат го поврзеш, на телефонот треба да излезе порака **„Дали да дозволиш USB debugging?“** → прифати и штиклирај **„Секогаш од овој компјутер“** ако понуди.  
   - Ако пораката не излегува: **Поставки → За развивачи** → исклучи **USB debugging**, повтори со кабел, пак вклучи **USB debugging** и поврзи го уредот.  
   - На некои телефони: кога ќе поврзеш, на телефонот избери **„Пренос на датотеки“ / „File transfer (MTP)“** наместо „Само полнење“.

4. **USB кабел и порт:**  
   Користи кабел што пренесува податоци (не само полнење). Пробај друг USB порт на лаптопот, по можност директно на лаптопот, не преку USB hub.

5. **USB драјвер (Windows):**  
   На некои Android уреди на Windows треба посебен драјвер:
   - **Samsung:** [Samsung USB Driver](https://developer.samsung.com/android-usb-driver).
   - **Xiaomi / Redmi:** вклучи **USB debugging** и **USB debugging (Security settings)** во За развивачи; понекогаш треба [Xiaomi driver](https://www.xiaomi.com/).
   - **Други:** во Device Manager (Win + X → Device Manager) провери дали под „Other devices“ или „Android“ има уред со жолт триаголник; десен клик → Update driver → Browse → Let me pick → Android Device или Google USB Driver.

6. **Ресетирај adb:**  
   Во терминал:
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```
   Повтори `flutter devices`.

7. **Алтернатива без телефон:**  
   Користи **емулатор** (Варијанта 2Б погоре): Android Studio → Device Manager → Create Device → стартувај емулатор. Кога емулаторот работи, `flutter devices` ќе покаже Android уред и `flutter run -d android` ќе работи.

---

### Варијанта 3: iPhone (потребен е Mac)

**iPhone се тестира само од Mac** (со Xcode). На Windows/Lenovo не може да се гради апликација за iPhone.

1. На **Mac**: инсталирај [Xcode](https://developer.apple.com/xcode/) од App Store. Отвори го Xcode еднаш и прифати лиценци.
2. Инсталирај CocoaPods (доколку го немаш):

```bash
sudo gem install cocoapods
```

3. Во папката на проектот прв пат изврши:

```bash
cd ios
pod install
cd ..
```

4. Поврзи го **iPhone** со Mac со кабел. На iPhone: **Поставки → Општо → VPN и управување со уред** → довери го овој компјутер.
5. На Mac во папката на проектот:

```bash
flutter devices
```

Провери дали се појавува iPhone. Потоа:

```bash
flutter run -d ios
```

Ако сакаш симулатор наместо физички iPhone: отвори симулатор со `open -a Simulator`, потоа `flutter run -d ios`.

