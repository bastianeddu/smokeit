# smokeit (RauchSim)

Flutter-App für **Android und iOS**, die simuliert, dass eine **Zigarette, Zigarre oder ein Joint** auf dem Display abbrennt. Sobald du ein **Sauggeräusch** machst, brennt die Glut sichtbar weiter, leuchtet heller und stößt Rauch aus.

Nur eine Simulation – es wird nichts aufgenommen oder gespeichert; ausgewertet wird ausschließlich der live Mikrofon-Lautstärkepegel (dB).

## Funktionsweise

- `noise_meter` liefert den Mikrofon-Pegel als Stream von dB-Werten (Android/iOS nativ, Sample-Rate 44,1 kHz).
- `InhaleDetector` (`lib/services/inhale_detector.dart`) kalibriert zuerst den Umgebungs-Ruhepegel und meldet einen „Zug“, sobald der Pegel deutlich darüber liegt (Schwelle konfigurierbar via `thresholdOffsetDb`, plus Refraktärzeit gegen Doppelzählung).
- Jeder Zug erhöht kurzzeitig Brennrate, Glut-Helligkeit und Rauchemission; dazwischen schwacher Dauerbrand, bis das Objekt bei 100 % „aufgeraucht“ ist.
- Gezeichnet wird alles mit einem `CustomPainter` (`lib/widgets/burning_item_painter.dart`): Körper (Zigarette mit Filter, Zigarre mit Band, Joint als Kegel mit Krutz), wachsende Asche, glühende Spitze mit Flicker/Glow sowie Rauch- und Aschepartikel.
- Fallback ohne Mikrofon-Berechtigung: Button „Zug simulieren“.

## Setup

Voraussetzung: aktuelles stabiles Flutter-SDK (`noise_meter` 6.x benötigt Flutter 3.44+, iOS 16+, Android minSdk 24).

```bash
git clone https://github.com/bastianeddu/smokeit.git
cd smokeit
flutter create --project-name smokeit --org com.example .
# ergänzt nur das Flutter-Gerüst (android/, ios/, …); vorhandene Dateien bleiben erhalten
flutter pub get
flutter run
```

## Plattform-Konfiguration (liegt diesem Repo bei)

- **Android**: `RECORD_AUDIO` in `android/app/src/main/AndroidManifest.xml`. In `android/app/build.gradle` sicherstellen, dass `minSdk` mindestens **24** ist (Requirement von `noise_meter`/`audio_streamer`).
- **iOS**: `NSMicrophoneUsageDescription` in `ios/Runner/Info.plist`. Zusätzlich in Xcode im Runner-Target unter *Signing & Capabilities → Background Modes* den Modus **„Audio, AirPlay and Picture in Picture“** aktivieren. Bei CocoaPods außerdem in der `Podfile` im `post_install`-Block `'PERMISSION_MICROPHONE=1'` in `GCC_PREPROCESSOR_DEFINITIONS` eintragen (bei Swift Package Manager nicht nötig – siehe noise_meter-README auf pub.dev).

## Hinweise

- Am besten auf einem **echten Gerät** testen; Emulator/Simulator liefern oft kein brauchbares Mikrofon. Dafür gibt es den Button „Zug simulieren“.
- Schwellenwert anpassen: `thresholdOffsetDb` im Konstruktor von `InhaleDetector` (`lib/services/inhale_detector.dart`).
- Neue Objekte (z. B. Pfeife, Vape) lassen sich einfach in `SmokeItem.all` (`lib/models/smoke_item.dart`) ergänzen.

## Tests

```bash
flutter test
```
