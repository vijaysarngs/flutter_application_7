from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import http.client
import json
app = Flask(__name__)
CORS(app)

API_URL = "https://eventregistry.org/api/v1/article/getArticles"
API_KEY = "f8a41aca-c7ed-4092-b1f9-155249e3b295"
NEWS_API_KEY = "5378b113380e4777a595687ed0d1633f"
NEWS_API_BASE_URL = "https://newsapi.org/v2/everything"
MEDIASTACK_API_URL = "http://api.mediastack.com/v1/news"
MEDIASTACK_ACCESS_KEY = "b8330d8e29744bb2049acafed70bf333"
GNEWS_API_URL = "https://gnews.io/api/v4/search"
API_KEY = "13617d20cd790f3babe0abb66730793a"  # Replace with your actual API key

NEWS_API_KEY_NEWW = '13617d20cd790f3babe0abb66730793a'

NEWS_API_BASE_URL_NEWW = 'https://gnews.io/api/v4/top-headlines'
@app.route('/api/articles', methods=['GET'])
def get_articles():
    try:
        # Get category, location, and language from the request arguments
        category = request.args.get('category', 'general')  # Default to 'general' if no category is provided
        location = request.args.get('location', 'in')  # Default to 'in' (India) if no location is provided
        language = request.args.get('language', 'en')  # Default to 'en' (English) if no language is provided
        page = int(request.args.get('page', 1))  # Default to page 1 if no page is provided

        # Construct the URL with the parameters included directly
        url = f"{NEWS_API_BASE_URL_NEWW}?q={category}&apikey={NEWS_API_KEY_NEWW}&min=40&max=100&country={location}&lang={language}&page={page}"

        # Get the articles from the Gnews API
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for unsuccessful status codes

        articles_data = response.json().get('data', [])  # Extract the articles from the response

        # Format the articles to match the frontend structure
        formatted_articles = [
            {
                'title': article.get('title', 'No title'),
                'summary': article.get('description', 'No summary available'),
                'url': article.get('url', '#'),
                'date': article.get('publishedAt', 'Unknown date'),
                'source': article.get('source', {}).get('name', 'Unknown source'),
                'imageUrl': article.get('image', 'https://via.placeholder.com/150')  # Default placeholder if no image
            }
            for article in articles_data  # Ensure articles have an image
        ]

        # Return results
        if formatted_articles:
            return jsonify({'status': 'success', 'articles': formatted_articles}), 200
        else:
            return jsonify({'status': 'error', 'message': 'No articles found with images'}), 404

    except requests.exceptions.RequestException as e:
        return jsonify({'status': 'error', 'message': f'API request error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Internal server error: {str(e)}'}), 500
NEWS_API_BASE_URLLL = 'https://gnews.io/api/v4/top-headlines'

@app.route('/news', methods=['GET'])
def get_news():
    try:
        # Default category to 'general' if no category is provided
        category = request.args.get('category', 'general')  # Default to 'general' if no category is provided
        page = int(request.args.get('page', 1))  

        # Construct the URL with the parameters included directly
        url = f"{NEWS_API_BASE_URLLL}?category=science&apikey={NEWS_API_KEY_NEWW}&lang=en&page={page}&country=in"

        # Get the articles from the Gnews API
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for unsuccessful status codes

        articles_data = response.json().get('articles', [])  # Extract the articles from the response

        # Format the articles to match the frontend structure
        formatted_articles = [
            {
                'title': article.get('title', 'No title'),
                'description': article.get('description', 'No description available'),
                'content': article.get('content', 'No content available'),
                'url': article.get('url', '#'),
                'imageUrl': article.get('image', 'https://via.placeholder.com/150'),
                'publishedAt': article.get('publishedAt', 'Unknown date'),
                'source': article.get('source', {}).get('name', 'Unknown source'),
            }
            for article in articles_data  # Ensure articles have necessary fields
        ]

        # Return results
        if formatted_articles:
            return jsonify({'status': 'success', 'articles': formatted_articles}), 200
        else:
            return jsonify({'status': 'error', 'message': 'No articles found'}), 404

    except requests.exceptions.RequestException as e:
        return jsonify({'status': 'error', 'message': f'API request error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Internal server error: {str(e)}'}), 500


