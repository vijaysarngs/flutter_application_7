from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import mysql.connector
from mysql.connector import Error
import subprocess
import json
app = Flask(__name__)

# Enable CORS
CORS(app, resources={r"/*": {"origins": "*"}})

# Database connection
def create_connection():
    try:
        return mysql.connector.connect(
            host="localhost",
            user="root",
            password="Kutta@123",
            database="your_database"
        )
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    category = data.get('category')
    source = data.get('source')

    # Validate required fields
    if not name or not email or not password:
        return jsonify({"message": "All fields are required."}), 400

    # Validate agreedToTerms
    

    try:
        connection = create_connection()
        cursor = connection.cursor()

        # Check if the user already exists
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        existing_user = cursor.fetchone()
        if existing_user:
            return jsonify({"message": "User already exists."}), 400

        # Insert new user
        cursor.execute(
            "INSERT INTO users (name, email, password, category, source) VALUES (%s, %s, %s, %s, %s)",
            (name, email, password, category, source),
        )
        connection.commit()

        cursor.close()
        connection.close()

        # Always return a JSON response
        return jsonify({"message": "User created successfully."}), 201
    except Exception as e:
        return jsonify({"message": f"Server error: {e}"}), 500

# @app.route('/signup', methods=['POST'])
# def signup():
#     data = request.json

#     name = data.get('name')
#     email = data.get('email')
#     password = data.get('password')
#     agreed_to_terms = data.get('agreedToTerms',False) 
#     category = data.get('category', '')
#     source = data.get('source', '')
    

#     # Ensure all required fields are present
#     if not name or not email or not password:
#         return jsonify({"message": "Missing required fields"}), 400

#     connection = create_connection()
#     if connection is None:
#         return jsonify({"message": "Unable to connect to the database"}), 500

#     try:
#         cursor = connection.cursor()

#         query = """
#             INSERT INTO users (name, email, password, agreed_to_terms, category, source) 
#             VALUES (%s, %s, %s, %s, %s, %s)
#         """
#         values = (name, email, password, agreed_to_terms,category, source)

#         cursor.execute(query, values)
#         connection.commit()

#         cursor.close()
#         connection.close()

#         return jsonify({
#             "message": "User registered successfully", "status_code": 201
#         }),201

#     except Error as e:
#         print(f"Database error: {e}")
#         return jsonify({"message": f"Database error occurred: {str(e)}"}), 500


@app.route('/signin', methods=['POST'])
def signin():
    data = request.json

    email = data.get('email')
    password = data.get('password')

    # Validate required fields
    if not email or not password:
        return jsonify({"message": "Missing email or password", "status_code": 400}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"message": "Unable to connect to the database", "status_code": 500}), 500

    try:
        cursor = connection.cursor()

        # SQL query to fetch user data
        query = "SELECT id, name, email, category, source FROM users WHERE email = %s AND password = %s"
        cursor.execute(query, (email, password))
        user = cursor.fetchone()

        if user:
            return jsonify({
                "message": "Sign-in successful",
                "user": {
                    "id": user[0],
                    "name": user[1],
                    "email": user[2],
                    "category": user[3],  # Added category field
                    "source": user[4],     # Added source field
                    "status_code": 200
                }
            }), 200
        else:
            return jsonify({
                "message": "Invalid email or password",
                "status_code": 401
            }), 401  # Unauthorized

    except Error as e:
        print(f"Database error: {e}")
        return jsonify({"message": f"Database error: {e}", "status_code": 500}), 500
    finally:
        cursor.close()
        connection.close()
