import requests

# The URL to which you want to send the XML request
url = "https://boardgamegeek.com/xmlapi2/type=boardgame"  # Replace with your target URL

# The XML data to send
xml_data = """<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>User</to>
  <from>Assistant</from>
  <heading>Reminder</heading>
  <body>This is a test XML request.</body>
</note>"""

# Set the appropriate headers for XML
headers = {
    "Content-Type": "application/xml"
}

# Send the POST request with XML data
response = requests.post(url, data=xml_data, headers=headers)

# Print the response text
print("Status code:", response.status_code)
print("Response body:")
print(response.text)