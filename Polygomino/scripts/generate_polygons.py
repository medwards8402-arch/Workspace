"""
Generate simple polygons with test points and save them to a JSON file.

This script generates random simple (non-self-intersecting) polygons
with 3 to 25 vertices, along with random test points classified as
INSIDE, OUTSIDE, or BOUNDARY.
"""

import json
import random
import math
import sys
import os

# Add parent directory to path for geometry imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from geometry import Point, Polygon, Segment


# Coordinate range for all polygons
COORD_MIN = -100
COORD_MAX = 100


def generate_convex_polygon(num_vertices: int, center: Point = None, 
                            radius: int = 80) -> Polygon:
    """
    Generate a random convex polygon by placing points around a circle.
    Convex polygons are always simple. All coordinates are integers.
    
    Args:
        num_vertices: Number of vertices for the polygon.
        center: Center point of the polygon.
        radius: Approximate radius of the polygon.
    
    Returns:
        A Polygon object with integer coordinates.
    """
    if center is None:
        center = Point(random.randint(-30, 30), random.randint(-30, 30))
    
    # Generate random angles with irregular spacing
    angles = []
    angle = random.uniform(0, 0.5)
    for _ in range(num_vertices):
        angles.append(angle)
        # Irregular angle steps for less circular shapes
        angle += random.uniform(0.3, 2.5) * (2 * math.pi / num_vertices)
    
    # Normalize to 2*pi range
    max_angle = max(angles)
    angles = [a * 2 * math.pi / max_angle for a in angles]
    
    # Generate vertices with high radius variation
    vertices = []
    for angle in angles:
        r = radius * random.uniform(0.2, 1.0)
        x = int(round(center.x + r * math.cos(angle)))
        y = int(round(center.y + r * math.sin(angle)))
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
    
    return Polygon(vertices)


def generate_jagged_polygon(num_vertices: int) -> Polygon:
    """
    Generate a jagged, maze-like polygon with sharp turns and indentations.
    
    Args:
        num_vertices: Number of vertices for the polygon.
    
    Returns:
        A Polygon object with integer coordinates.
    """
    center = Point(random.randint(-20, 20), random.randint(-20, 20))
    vertices = []
    
    # Create base angles with irregular spacing
    base_angles = []
    angle = 0
    for i in range(num_vertices):
        base_angles.append(angle)
        angle += random.uniform(0.5, 1.5) * (2 * math.pi / num_vertices)
    
    # Normalize
    max_angle = max(base_angles) if base_angles else 1
    base_angles = [a * 2 * math.pi / max_angle for a in base_angles]
    
    # Create jagged pattern with deep indentations
    for i, angle in enumerate(base_angles):
        # Alternate between far and near with high variance
        if i % 3 == 0:
            r = random.randint(60, 95)
        elif i % 3 == 1:
            r = random.randint(20, 45)
        else:
            r = random.randint(35, 70)
        
        x = int(round(center.x + r * math.cos(angle)))
        y = int(round(center.y + r * math.sin(angle)))
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
    
    return Polygon(vertices)


def generate_comb_polygon(num_vertices: int) -> Polygon:
    """
    Generate a comb-like polygon with teeth/protrusions.
    
    Args:
        num_vertices: Number of vertices (should be >= 6).
    
    Returns:
        A Polygon object with integer coordinates.
    """
    # Ensure even number for comb pattern
    if num_vertices < 6:
        num_vertices = 6
    
    center = Point(random.randint(-15, 15), random.randint(-15, 15))
    vertices = []
    
    num_teeth = num_vertices // 2
    tooth_angle = 2 * math.pi / num_teeth
    
    for i in range(num_teeth):
        angle = i * tooth_angle + random.uniform(-0.1, 0.1)
        
        # Outer point (tooth tip)
        r_outer = random.randint(70, 95)
        x = int(round(center.x + r_outer * math.cos(angle)))
        y = int(round(center.y + r_outer * math.sin(angle)))
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
        
        # Inner point (between teeth) - deep indentation
        angle_inner = angle + tooth_angle * 0.5
        r_inner = random.randint(15, 35)
        x = int(round(center.x + r_inner * math.cos(angle_inner)))
        y = int(round(center.y + r_inner * math.sin(angle_inner)))
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
    
    return Polygon(vertices)