def classify_article_with_ollama(article):
    prompt = f"""
    Classify the following article as 'left,' 'right,' or 'center' based on its political stance. 
    Additionally, provide a brief explanation for your classification.

    Article:
    {article}

    Your response format should be following the json format as:
    {{
        "classification": "left/right/center",
        "explanation": "Provide a clear explanation here."
    }}
    """

    try:
        result = subprocess.run(
            ["ollama", "run", "llama3.2"],
            input=prompt,
            text=True,
            capture_output=True,
            encoding="utf-8",
            errors="replace"
        )

        print("Raw response from Ollama:", result.stdout)

        if result.returncode != 0:
            error_message = f"Subprocess failed with return code {result.returncode}: {result.stderr.strip()}"
            print(error_message)
            return {"error": error_message}

        response = result.stdout.strip()

        # Validate the JSON format
        try:
            classification_data = json.loads(response)
        except json.JSONDecodeError as e:
            error_message = f"Failed to decode JSON response from Ollama: {e}. Response: {response}"
            print(error_message)
            return {"error": error_message}

        # Validate expected keys in JSON
        if "classification" not in classification_data or "explanation" not in classification_data:
            error_message = "Response JSON does not contain expected keys: 'classification' and 'explanation'."
            print(error_message)
            return {"error": error_message}

        return classification_data

    except FileNotFoundError:
        error_message = "Ollama is not installed or not found in the system PATH."
        print(error_message)
        return {"error": error_message}
    except Exception as e:
        error_message = f"An unexpected error occurred: {str(e)}"
        print(error_message)
        return {"error": error_message}

@app.route('/classify', methods=['POST'])
def classify_article():
    try:
        data = request.json
        article=data.get('article','')

        if 'article' not in data:
            return jsonify({"error": "No article content provided"}), 400


        result = classify_article_with_ollama(article)

        if "error" in result:
            return jsonify(result), 500
        else:
            return jsonify({
                "classification": result["classification"],
                "explanation": result["explanation"]
            })
    except Exception as e:
        error_message = f"An unexpected error occurred in the API: {str(e)}"
        print(error_message)
        return jsonify({"error": error_message}), 500

@app.route('/submit_feedback', methods=['POST'])
def submit_feedback():
    conn = create_connection()
    cursor = conn.cursor()

    try:
        # Get the request data from the Flutter frontend
        data = request.json
        email = data.get('email')
        rating = data.get('rating')
        review = data.get('review')

        # Validate the input
        if not email or not rating or review is None:
            return jsonify({'error': 'All fields (email, rating, feedback) are required'}), 400

        # if not isinstance(rating, int) or rating < 1 or rating > 5:
        #     return jsonify({'error': 'Rating must be an integer between 1 and 5'}), 400

        # Connect to the MySQL database
        
        # Insert data into the feedback table
        insert_query = """
            INSERT INTO feedback (user_email, rating, review)
            VALUES (%s, %s, %s)
        """
        cursor.execute(insert_query, (email, rating, review))
        conn.commit()

        return jsonify({'message': 'Feedback submitted successfully!'}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': f'Database error: {str(err)}'}), 500

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

@app.route('/feedbacks', methods=['GET'])
def get_feedbacks():
    conn = create_connection()
    cursor = conn.cursor(dictionary=True)  # Dictionary cursor for column names as keys

    try:
        # Query to fetch all feedback records
        query = """
            SELECT 
                id, 
                user_email AS email, 
                rating, 
                review, 
                created_at
            FROM 
                feedback
        """
        cursor.execute(query)
        feedbacks = cursor.fetchall()
        return jsonify(feedbacks), 200

    except mysql.connector.Error as err:
        return jsonify({'error': f'Database error: {str(err)}'}), 500

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

### Endpoint to Delete Feedback ###
@app.route('/feedbacks/<int:feedback_id>', methods=['DELETE'])
def delete_feedback(feedback_id):
    conn = create_connection()
    cursor = conn.cursor()

    try:
        # Query to delete a specific feedback by ID
        query = "DELETE FROM feedback WHERE id = %s"
        cursor.execute(query, (feedback_id,))
        conn.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': 'Feedback not found'}), 404

        return jsonify({'message': 'Feedback deleted successfully'}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': f'Database error: {str(err)}'}), 500

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    app.run(host='180.235.121.245', debug=True, port=40735)
