# 📱 Guía para compilar iOS - ESVARO Logística

## Prerrequisitos
- macOS con Xcode 15+ instalado
- CocoaPods instalado (`sudo gem install cocoapods`)
- Flutter SDK configurado (`flutter doctor`)
- Apple Developer Account (para firmar la app)

## Pasos para compilar

### 1. Instalar dependencias
```bash
cd ios
pod install
cd ..
```

### 2. Abrir en Xcode (para configurar certificados)
```bash
open ios/Runner.xcworkspace
```
En Xcode:
- Selecciona el proyecto **Runner** en el árbol
- Ve a **Signing & Capabilities**
- Selecciona tu **Team** (tu Apple Developer account)
- Cambia el **Bundle Identifier** de `com.example.gestionPaquetes` a tu propio ID
  (por ejemplo: `com.esvaro.logistica`)

### 3. Compilar Debug (conectando iPhone por cable)
```bash
flutter run -d ios
```

### 4. Compilar Release (para distribución)
```bash
flutter build ios --release
```

### 5. Generar IPA (para TestFlight o App Store)
```bash
flutter build ipa
```

## Configuración ya realizada ✅
- ✅ Deployment target: iOS 14.0
- ✅ Podfile creado con CocoaPods
- ✅ Permisos en Info.plist:
  - NSCameraUsageDescription (para fotos de evidencia)
  - NSPhotoLibraryUsageDescription (para seleccionar fotos)
  - NSPhotoLibraryAddUsageDescription (para guardar fotos)
  - UIFileSharingEnabled (para importar/exportar Excel)
  - LSSupportsOpeningDocumentsInPlace (para file_picker)
  - UISupportsDocumentBrowser (para file_picker)
- ✅ Firebase Options configurado para iOS
- ✅ permission_handler configurado en Podfile
- ✅ AppDelegate.swift correcto

## Notas importantes
- Si cambias el Bundle Identifier, debes registrarlo en Firebase Console
  y actualizar `firebase_options.dart` con `flutterfire configure`
- Para publicar en App Store, necesitas iconos de todas las resoluciones.
  Puedes generarlos con: `flutter pub run flutter_launcher_icons`