def generate_blob_polygon(num_vertices: int) -> Polygon:
    """
    Generate an irregular blob-like polygon using noise-based radius.
    
    Args:
        num_vertices: Number of vertices for the polygon.
    
    Returns:
        A Polygon object with integer coordinates.
    """
    center = Point(random.randint(-25, 25), random.randint(-25, 25))
    vertices = []
    
    # Generate base shape with multiple frequency noise
    base_radius = random.randint(40, 70)
    
    for i in range(num_vertices):
        angle = (i / num_vertices) * 2 * math.pi
        
        # Multi-frequency noise for organic irregularity
        noise = (
            0.3 * math.sin(angle * 2 + random.uniform(0, math.pi)) +
            0.2 * math.sin(angle * 3 + random.uniform(0, math.pi)) +
            0.15 * math.sin(angle * 5 + random.uniform(0, math.pi)) +
            random.uniform(-0.25, 0.25)
        )
        
        r = base_radius * (1 + noise)
        r = max(15, min(95, r))
        
        x = int(round(center.x + r * math.cos(angle)))
        y = int(round(center.y + r * math.sin(angle)))
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
    
    return Polygon(vertices)


def generate_angular_polygon(num_vertices: int) -> Polygon:
    """
    Generate a polygon with sharp angular features, like a maze outline.
    
    Args:
        num_vertices: Number of vertices for the polygon.
    
    Returns:
        A Polygon object with integer coordinates.
    """
    # Start from a corner and build outward
    vertices = []
    
    # Random starting point
    x = random.randint(-80, 80)
    y = random.randint(-80, 80)
    vertices.append(Point(x, y))
    
    # Build path with mostly orthogonal or 45-degree moves
    directions = [
        (1, 0), (1, 1), (0, 1), (-1, 1),
        (-1, 0), (-1, -1), (0, -1), (1, -1)
    ]
    
    last_dir = random.choice(directions)
    
    for _ in range(num_vertices - 1):
        # Prefer continuing or turning 45-90 degrees
        dir_idx = directions.index(last_dir)
        turn = random.choice([-2, -1, 0, 1, 2])  # Turn amount
        new_dir = directions[(dir_idx + turn) % 8]
        
        # Random step size
        step = random.randint(15, 50)
        
        new_x = vertices[-1].x + new_dir[0] * step
        new_y = vertices[-1].y + new_dir[1] * step
        
        # Clamp and add
        new_x = max(COORD_MIN, min(COORD_MAX, new_x))
        new_y = max(COORD_MIN, min(COORD_MAX, new_y))
        vertices.append(Point(new_x, new_y))
        
        last_dir = new_dir
    
    return Polygon(vertices)


