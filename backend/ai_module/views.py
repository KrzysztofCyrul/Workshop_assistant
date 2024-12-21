import openai
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def generate_email_content(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method. Use POST."}, status=405)

    try:
        data = json.loads(request.body)
        subject_hint = data.get("subject_hint", "Brak tematu")
        recipient_type = data.get("recipient_type", "all")
        selected_segment = data.get("selected_segment")
        selected_client = data.get("selected_client")
        sender_name = data.get("sender_name", "Twoje Imię i Nazwisko")
        sender_position = data.get("sender_position", "Twoje Stanowisko")
        sender_company = data.get("sender_company", "Twoja Firma")

        # Skonfiguruj klucz API
        openai.api_key = settings.API_KEY

        # Przygotuj prompt z uwzględnieniem nadawcy
        messages = [
            {"role": "system", "content": "Jesteś pomocnym asystentem w warsztacie samochodwym, który pisze profesjonalne wiadomości e-mail."},
            {"role": "user", "content": f"""
            Stwórz treść e-maila na temat: {subject_hint}.
            Nadawca: {sender_name}, {sender_position}, {sender_company}.
            Typ odbiorcy: {recipient_type}.
            {f"Segment: {selected_segment}." if selected_segment else ""}
            {f"Odbiorca: {selected_client}." if selected_client else ""}
            Wiadomość powinna być uprzejma i profesjonalna.
            """}
        ]

        # Wywołaj API OpenAI
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=500,
            temperature=0.7,
        )

        generated_email = response['choices'][0]['message']['content'].strip()

        return JsonResponse({"email_content": generated_email}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
