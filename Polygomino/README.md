# Polygomino - Simple Polygon Dataset & Geometry Library

A Python project for generating, validating, visualizing, and working with simple polygons. Built with Pygame for future game development.

## Project Structure

```
Polygomino/
├── geometry/                 # Geometry library
│   ├── __init__.py
│   ├── point.py             # Point class for 2D coordinates
│   ├── segment.py           # Segment class for line segments
│   └── polygon.py           # Polygon class for polygon operations
├── scripts/                  # Dataset utilities
│   ├── generate_polygons.py # Script to generate polygon dataset
│   └── validate_polygons.py # Script to validate polygons
├── game/                     # Pygame-based visualization & game
│   └── polygon_viewer.py    # Interactive polygon viewer
├── polygons.json             # Generated dataset with polygons and test points
└── README.md
```

## Requirements

```bash
pip install pygame
```

## Dataset Format

The polygon dataset is stored in `polygons.json` with the following structure:

- **All coordinates are integers** in the range **-100 to 100**
- Each polygon has 3-25 vertices
- Each polygon includes 1-10 test points with pre-computed locations
- Edge points are typically placed on polygon vertices to ensure exact integer coordinates
- Rare vertex-based edge points (~5% chance per test point)

```json
{
  "metadata": {
    "num_polygons": 100,
    "total_points": 567,
    "point_counts": {"INSIDE": 117, "OUTSIDE": 335, "BOUNDARY": 115}
  },
  "polygons": [
    {
      "id": 1,
      "vertices": [{"x": 45, "y": 9}, {"x": 50, "y": 14}, ...],
      "test_points": [
        {"x": 33, "y": 10, "location": "INSIDE"},
        {"x": -95, "y": -22, "location": "OUTSIDE"},
        {"x": 45, "y": 9, "location": "BOUNDARY"}
      ]
    },
    ...
  ]
}
```

Each polygon includes:
- **vertices**: List of {x, y} integer coordinates defining the simple polygon
- **test_points**: 1-10 random points with pre-computed location classifications (INSIDE, OUTSIDE, BOUNDARY)
- At least one point is guaranteed to be on the boundary (usually a vertex)

## Geometry Library

### Point
```python
from geometry import Point

p1 = Point(0, 0)
p2 = Point(3, 4)

# Calculate distance
dist = p1.distance_to(p2)  # 5.0

# Vector operations
diff = p2 - p1  # Point(3, 4)
```

### Segment
```python
from geometry import Segment, Point

seg1 = Segment(Point(0, 0), Point(2, 2))
seg2 = Segment(Point(0, 2), Point(2, 0))

# Check intersection
seg1.intersects(seg2)  # True
seg1.intersects(seg2, proper=True)  # True (proper intersection)

# Get length
length = seg1.length()
```

### Polygon
```python
from geometry import Polygon, Point

# Create from points
vertices = [Point(0, 0), Point(4, 0), Point(4, 3), Point(0, 3)]
poly = Polygon(vertices)

# Or from list of coordinates
poly = Polygon.from_list([[0, 0], [4, 0], [4, 3], [0, 3]])

# Check if simple (no self-intersections)
poly.is_simple()  # True

# Check if convex
poly.is_convex()  # True

# Calculate properties
area = poly.area()        # 12.0
perimeter = poly.perimeter()
centroid = poly.centroid()

# Get edges
edges = poly.get_edges()  # List of Segment objects

# Point-in-polygon testing
location = poly.point_location(Point(2, 1.5))  # 'INSIDE', 'OUTSIDE', or 'BOUNDARY'
is_inside = poly.contains_point(Point(2, 1.5))  # True/False
```

## Scripts

### Generate Polygons
```bash
python scripts/generate_polygons.py
```

Generates 100 simple polygons with 3-25 vertices and 1-10 test points per polygon. Saves to `polygons.json`. Each polygon is guaranteed to have at least one edge point.

### Validate Polygons
```bash
python scripts/validate_polygons.py
python scripts/validate_polygons.py path/to/custom_polygons.json
```

Validates that all polygons in the JSON are:
- Properly formatted with vertices and test points
- Are simple (no self-intersecting edges)
- Have correctly classified test point locations
- Include at least one edge point

### Polygon Viewer
```bash
python game/polygon_viewer.py
```

Interactive viewer for exploring the polygon dataset:
- **Navigation**: Arrow keys (← →), A/D keys, or click buttons
- **Display**: Shows polygon with highlighted vertices, edges, and test points
- **Test Points**: Green = inside, Red = outside, Yellow = edge
- **Info Panel**: Displays vertex count, area, perimeter, convexity, and point counts
- **ESC**: Quit the viewer

## What is a Simple Polygon?

A simple polygon is a polygon whose edges:
1. Only intersect at their endpoints
2. Non-adjacent edges do not cross each other

Examples:
- ✅ Triangle, square, regular polygons - always simple
- ✅ Star shapes (when properly constructed) - can be simple
- ❌ Figure-eight shape - NOT simple (edges cross)
- ❌ Self-overlapping shapes - NOT simple

## Generation Methods

The generator uses several methods to create simple polygons:

1. **Convex Polygons**: Points placed around a circle at random angles (always simple)
2. **Perturbed Convex**: Convex polygons with slightly moved vertices (validated for simplicity)
3. **Star Polygons**: Alternating inner/outer radii for star shapes
