from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
from transformers import pipeline
from textblob import TextBlob
import nltk
import random
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# nltk.download('punkt_tab')

app = Flask(__name__)


# Enable CORS for all routes
CORS(app)

# paraphraser = pipeline("text2text-generation", model="t5-small")
# summarizer = pipeline("summarization")

# def detect_bias(sentence):
#     analysis = TextBlob(sentence)
#     return abs(analysis.sentiment.polarity) > 0.5

# def rewrite_biased_sentence(sentence):
#     paraphrased = paraphraser(f"paraphrase: {sentence}", max_length=50, num_return_sequences=1)
#     return paraphrased[0]['generated_text']

# @app.route('/rewrite', methods=['POST'])
# def process_article():
#     try:
#         data = request.json
#         article = data.get('article', '')

#         if not article:
#             return jsonify({"error": "Article content is missing"}), 400

#         sentences = nltk.sent_tokenize(article)
#         rewritten_article = []
#         summary_of_changes = []

#         for sentence in sentences:
#             if detect_bias(sentence):
#                 rewritten_sentence = rewrite_biased_sentence(sentence)
#                 summary_of_changes.append({
#                     "original": sentence,
#                     "rewritten": rewritten_sentence,
#                     "reason": "High sentiment polarity detected"
#                 })
#                 rewritten_article.append(rewritten_sentence)
#             else:
#                 rewritten_article.append(sentence)

#         rewritten_text = " ".join(rewritten_article)
#         summary = summarizer(rewritten_text, max_length=100, min_length=30, do_sample=False)[0]['summary_text']

#         return jsonify({
#             "rewritten_article": rewritten_text,
#             "summary": summary,
#             "changes": summary_of_changes
#         })

#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# def classify_article_with_ollama(article):
#     prompt = f"""
#     Classify the following article as 'left,' 'right,' or 'center' based on its political stance. 
#     Additionally, provide a brief explanation for your classification.

#     Article:
#     {article}

#     Your response format should be:
#     {{
#         "classification": "left/right/center",
#         "explanation": "Provide a clear explanation here."
#     }}
#     """

#     try:
#         result = subprocess.run(
#             ["ollama", "run", "llama3.2"],
#             input=prompt,
#             text=True,
#             capture_output=True,
#             encoding="utf-8",
#             errors="replace"
#         )

#         print("Raw response from Ollama:", result.stdout)

#         if result.returncode != 0:
#             return {"error": f"Subprocess failed with return code {result.returncode}: {result.stderr.strip()}"}

#         response = result.stdout.strip()

#         if not response.startswith("{") or not response.endswith("}"):
#             return {"error": "Response from Ollama is not valid JSON."}

#         try:
#             classification_data = json.loads(response)
#         except json.JSONDecodeError:
#             return {"error": "Failed to decode JSON response from Ollama."}

#         return classification_data

#     except FileNotFoundError:
#         return {"error": "Ollama is not installed or not found in the system PATH."}
#     except Exception as e:
#         return {"error": f"An unexpected error occurred: {str(e)}"}

# @app.route('/classify', methods=['POST'])
# def classify_article():
#     data = request.get_json()

#     if 'article' not in data:
#         return jsonify({"error": "No article content provided"}), 400

#     article = data['article']

#     result = classify_article_with_ollama(article)

#     if "error" in result:
#         return jsonify(result), 500
#     else:
#         return jsonify({
#             "classification": result["classification"],
#             "explanation": result["explanation"]
#         })
# Email settings
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
EMAIL_ADDRESS = 'freakydevil2005@gmail.com'
EMAIL_PASSWORD = 'agzp ivau efmb qemz'

otp_storage = {}  # In-memory storage for OTPs (use a database in production)


def send_email(to_email, subject, body):
    try:
        # Set up the server
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)

        # Create the email
        msg = MIMEMultipart()
        msg['From'] = EMAIL_ADDRESS
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))

        # Send the email
        server.send_message(msg)
        server.quit()
        print("Email sent successfully")
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False


@app.route('/send-otp', methods=['POST'])
def send_otp():
    try:
        data = request.get_json()
        email = data.get('email')

        if not email:
            return jsonify({'error': 'Email is required'}), 400

        # Generate a 6-digit OTP
        otp = random.randint(100000, 999999)
        otp_storage[email] = otp  # Store the OTP for the email

        # Email content
        subject = "Your OTP for Verification"
        body = f"Your OTP for verification is: {otp}. Please do not share this with anyone."

        # Send the email
        if send_email(email, subject, body):
            return jsonify({'message': 'OTP sent successfully'}), 200
        else:
            return jsonify({'error': 'Failed to send OTP'}), 500
    except Exception as e:
        print(f"Error in /send-otp route: {e}")
        return jsonify({'error': 'Internal server error'}), 500
@app.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')

    if not email or not otp:
        return jsonify({'error': 'Email and OTP are required'}), 400

    # Check if the OTP matches
    if email in otp_storage and str(otp_storage[email]) == str(otp):
        del otp_storage[email]  # Remove the OTP after successful verification
        return jsonify({'message': 'OTP verified successfully'}), 200
    else:
        return jsonify({'error': 'Invalid OTP'}), 400
if __name__ == "__main__":
    app.run(debug=True, host="180.235.121.245", port=4073)
