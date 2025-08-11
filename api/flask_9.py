from groq import Groq
from flask import Flask, request, jsonify
import json
import re
app = Flask(__name__)
client = Groq(api_key="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")


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
    app.run(host="180.235.121.245", debug=True, port=40731)