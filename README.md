# StoryPrompt

> **«Conserva su voz, sus palabras y su historia»**

![Android](https://img.shields.io/badge/Android-Offline--First-BE185D)
![Flutter](https://img.shields.io/badge/Flutter-Material%203-blue)
![Zero Telemetry](https://img.shields.io/badge/Telemetr%C3%ADa-0%25-success)

**StoryPrompt** es un cuaderno **offline-first** para realizar entrevistas familiares guiadas, recoger respuestas conservando las palabras literales de la persona y compilar sus recuerdos en un libro imprimible organizado por capítulos.

---

## Características principales

- **Preguntas guía curadas**: tarjetas de conversación pensadas para abrir recuerdos de infancia, oficios, familia y consejos.
- **Preservación literal**: cada fragmento guarda textualmente las palabras del entrevistado sin reescrituras automáticas no autorizadas.
- **Organización por personas y capítulos**: agrupa sesiones y relatos por temática.
- **Exportación a libro PDF y Markdown**: genera un recuerdo familiar legible e imprimible sin conexión.
- **IA opcional BYOK (gratuita)**: desactivada por defecto.

---

## Privacidad

- Las historias familiares son privadas: todo se guarda localmente en SQLite, sin servidores, cuentas ni analítica.

---

## Instalación y compilación local

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

---

## Documentación adicional

- [DEPENDENCIES.md](DEPENDENCIES.md) · [CONTRIBUTING.md](CONTRIBUTING.md)
