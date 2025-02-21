# Używamy oficjalnego obrazu Pythona
FROM python:3.11

# Ustawiamy katalog roboczy
WORKDIR /app

# Kopiujemy pliki projektu do kontenera
COPY . /app

# Instalujemy zależności
RUN pip install --no-cache-dir -r requirements.txt

# Otwieramy port aplikacji
EXPOSE 8000

# Uruchamiamy serwer Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
