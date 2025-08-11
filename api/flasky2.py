from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
from textblob import TextBlob
import pymysql
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import random
from groq import Groq

app = Flask(__name__)

# Email settings
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
EMAIL_ADDRESS = 'freakydevil2005@gmail.com'  # Replace with your email
EMAIL_PASSWORD = 'agzp ivau efmb qemz'  # Replace with your email app password

# Store OTPs temporarily (in memory)
otp_storage = {}

def send_email(to_email, subject, body):
    """Function to send an email via SMTP."""
    try:
        # Set up the SMTP server
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
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

@app.route('/send-otp', methods=['POST'])
def send_otp():
    """API endpoint to send an OTP to a given email."""
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

@app.route('/verify-otp', methods=['POST'])
def verify_otp():
    """API endpoint to verify an OTP."""
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')

    if not email or not otp:
        return jsonify({'error': 'Email and OTP are required'}), 400

    if otp_storage.get(email) == int(otp):
        del otp_storage[email]  # Remove OTP after successful verification
        return jsonify({'message': 'OTP verified successfully'}), 200
    else:
        return jsonify({'error': 'Invalid OTP'}), 400

def send_email(to_email, subject, body):
    try:
        sender_email = "freakydevil2005@gmail.com"
        sender_password = "agzp ivau efmb qemz"

        # Set up the MIME
        message = MIMEMultipart()
        message['From'] = sender_email
        message['To'] = to_email
        message['Subject'] = subject
        message.attach(MIMEText(body, 'plain'))

        # Send the email via SMTP
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(message)
        server.quit()

        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False