@app.route('/category-news', methods=['GET'])
def get_category_news():
    try:
        # Get category from the request arguments, default to 'general' if not provided
        # page = int(request.args.get('page', 1))  # Default to page 1 if no page is provided

        # Construct the URL with the parameters included directly
        url = f"{NEWS_API_BASE_URLLL}?category={request.args.get('category')}&apikey={NEWS_API_KEY_NEWW}&lang=en&country=in"

        # Get the articles from the Gnews API
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for unsuccessful status codes

        articles_data = response.json().get('articles', [])  # Extract the articles from the response

        # Format the articles to match the frontend structure
        formatted_articles = [
            {
                'title': article.get('title', 'No title'),
                'description': article.get('description', 'No description available'),
                'content': article.get('content', 'No content available'),
                'url': article.get('url', '#'),
                'imageUrl': article.get('image', 'https://via.placeholder.com/150'),
                'publishedAt': article.get('publishedAt', 'Unknown date'),
                'source': article.get('source', {}).get('name', 'Unknown source'),
            }
            for article in articles_data  # Ensure articles have necessary fields
        ]

        # Return results
        if formatted_articles:
            return jsonify({'status': 'success', 'articles': formatted_articles}), 200
        else:
            return jsonify({'status': 'error', 'message': 'No articles found for this category'}), 404

    except requests.exceptions.RequestException as e:
        return jsonify({'status': 'error', 'message': f'API request error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Internal server error: {str(e)}'}), 500

@app.route('/article-details', methods=['POST'])
def fetch_article_details():
    api_url = "http://analytics.eventregistry.org/api/v1/extractArticleInfo"
    headers = {
        "Content-Type": "application/json"
    }

    data = request.get_json()
    article_url = data.get('url')
    api_key = "f8a41aca-c7ed-4092-b1f9-155249e3b295"

    if not article_url:
        return jsonify({"error": "Article URL is required"}), 400

    try:
        response = requests.post(
            api_url,
            headers=headers,
            json={"url": article_url, "apiKey": api_key}
        )

        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({
                "error": "Failed to fetch article details",
                "status_code": response.status_code,
                "message": response.text
            }), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def fetch_media_bias_data(source_name):
    conn = http.client.HTTPSConnection("political-bias-database.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': "c61480be18msh222aeaa86ab2f8bp162cf7jsn81954872764e",
        'x-rapidapi-host': "political-bias-database.p.rapidapi.com"
    }

    conn.request("GET", "/MBFCdata", headers=headers)
    res = conn.getresponse()
    data = res.read()

    try:
        # Parse the API response
        all_sources = json.loads(data)
        # Search for the source
        for source in all_sources:
            if source_name.lower() in source['name'].lower():
                return source  # Return the matching source details

        return None  # If source is not found
    except json.JSONDecodeError:
        return None  # Error decoding response

@app.route('/fetch_media_bias', methods=['GET'])
def fetch_media_bias():
    source_name = request.args.get('name')
    if not source_name:
        return jsonify({"error": "Source name is required."}), 400
    
    result = fetch_media_bias_data(source_name)
    
    if result:
        return jsonify(result)
    else:
        return jsonify({"error": f"No data found for the source '{source_name}'."}), 404
NEWS_API_BASE_URL32 = "https://newsapi.org/v2/everything"
NEWS_API_KEY32 = "5378b113380e4777a595687ed0d1633f"
@app.route('/news43', methods=['GET'])
def get_news32():
    try:
        # Construct the URL with the parameters included directly
        url = f"{NEWS_API_BASE_URL32}?q=general&apiKey={NEWS_API_KEY32}&page=1&language=en"

        # Get the articles from the NewsAPI
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for unsuccessful status codes

        # Extract articles from the API response
        articles_data = response.json().get('articles', [])  # Extract the articles from the response

        # Format the articles to match the frontend structure and ignore invalid articles
        formatted_articles = [
            {
                'title': article['title'],
                'description': article['description'],
                'content': article['content'],
                'url': article['url'],
                'imageUrl': article['urlToImage'] if article.get('urlToImage') else 'https://via.placeholder.com/150',
                'publishedAt': article['publishedAt'],
                'source': article['source']['name'] if article.get('source') else 'Unknown source',
            }
            for article in articles_data
            if article.get('title') and article.get('description') and article.get('content') and article.get('url') and article.get('publishedAt') and article.get('source', {}).get('name')
        ]

        # Return results
        if formatted_articles:
            return jsonify({'status': 'success', 'articles': formatted_articles}), 200
        else:
            return jsonify({'status': 'error', 'message': 'No articles found'}), 404

    except requests.exceptions.RequestException as e:
        return jsonify({'status': 'error', 'message': f'API request error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Internal server error: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host="180.235.121.245",debug=True,port=40733)
