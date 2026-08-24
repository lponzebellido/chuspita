# Chuspita

Gestor financiero personal desarrollado con Flutter.

## Requisitos

- Git.
- Flutter estable. El proyecto se desarrolla con Flutter 3.47.1 y Dart 3.13.1.
- Para Android: Android Studio, Android SDK y un emulador o dispositivo.
- Para iOS: macOS, Xcode, un simulador o dispositivo y CocoaPods.

Comprueba el entorno antes de comenzar:

```bash
flutter --version
flutter doctor -v
```

## Preparar el proyecto en otro equipo

```bash
git clone https://github.com/lponzebellido/chuspita.git
cd chuspita
flutter pub get
flutter test
flutter analyze
```

`pubspec.lock` y los archivos generados necesarios están versionados, por lo
que no es necesario ejecutar `build_runner` para iniciar el proyecto.

## Ejecutar la aplicación

Consulta primero los dispositivos disponibles:

```bash
flutter devices
```

Ejecuta la aplicación indicando el identificador mostrado por el comando
anterior:

```bash
flutter run -d <device-id>
```

### Android

Para usar un emulador existente:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter devices
flutter run -d <device-id>
```

También puedes conectar un teléfono con la depuración USB habilitada y aceptar
la autorización del equipo.

### iOS

Abre primero el simulador y después ejecuta la aplicación:

```bash
open -a Simulator
flutter devices
flutter run -d <device-id>
```

En un iPhone físico será necesario configurar un equipo de firma en Xcode.

## Flujo habitual después de recibir cambios

```bash
git pull
flutter pub get
flutter test
flutter analyze
```

Vuelve a ejecutar `flutter pub get` cuando cambie `pubspec.yaml` o
`pubspec.lock`.
