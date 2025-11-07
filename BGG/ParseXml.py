import xml.etree.ElementTree as ET

class Game:
    def __init__(self, id, name, year):
        self.id = id
        self.name = name
        self.year = year

    def __repr__(self):
        return f"Game(id={self.id}, name='{self.name}', year={self.year})"

# Parse the XML file
tree = ET.parse('response.xml')
root = tree.getroot()

games = []
for item in root.findall('item'):
    id_ = item.find('id').text
    name = item.find('name').text
    year = item.find('year').text
    games.append(Game(id_, name, year))

# Print the parsed objects
for game in games:
    print(game)