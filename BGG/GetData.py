import requests

# function that performs a get operation on a url and writes the xml text to a file
def get_data(url):
    # Set the appropriate headers for XML (optional for GET)
    headers = {
        "Accept": "application/xml"
    }

    # Send the GET request
    response = requests.get(url, headers=headers)

    # Write the response text to a file
    with open('response.xml', 'w', encoding='utf-8') as f:
        f.write(response.text)

    print(f"Status code: {response.status_code}")
    print("Response written to response.xml")

# Main function
if __name__ == "__main__":
    url = "https://www.boardgamegeek.com/xmlapi2/thing?id=013"
    get_data(url)


