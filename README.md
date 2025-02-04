# Instrukcja uruchomienia aplikacji

Aplikacja składa się z backendu w Django i frontendu w Flutter. Baza danych SQLite jest dołączona do projektu i nie wymaga dodatkowej konfiguracji.

---

## Wymagania

- **Python 3.8+** (do backendu Django)
- **Flutter SDK** (do frontendu)
- **Git** (do pobrania kodu)
- **IDE** (np. Visual Studio Code, PyCharm, Android Studio)

---

## 1. Przygotowanie środowiska

### Instalacja Pythona
Pobierz i zainstaluj Pythona z [oficjalnej strony](https://www.python.org/). Upewnij się, że `python` i `pip` są dostępne w terminalu.

### Instalacja Flutter
Pobierz i zainstaluj Flutter SDK z [oficjalnej strony](https://flutter.dev/). Upewnij się, że `flutter` jest dostępny w terminalu.

### Instalacja zależności
Zainstaluj narzędzia do zarządzania środowiskami wirtualnymi w Pythonie:

```sh
pip install virtualenv
```

---

## 2. Struktura projektu

```sh
projekt/
├── backend/  # Kod Django
├── frontend/ # Kod Flutter
└── README.md
```

---

## 3. Uruchomienie backendu (Django)

Przejdź do folderu backend:

```sh
cd backend
```

### Utwórz i aktywuj środowisko wirtualne:

#### Windows:
```sh
python -m venv venv
venv\Scripts\activate
```

#### macOS/Linux:
```sh
python3 -m venv venv
source venv/bin/activate
```

### Zainstaluj zależności:

```sh
pip install -r requirements.txt
```

### Przygotuj bazę danych SQLite:

```sh
python manage.py migrate
```

### Utwórz superużytkownika (opcjonalnie):

```sh
python manage.py createsuperuser
```

### Uruchom serwer deweloperski:

```sh
python manage.py runserver
```

Backend będzie dostępny pod adresem: [http://127.0.0.1:8000/](http://127.0.0.1:8000/).

---

## 4. Uruchomienie frontendu (Flutter)

Przejdź do folderu frontend:

```sh
cd ../frontend
```

### Zainstaluj zależności Flutter:

```sh
flutter pub get
```

### Skonfiguruj adres backendu:
Otwórz plik `lib/config.dart` i upewnij się, że `baseUrl` wskazuje na adres backendu:

```dart
class Config {
  static const String baseUrl = 'http://127.0.0.1:8000';
}
```

### Uruchom aplikację:

1. Podłącz urządzenie (fizyczne lub emulator).
2. Uruchom aplikację:

```sh
flutter run
```

---

## 5. Testowanie aplikacji

### Backend:
- Sprawdź, czy backend działa, otwierając w przeglądarce: [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/).
- Zaloguj się jako superużytkownik, jeśli potrzebujesz dostępu do panelu admina.

### Frontend:
- Przetestuj funkcjonalności aplikacji na urządzeniu/emulatorze.
- Upewnij się, że frontend komunikuje się z backendem (np. logowanie, generowanie kodu).

---

## 6. Prezentacja

### Pokaz backendu:
- Pokaż działający serwer Django.
- Zademonstruj panel admina (jeśli jest potrzebny).

### Pokaz frontendu:
- Pokaż działającą aplikację Flutter na urządzeniu/emulatorze.
- Zademonstruj kluczowe funkcjonalności (np. logowanie, generowanie kodu, użycie kodu).

### Integracja:
- Pokaż, jak frontend komunikuje się z backendem (np. wyświetlając dane z API).

---

## 7. Zakończenie

### Zatrzymaj serwer Django:
W terminalu z backendem naciśnij `Ctrl+C`, aby zatrzymać serwer.

### Zatrzymaj aplikację Flutter:
W terminalu z frontendem naciśnij `Ctrl+C`, aby zatrzymać aplikację.

### Dezaktywuj środowisko wirtualne:

```sh
deactivate
```

---

## 8. Dodatkowe uwagi

### Baza danych SQLite:
Baza danych SQLite jest dołączona do projektu Django i nie wymaga dodatkowej konfiguracji. Plik bazy danych (`db.sqlite3`) znajduje się w folderze `backend`.

### Problemy z Flutter:
Jeśli Flutter nie działa, upewnij się, że masz zainstalowane wszystkie zależności:

```sh
flutter doctor
```

Postępuj zgodnie z sugestiami wyświetlanymi przez `flutter doctor`.

### Problemy z Django:
Jeśli Django nie działa, upewnij się, że wszystkie zależności są zainstalowane:

```sh
pip install -r requirements.txt