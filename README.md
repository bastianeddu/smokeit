# smokeit (RauchSim)

Flutter-App für **Android und iOS**, die simuliert, dass eine **Zigarette, Zigarre, ein Joint oder eine Bong** auf dem Display abbrennt. Sobald du ein **Sauggeräusch** machst, brennt die Glut sichtbar weiter, leuchtet heller, stößt Rauch aus – und knistert.

Nur eine Simulation – es wird nichts aufgenommen oder gespeichert; ausgewertet wird ausschließlich der live Mikrofon-Lautstärkepegel (dB).

## Features

- **Zigarette, Zigarre, Joint**: Dauerbrand + beschleunigtes Abbrennen bei jedem erkannten Zug
- **Bong**: genau **ein Zug** mit **Flutsch-/Blubber-Geräusch** (`assets/audio/bong.wav`); danach wird der **Bildschirm ~2,6 s schwarz** und dann „Bong geleert“ angezeigt
- **Sounds** (prozedural erzeugte WAVs, keine externen Dateien): Crackle-Loop während des Brennens (Lautstärke folgt der Glut), Inhale-Whoosh pro Zug (`assets/audio/crackle.wav`, `inhale.wav`)
- Zug-Erkennung: `noise_meter` liefert live dB-Werte; `InhaleDetector` kalibriert den Ruhepegel und meldet Züge (Schwelle `thresholdOffsetDb` + Refraktärzeit)
- Darstellung per `CustomPainter`: Körper, Asche, Glut mit Glow/Flicker, Rauch-/Aschepartikel; Bong als Kolben mit Wasser, Hals und Kopf
- Fallback ohne Mikrofon-Berechtigung: Button „Zug simulieren“

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

## Bekannte Build-Hinweise (Flutter 3.47 / AGP 9.1)

- `permission_handler` ist auf **^12.0.1** gepinnt, weil 13.x compileSdk 37 verlangt (AGP 9.1 kann max. 36).
- Falls der Build „NDK 28.2.13676358 not found“ meldet: in `android/app/build.gradle.kts` die Zeile `ndkVersion = ...` auskommentieren oder auf ein installiertes NDK setzen (z. B. `ndkVersion = "30.0.16248370"`). Die Plugins brauchen kein NDK.
- Windows: Entwicklermodus aktivieren (Symlinks für Plugins): `start ms-settings:developers`.

## Plattform-Konfiguration (liegt diesem Repo bei)

- **Android**: `RECORD_AUDIO` in `android/app/src/main/AndroidManifest.xml`; `minSdk` >= 24 in `android/app/build.gradle` (Audio-Wiedergabe braucht keine extra Permission).
- **iOS**: `NSMicrophoneUsageDescription` in `ios/Runner/Info.plist`; Xcode Background Mode **„Audio, AirPlay and Picture in Picture“**; bei CocoaPods `PERMISSION_MICROPHONE=1` in der Podfile.

## Hinweise

- Auf einem **echten Gerät** testen (Emulator/Simulator-Mikrofon oft unzuverlässig).
- Schwellenwert anpassen: `thresholdOffsetDb` in `lib/services/inhale_detector.dart`.
- Neue Objekte: `SmokeItem.all` in `lib/models/smoke_item.dart`; Bong-Sonderlogik hängt an `SmokeItemType.bong`.

## Tests

```bash
flutter test
```