@app.route('/send-password', methods=['POST'])
def send_password():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({'error': 'Email is required'}), 400

    try:
        # Connect to the database
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor(dictionary=True)

        # Query to fetch the password
        cursor.execute("SELECT password FROM users WHERE email = %s", (email,))
        result = cursor.fetchone()

        if result:
            password = result['password']
            subject = "Your Account Password"
            body = f"Your password is: {password}. Please keep it secure."

            if send_email(email, subject, body):
                return jsonify({'message': 'Password sent successfully'}), 200
            else:
                return jsonify({'error': 'Failed to send email'}), 500
        else:
            return jsonify({'error': 'Email not found'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Database connection
def create_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Kutta@123",
        database="your_database"
    )
def get_db_connection():
    return pymysql.connect(
        host='localhost',       # Replace with your MySQL host
        user='root',       # Replace with your MySQL username
        password='Kutta@123',  # Replace with your MySQL password
        database='your_database',  # Replace with your database name
        cursorclass=pymysql.cursors.DictCursor
    )
@app.route('/getCategoryProportions', methods=['POST'])
def get_category_proportions():
    try:
        # Parse the email from the request
        data = request.json
        user_email = data.get('email')
        
        if not user_email:
            return jsonify({'status': 'error', 'message': 'Email is required'}), 400

        # Connect to the database
        conn = get_db_connection()
        with conn.cursor() as cursor:
            # Fetch counts for all categories for the given email
            cursor.execute(
                """
                SELECT business, politics, sports, technology
                FROM UserCount2
                WHERE email = %s;
                """,
                (user_email,)
            )
            row = cursor.fetchone()

        conn.close()

        if not row:
            return jsonify({'status': 'error', 'message': 'No data found for the given email'}), 404

        # Calculate proportions
        total_count = sum(int(row[category]) for category in row if row[category].isdigit())
        if total_count == 0:
            return jsonify({'status': 'error', 'message': 'Total count is zero, cannot calculate proportions'}), 400

        proportions = [
            {
                'category': category,
                'proportion': (int(row[category]) / total_count) * 100
            }
            for category in row
        ]

        return jsonify({'status': 'success', 'data': proportions}), 200

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
    
def find_sentiment(news_story):
    news = TextBlob(news_story)
    polarity_data = []
    subjectivity_data = []

    # Iterates over each sentence in the news, extracts the sentiment, and stores each inside of a list.
    for sentence in news.sentences:
        sentiment = sentence.sentiment
        polarity_data.append(sentiment.polarity)
        subjectivity_data.append(sentiment.subjectivity)

    # The averages of both sentiment lists are calculated.
    polarity_average = calculate_average(polarity_data)
    subjectivity_average = calculate_average(subjectivity_data)

    return polarity_average, subjectivity_average


# Helper Methods (for the find_sentiment method)
def calculate_average(data):
    return sum(data) / len(data) if data else 0


@app.route('/analyze_sentiment', methods=['POST'])
def analyze_sentiment():
    data = request.get_json()
    if not data or 'article' not in data:
        return jsonify({"error": "Invalid input. Please provide an article."}), 400
    
    article = data['article']
    try:
        polarity, subjectivity = find_sentiment(article)

        # Return the polarity and subjectivity as a response
        return jsonify({
            'polarity': polarity,
            'subjectivity': subjectivity
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/update-profile', methods=['POST'])
def update_profile():
    try:
        data = request.get_json()

        # Extract email and validate
        email = data.get("email")
        if not email:
            return jsonify({"message": "Email is required"}), 400

        # Connect to database
        connection = create_connection()
        cursor = connection.cursor(dictionary=True)

        # Check if user exists
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        if not user:
            return jsonify({"message": "User not found"}), 404

        # Update user fields if provided
        if "name" in data:
            cursor.execute("UPDATE users SET name = %s WHERE email = %s", (data["name"], email))
        if "password" in data:
            cursor.execute("UPDATE users SET password = %s WHERE email = %s", (data["password"], email))
        if "category" in data:
            cursor.execute("UPDATE users SET category = %s WHERE email = %s", (data["category"], email))
        if "source" in data:
            cursor.execute("UPDATE users SET source = %s WHERE email = %s", (data["source"], email))

        connection.commit()

        return jsonify({"message": "Profile updated successfully!"}), 200

    except Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
# Route to update article read count and source
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Kutta@123',  # Replace with your MySQL password
    'database': 'your_database'
}
@app.route('/update_category', methods=['POST'])
def update_category():
    try:
        # Get the request data
        data = request.json
        email = data.get('email')
        category = data.get('category')

        if not email or not category:
            return jsonify({'error': 'Email and category are required'}), 400

        # Check if the category is valid
        valid_categories = ['business', 'politics', 'sports', 'technology']
        if category not in valid_categories:
            return jsonify({'error': f'Invalid category. Choose from {valid_categories}'}), 400

        # Connect to the database
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # Check if the email exists
        cursor.execute("SELECT id FROM UserCount2 WHERE email = %s", (email,))
        result = cursor.fetchone()

        if not result:
            # If email does not exist, insert it with category counts initialized to 0
            insert_query = """
                INSERT INTO UserCount2 (email, business, politics, sports, technology)
                VALUES (%s, 0, 0, 0, 0)
            """
            cursor.execute(insert_query, (email,))
            conn.commit()

        # Increment the count for the specified category
        update_query = f"UPDATE UserCount2 SET {category} = {category} + 1 WHERE email = %s"
        cursor.execute(update_query, (email,))
        conn.commit()

        return jsonify({'message': f'{category.capitalize()} count updated successfully for {email}'}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': f'Database error: {str(err)}'}), 500

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

def fetch_data_by_email(email):
    connection = create_connection()
    cursor = connection.cursor(dictionary=True)  # Enable dictionary cursor
    query = """
        SELECT business, politics, sports, technology
        FROM usercount2
        WHERE email = %s
    """
    cursor.execute(query, (email,))
    data = cursor.fetchone()  # Fetch one record
    connection.close()
    return data

# API endpoint to fetch data for a specific email
@app.route('/data', methods=['POST'])
def get_data():
    try:
        # Get the email from the request JSON body
        email = request.json.get('email')
        if not email:
            return jsonify({"error": "Email is required"}), 400

        # Fetch data for the provided email
        data = fetch_data_by_email(email)
        # if 'email' not in data:
        #     return jsonify({"error": "No data found for the provided email"}), 404

        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
@app.route('/users', methods=['GET'])
def fetch_users():
    try:
        connection = create_connection()
        cursor = connection.cursor(dictionary=True)  # Dictionary cursor to return rows as dict
        query = "SELECT name, email, category, source FROM users"  # Exclude password field for security
        cursor.execute(query)
        users = cursor.fetchall()
        connection.close()
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/users2/<email>', methods=['GET'])
def fetch_users2(email):
    try:
        connection = create_connection()
        cursor = connection.cursor()
        query = "SELECT name, email, category, source FROM users WHERE email = %s"
        print("Executing query:", query)  # Debug log
        print("With email:", email)       # Debug log
        cursor.execute(query, (email,))
        users = cursor.fetchall()
        print("Fetched users:", users)   # Debug log
        connection.close()
        return jsonify(users), 200 # Return 404 if no data found
    except Exception as e:
        return jsonify({"error": str(e)}), 500



# Delete a user by email
@app.route('/users/<email>', methods=['DELETE'])
def delete_user(email):
    try:
        connection = create_connection()
        cursor = connection.cursor()
        query = "DELETE FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        connection.commit()

        # Check if a record was deleted
        if cursor.rowcount == 0:
            connection.close()
            return jsonify({"error": "No user found with the provided email"}), 404

        connection.close()
        return jsonify({"message": "User deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/get_daily_data', methods=['GET'])
def get_daily_data():
    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor(dictionary=True)
        
        # Query to get the last 10 days' data
        query = """
            SELECT date, articles_count 
            FROM dailydata
            WHERE date >= CURDATE() - INTERVAL 10 DAY
            ORDER BY date ASC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        
        # Format response
        formatted_results = [
            {
                "date": result["date"].strftime('%Y-%m-%d'),
                "articles_count": result["articles_count"]
            }
            for result in results
        ]
        return jsonify(formatted_results), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/verify-and-update-password', methods=['POST'])
def verify_and_update_password():
    data = request.json
    email = data.get('email')
    old_password = data.get('old_password')
    new_password = data.get('new_password')

    if not email or not old_password or not new_password:
        return jsonify({"message": "All fields are required."}), 400

    try:
        # Fetch the current password from the database
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT password FROM users WHERE email = %s", (email,))
        result = cursor.fetchone()

        if not result:
            return jsonify({"message": "User not found."}), 404

        current_password = result[0]

        # Verify the old password
        if current_password != old_password:
            return jsonify({"message": "Old password is incorrect."}), 400

        # Update the password with the new password
        cursor.execute("UPDATE users SET password = %s WHERE email = %s", (new_password, email))
        mysql.connection.commit()
        cursor.close()

        return jsonify({"message": "Password updated successfully."}), 200

    except Exception as e:
        return jsonify({"message": f"An error occurred: {e}"}), 500
    
client = Groq(api_key="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")

@app.route('/analyze_article2', methods=['POST'])
def analyze_article32():
    try:
        # Get the article from the request body
        data = request.get_json()
        article = data.get("article")

        if not article:
            return jsonify({"error": "Article content is required"}), 400

        # Construct the prompt
        prompt = (f""""
            Classify the following article as 'left,' 'right,' or 'center' based on its political stance.
Analyze the content deeply, taking into account the tone, subject matter, use of language, framing of arguments, selection of evidence, and overall context. Highlight any biases, perspectives, or emphasis on particular ideologies or issues that indicate its stance. Ensure the analysis is comprehensive, 
    covering multiple possible interpretations, and conclude with the most likely classification.Mention all of the details only within the fields in the json response nd nothing outside those fields to maintin uniformity

    Article:
    {article}

    {{
        "classification": "left/right/center",
        "explanation": "Provide a clear explanation here."
    }}
    Make sure the analysis is deep and think of all possible prespectives and conclude on the best one
                  """
        )

        # Call Groq API
        chat_comp = client.chat.completions.create(
            messages=[
                {"role": "user", "content": prompt}
            ],
            model="llama-3.3-70b-versatile",
        )

        # Extract response
        response_content = chat_comp.choices[0].message.content

        return response_content, 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
import requests
groq_client = Groq(
    api_key="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"
)
YOUTUBE_API_KEY = "AIzaSyBDCu9ii0vAGnQhsJM2AqHjrMSMpadb5sk"

@app.route('/get_videos', methods=['POST'])
def get_videos():
    # Get the title from the request JSON
    data = request.get_json()
    title = data.get('title')

    if not title:
        return jsonify({"error": "Title is required"}), 400

    # Step 1: Generate the query keyword using Groq API
    chat_comp = groq_client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": f"Generate a keyword for the following title:{title}for YouTube videos querying  kindly return the keyword plainly and just one without anyother fields surrounding it",
            }
        ],
        model="llama3-8b-8192",
    )

    # Extract the keyword generated by the model
    keyword = chat_comp.choices[0].message.content.strip()

    # Step 2: Use the generated keyword as the query parameter for the YouTube API
    youtube_api_endpoint = "https://www.googleapis.com/youtube/v3/search"
    params = {
        "part": "snippet",
        "maxResults": 10,
        "q": keyword,
        "type": "video",
        "key": YOUTUBE_API_KEY,
    }

    # Make the request to the YouTube API
    response = requests.get(youtube_api_endpoint, params=params)

    if response.status_code == 200:
        youtube_data = response.json()
        videos = []

        # Step 3: Extract video IDs, titles, and thumbnails
        for item in youtube_data.get("items", []):
            video_id = item.get("id", {}).get("videoId")
            snippet = item.get("snippet", {})
            if video_id:
                video_url = f"https://www.youtube.com/watch?v={video_id}"
                thumbnail_url = snippet.get("thumbnails", {}).get("default", {}).get("url")
                video_title = snippet.get("title", "No title available")
                videos.append({
                    "url": video_url,
                    "thumbnail": thumbnail_url,
                    "title": video_title
                })

        # Step 4: Return the constructed URLs and thumbnails as JSON
        return jsonify({
            "keyword": keyword,
            "videos": videos
        })
    else:
        return jsonify({
            "error": f"Failed to fetch YouTube data: {response.status_code}",
            "details": response.text
        }), 500
    
@app.route('/bias_free', methods=['POST'])
def analyze_article3254():
    try:
        # Get the article from the request body
        data = request.get_json()
        article = data.get("article")

        if not article:
            return jsonify({"error": "Article content is required"}), 400

        # Construct the prompt
        prompt = f""""
          Rewrite the given article in a neutral tone, removing bias, political stance, and subjective language while maintaining factual accuracy. List the changes made to ensure neutrality and provide a brief summary of the rewritten article.
          Ensure the rewritten article is in paragraph form, the changes are detailed and clear, and the summary is concise. Article: {article}, also the fields should be in string format.Also just give the json response nd no other notes, 
while also making sure the field is one whole string and not seperated into chunks and also make sure the strings are not seperated for each field .MAKE SURE TO NOT RESPOND WITH ANY OTHER TEXTS OTHER THAN JSON FIELDS, dont give the intro such as"here is the rewritten article", just the response
                   Return the response in the JSON format below:

{{
  "changes": [],
  "rewritten_article": "",
  "summary": ""
}}

                  """


        # Call Groq API
        chat_comp = client.chat.completions.create(
            messages=[
                {"role": "user", "content": prompt}
            ],
            model="llama-3.3-70b-versatile",
        )

        # Extract response
        response_content = chat_comp.choices[0].message.content

        return response_content, 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="180.235.121.245", debug=True, port=40734)