def generate_star_polygon(num_points: int, center: Point = None,
                          outer_radius: int = 80, 
                          inner_radius: int = 40) -> Polygon:
    """
    Generate a star-shaped simple polygon. All coordinates are integers.
    
    Args:
        num_points: Number of star points (total vertices = 2 * num_points).
        center: Center point of the star.
        outer_radius: Radius to outer points.
        inner_radius: Radius to inner points.
    
    Returns:
        A Polygon object with integer coordinates.
    """
    if center is None:
        # Random center for variety
        center = Point(random.randint(-20, 20), random.randint(-20, 20))
    
    # Randomize radii for zany stars
    outer_radius = random.randint(50, 95)
    inner_radius = random.randint(15, outer_radius // 2)
    
    vertices = []
    angle_step = math.pi / num_points
    # Random rotation offset
    rotation = random.uniform(0, 2 * math.pi)
    
    for i in range(2 * num_points):
        angle = i * angle_step + rotation
        if i % 2 == 0:
            r = outer_radius * random.uniform(0.7, 1.0)
        else:
            r = inner_radius * random.uniform(0.5, 1.0)
        
        x = int(round(center.x + r * math.cos(angle)))
        y = int(round(center.y + r * math.sin(angle)))
        # Clamp to valid range
        x = max(COORD_MIN, min(COORD_MAX, x))
        y = max(COORD_MIN, min(COORD_MAX, y))
        vertices.append(Point(x, y))
    
    return Polygon(vertices)


def generate_random_simple_polygon(num_vertices: int, 
                                   max_attempts: int = 100) -> Polygon:
    """
    Generate a random simple polygon using various maze-like methods.
    
    Args:
        num_vertices: Target number of vertices (3 to 25).
        max_attempts: Maximum attempts to generate a valid polygon.
    
    Returns:
        A Polygon object that is guaranteed to be simple.
    """
    for _ in range(max_attempts):
        # Weight towards more interesting shapes, less stars/circles
        method = random.choices(
            ['jagged', 'comb', 'blob', 'angular', 'perturbed_convex', 'convex', 'star'],
            weights=[25, 20, 20, 15, 10, 5, 5],
            k=1
        )[0]
        
        if method == 'jagged':
            polygon = generate_jagged_polygon(num_vertices)
            
        elif method == 'comb' and num_vertices >= 6:
            polygon = generate_comb_polygon(num_vertices)
            
        elif method == 'blob':
            polygon = generate_blob_polygon(num_vertices)
            
        elif method == 'angular' and num_vertices >= 5:
            polygon = generate_angular_polygon(num_vertices)
            
        elif method == 'convex':
            polygon = generate_convex_polygon(num_vertices)
            
        elif method == 'perturbed_convex':
            # Start with convex and aggressively perturb vertices
            polygon = generate_convex_polygon(num_vertices)
            vertices = polygon.vertices.copy()
            
            # Perturb vertices with larger offsets
            for i in range(len(vertices)):
                if random.random() < 0.6:  # 60% chance to perturb
                    dx = random.randint(-30, 30)
                    dy = random.randint(-30, 30)
                    new_x = max(COORD_MIN, min(COORD_MAX, vertices[i].x + dx))
                    new_y = max(COORD_MIN, min(COORD_MAX, vertices[i].y + dy))
                    vertices[i] = Point(new_x, new_y)
            
            polygon = Polygon(vertices)
            
        elif method == 'star' and num_vertices >= 6 and num_vertices % 2 == 0:
            polygon = generate_star_polygon(num_vertices // 2)
            
        else:
            # Default to jagged for variety
            polygon = generate_jagged_polygon(num_vertices)
        
        # Verify the polygon is simple
        if polygon.is_simple():
            return polygon
    
    # Fallback: return a regular polygon (always simple)
    return generate_convex_polygon(num_vertices)


def generate_random_point_in_bbox(polygon: Polygon, padding: float = 0.2) -> Point:
    """
    Generate a random integer point within the polygon's extended bounding box.
    
    Args:
        polygon: The polygon to generate a point around.
        padding: Fraction to extend bounding box (0.2 = 20%).
    
    Returns:
        A random Point with integer coordinates.
    """
    coords = polygon.to_list()
    
    min_x = min(c[0] for c in coords)
    max_x = max(c[0] for c in coords)
    min_y = min(c[1] for c in coords)
    max_y = max(c[1] for c in coords)
    
    width = max_x - min_x
    height = max_y - min_y
    
    min_x = int(min_x - width * padding)
    max_x = int(max_x + width * padding)
    min_y = int(min_y - height * padding)
    max_y = int(max_y + height * padding)
    
    # Clamp to valid range
    min_x = max(COORD_MIN, min_x)
    max_x = min(COORD_MAX, max_x)
    min_y = max(COORD_MIN, min_y)
    max_y = min(COORD_MAX, max_y)
    
    x = random.randint(min_x, max_x)
    y = random.randint(min_y, max_y)
    
    return Point(x, y)


def find_integer_point_on_edge(edge: Segment) -> Point:
    """
    Find an integer point that lies on the edge (not at endpoints).
    Uses a search approach to find valid integer coordinates.
    
    Args:
        edge: The segment to find a point on.
    
    Returns:
        A Point with integer coordinates on the edge, or None if none found.
    """
    p1, p2 = edge.p1, edge.p2
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    
    # Try several t values and find one where the result rounds to integers
    # that still lie on the segment
    best_point = None
    best_error = float('inf')
    
    for _ in range(20):  # Try 20 random positions
        t = random.uniform(0.15, 0.85)  # Avoid endpoints
        x_exact = p1.x + t * dx
        y_exact = p1.y + t * dy
        x_int = int(round(x_exact))
        y_int = int(round(y_exact))
        
        # Check if this integer point is actually on the segment
        # by verifying the cross product is 0 (collinear)
        cross = (x_int - p1.x) * dy - (y_int - p1.y) * dx
        
        if abs(cross) < best_error:
            best_error = abs(cross)
            best_point = Point(x_int, y_int)
            
            if cross == 0:  # Perfect match
                # Verify it's within segment bounds
                if (min(p1.x, p2.x) <= x_int <= max(p1.x, p2.x) and
                    min(p1.y, p2.y) <= y_int <= max(p1.y, p2.y)):
                    return best_point
    
    return best_point  # Return best approximation if no perfect match


def generate_edge_point(polygon: Polygon, allow_vertex: bool = False) -> tuple:
    """
    Generate a point that lies on a random edge of the polygon.
    
    Args:
        polygon: The polygon to generate an edge point for.
        allow_vertex: If True, may return a vertex point (rare ~5%).
    
    Returns:
        Tuple of (Point, is_on_edge) where is_on_edge is True if validated.
    """
    if allow_vertex and random.random() < 0.05:  # 5% chance to return a vertex
        # Return a random vertex (guaranteed to be on edge)
        vertex = random.choice(polygon.vertices)
        return Point(int(vertex.x), int(vertex.y)), True
    
    # Try to find an integer point on a random edge
    edges = polygon.get_edges()
    random.shuffle(edges)
    
    for edge in edges:
        point = find_integer_point_on_edge(edge)
        if point:
            # Verify using polygon's point_location
            if polygon.point_location(point) == 'BOUNDARY':
                return point, True
    
    # Fallback to vertex if no valid edge point found
    vertex = random.choice(polygon.vertices)
    return Point(int(vertex.x), int(vertex.y)), True


def generate_vertex_point(polygon: Polygon) -> Point:
    """
    Generate a point that is exactly on a random vertex of the polygon.
    
    Args:
        polygon: The polygon to get a vertex from.
    
    Returns:
        A Point that is one of the polygon's vertices.
    """
    vertex = random.choice(polygon.vertices)
    return Point(int(vertex.x), int(vertex.y))


def generate_inside_point(polygon: Polygon, max_attempts: int = 50) -> Point:
    """
    Generate a random point that is guaranteed to be inside the polygon.
    Uses rejection sampling within the polygon's bounding box.
    
    Args:
        polygon: The polygon to generate an inside point for.
        max_attempts: Maximum attempts before giving up.
    
    Returns:
        A Point inside the polygon, or None if not found.
    """
    coords = polygon.to_list()
    min_x = min(c[0] for c in coords)
    max_x = max(c[0] for c in coords)
    min_y = min(c[1] for c in coords)
    max_y = max(c[1] for c in coords)
    
    for _ in range(max_attempts):
        x = random.randint(int(min_x), int(max_x))
        y = random.randint(int(min_y), int(max_y))
        point = Point(x, y)
        if polygon.point_location(point) == 'INSIDE':
            return point
    
    return None


def generate_outside_point(polygon: Polygon, max_attempts: int = 50) -> Point:
    """
    Generate a random point that is guaranteed to be outside the polygon.
    Uses rejection sampling within an extended bounding box.
    
    Args:
        polygon: The polygon to generate an outside point for.
        max_attempts: Maximum attempts before giving up.
    
    Returns:
        A Point outside the polygon, or None if not found.
    """
    coords = polygon.to_list()
    min_x = min(c[0] for c in coords)
    max_x = max(c[0] for c in coords)
    min_y = min(c[1] for c in coords)
    max_y = max(c[1] for c in coords)
    
    # Extend bounding box
    width = max_x - min_x
    height = max_y - min_y
    ext_min_x = max(COORD_MIN, int(min_x - width * 0.3))
    ext_max_x = min(COORD_MAX, int(max_x + width * 0.3))
    ext_min_y = max(COORD_MIN, int(min_y - height * 0.3))
    ext_max_y = min(COORD_MAX, int(max_y + height * 0.3))
    
    for _ in range(max_attempts):
        x = random.randint(ext_min_x, ext_max_x)
        y = random.randint(ext_min_y, ext_max_y)
        point = Point(x, y)
        if polygon.point_location(point) == 'OUTSIDE':
            return point
    
    return None


def generate_test_points_for_polygon(polygon: Polygon, max_points: int = 10) -> list:
    """
    Generate random test points for a polygon with balanced INSIDE/OUTSIDE.
    Guarantees at least one boundary point.
    
    Args:
        polygon: The polygon to generate points for.
        max_points: Maximum number of points to generate.
    
    Returns:
        List of dictionaries with integer point coordinates and location.
    """
    # Random number of points (at least 3 for variety, up to max_points)
    num_points = random.randint(3, max_points)
    
    test_points = []
    
    # First, guarantee at least one boundary point (could rarely be a vertex)
    edge_point, _ = generate_edge_point(polygon, allow_vertex=True)
    test_points.append({
        'x': int(edge_point.x),
        'y': int(edge_point.y),
        'location': 'BOUNDARY'
    })
    
    # Calculate how many inside/outside points we want (roughly equal)
    remaining = num_points - 1
    target_inside = remaining // 2
    target_outside = remaining - target_inside
    
    # Generate inside points
    inside_count = 0
    for _ in range(target_inside):
        point = generate_inside_point(polygon)
        if point:
            test_points.append({
                'x': int(point.x),
                'y': int(point.y),
                'location': 'INSIDE'
            })
            inside_count += 1
    
    # Generate outside points
    outside_count = 0
    for _ in range(target_outside):
        point = generate_outside_point(polygon)
        if point:
            test_points.append({
                'x': int(point.x),
                'y': int(point.y),
                'location': 'OUTSIDE'
            })
            outside_count += 1
    
    # Fill any gaps with random points if rejection sampling failed
    while len(test_points) < num_points:
        # Try to balance - prefer whichever type we're short on
        if inside_count < target_inside:
            point = generate_inside_point(polygon)
            if point:
                test_points.append({
                    'x': int(point.x),
                    'y': int(point.y),
                    'location': 'INSIDE'
                })
                inside_count += 1
                continue
        
        if outside_count < target_outside:
            point = generate_outside_point(polygon)
            if point:
                test_points.append({
                    'x': int(point.x),
                    'y': int(point.y),
                    'location': 'OUTSIDE'
                })
                outside_count += 1
                continue
        
        # Fallback to random
        point = generate_random_point_in_bbox(polygon)
        location = polygon.point_location(point)
        test_points.append({
            'x': int(point.x),
            'y': int(point.y),
            'location': location
        })
    
    # Rare chance (3%) to add a vertex point
    if random.random() < 0.03 and len(test_points) < max_points:
        vertex_point = generate_vertex_point(polygon)
        test_points.append({
            'x': int(vertex_point.x),
            'y': int(vertex_point.y),
            'location': 'BOUNDARY'
        })
    
    # Shuffle so the edge point isn't always first
    random.shuffle(test_points)
    
    return test_points


def polygon_to_dict(polygon: Polygon) -> list:
    """
    Convert a polygon to a list of vertex dictionaries.
    
    Args:
        polygon: The Polygon to convert.
    
    Returns:
        List of {x, y} dictionaries.
    """
    return [{'x': v.x, 'y': v.y} for v in polygon.vertices]


def generate_polygon_dataset(num_polygons: int = 100, 
                              min_vertices: int = 3,
                              max_vertices: int = 25,
                              max_points_per_polygon: int = 10,
                              output_file: str = "polygons.json") -> None:
    """
    Generate a dataset of simple polygons with test points and save to JSON.
    
    Args:
        num_polygons: Number of polygons to generate.
        min_vertices: Minimum vertices per polygon.
        max_vertices: Maximum vertices per polygon.
        max_points_per_polygon: Maximum test points per polygon.
        output_file: Path to output JSON file.
    """
    print(f"Generating {num_polygons} simple polygons with test points...")
    
    dataset = {
        'metadata': {
            'num_polygons': num_polygons,
            'min_vertices': min_vertices,
            'max_vertices': max_vertices,
            'max_points_per_polygon': max_points_per_polygon
        },
        'polygons': []
    }
    
    total_points = 0
    location_counts = {'INSIDE': 0, 'OUTSIDE': 0, 'BOUNDARY': 0}
    
    for i in range(num_polygons):
        num_vertices = random.randint(min_vertices, max_vertices)
        polygon = generate_random_simple_polygon(num_vertices)
        test_points = generate_test_points_for_polygon(polygon, max_points_per_polygon)
        
        polygon_data = {
            'id': i + 1,
            'vertices': polygon_to_dict(polygon),
            'test_points': test_points
        }
        
        dataset['polygons'].append(polygon_data)
        
        # Track statistics
        total_points += len(test_points)
        for tp in test_points:
            location_counts[tp['location']] += 1
        
        if (i + 1) % 20 == 0:
            print(f"  Generated {i + 1}/{num_polygons} polygons...")
    
    # Add statistics to metadata
    dataset['metadata']['total_points'] = total_points
    dataset['metadata']['point_counts'] = location_counts
    
    # Write to JSON
    print(f"Writing to {output_file}...")
    with open(output_file, 'w') as f:
        json.dump(dataset, f, indent=2)
    
    print(f"Done! Generated {num_polygons} polygons with {total_points} total test points.")
    print(f"Output saved to: {output_file}")
    
    # Print summary statistics
    vertex_counts = [len(p['vertices']) for p in dataset['polygons']]
    print(f"\nSummary:")
    print(f"  Polygons: {num_polygons}")
    print(f"  Vertex range: {min(vertex_counts)}-{max(vertex_counts)} (avg: {sum(vertex_counts)/len(vertex_counts):.1f})")
    print(f"  Total test points: {total_points}")
    print(f"    Inside: {location_counts['INSIDE']}")
    print(f"    Outside: {location_counts['OUTSIDE']}")
    print(f"    Boundary: {location_counts['BOUNDARY']}")


if __name__ == "__main__":
    # Set random seed for reproducibility (optional)
    # random.seed(42)
    
    # Generate the dataset
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    output_path = os.path.join(parent_dir, "polygons.json")
    
    generate_polygon_dataset(
        num_polygons=100,
        min_vertices=3,
        max_vertices=25,
        max_points_per_polygon=10,
        output_file=output_path
    )
