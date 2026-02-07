"""
Validate the polygon JSON dataset.

This script reads the polygon dataset and verifies that:
- Each polygon is simple (no self-intersecting edges)
- Each test point has the correct location classification
- Each polygon has at least one edge point
"""

import json
import sys
import os

# Add parent directory to path for geometry imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from geometry import Polygon, Point


def validate_polygon(polygon_data: dict, verbose: bool = True) -> dict:
    """
    Validate a single polygon and its test points.
    
    Args:
        polygon_data: Dictionary with polygon vertices and test points.
        verbose: If True, print detailed output.
    
    Returns:
        Dictionary with validation results.
    """
    polygon_id = polygon_data['id']
    
    result = {
        'polygon_id': polygon_id,
        'valid': True,
        'errors': [],
        'warnings': []
    }
    
    try:
        # Create polygon from vertices
        vertices = polygon_data['vertices']
        
        if len(vertices) < 3:
            result['errors'].append(
                f"Too few vertices: {len(vertices)} (minimum 3 required)"
            )
            result['valid'] = False
            return result
        
        coords = [[v['x'], v['y']] for v in vertices]
        polygon = Polygon.from_list(coords)
        
        # Check for overlapping edges
        edges = polygon.get_edges()
        has_overlaps = False
        for i in range(len(edges)):
            for j in range(i + 1, len(edges)):
                if edges[i].overlaps(edges[j]):
                    result['errors'].append(f"Edges {i} and {j} overlap (lie on top of each other)")
                    has_overlaps = True
        
        if has_overlaps:
            result['valid'] = False
        
        # Check if polygon is simple
        if not polygon.is_simple():
            result['errors'].append("Polygon is not simple (has self-intersecting or overlapping edges)")
            result['valid'] = False
        
        # Validate test points
        test_points = polygon_data.get('test_points', [])
        
        if not test_points:
            result['warnings'].append("No test points defined")
        
        # Check for at least one boundary point
        boundary_points = [tp for tp in test_points if tp['location'] == 'BOUNDARY']
        if not boundary_points:
            result['errors'].append("No boundary point in test points (required)")
            result['valid'] = False
        
        # Validate each test point's location
        misclassified = 0
        for i, tp in enumerate(test_points):
            point = Point(tp['x'], tp['y'])
            expected_location = tp['location']
            actual_location = polygon.point_location(point)
            
            if expected_location != actual_location:
                misclassified += 1
                result['errors'].append(
                    f"Test point {i+1} misclassified: expected '{expected_location}', got '{actual_location}'"
                )
                result['valid'] = False
        
        # Add polygon info
        result['num_vertices'] = len(vertices)
        result['num_test_points'] = len(test_points)
        result['area'] = polygon.area()
        result['is_convex'] = polygon.is_convex()
        
    except Exception as e:
        result['errors'].append(f"Error validating polygon: {str(e)}")
        result['valid'] = False
    
    return result


def validate_dataset(input_file: str, verbose: bool = True) -> dict:
    """
    Validate all polygons in the JSON dataset.
    
    Args:
        input_file: Path to the JSON file.
        verbose: If True, print detailed output.
    
    Returns:
        Dictionary with validation summary.
    """
    if not os.path.exists(input_file):
        print(f"Error: File not found: {input_file}")
        return {'error': 'File not found'}
    
    with open(input_file, 'r') as f:
        dataset = json.load(f)
    
    results = {
        'total': 0,
        'valid': 0,
        'invalid': 0,
        'with_warnings': 0,
        'convex_count': 0,
        'total_points': 0,
        'details': []
    }
    
    print(f"Validating polygons in: {input_file}")
    print("-" * 60)
    
    metadata = dataset.get('metadata', {})
    print(f"Dataset metadata:")
    print(f"  Polygons: {metadata.get('num_polygons', 'N/A')}")
    print(f"  Total points: {metadata.get('total_points', 'N/A')}")
    print("-" * 60)
    
    polygons = dataset.get('polygons', [])
    
    for polygon_data in polygons:
        result = validate_polygon(polygon_data, verbose)
        results['details'].append(result)
        results['total'] += 1
        results['total_points'] += result.get('num_test_points', 0)
        
        if result['valid']:
            results['valid'] += 1
            if result.get('is_convex'):
                results['convex_count'] += 1
        else:
            results['invalid'] += 1
        
        if result['warnings']:
            results['with_warnings'] += 1
        
        # Print progress for invalid/problematic polygons
        if verbose:
            if not result['valid']:
                print(f"❌ Polygon {result['polygon_id']}: INVALID")
                for error in result['errors']:
                    print(f"   Error: {error}")
            elif result['warnings']:
                print(f"⚠️ Polygon {result['polygon_id']}: Valid with warnings")
                for warning in result['warnings']:
                    print(f"   Warning: {warning}")
    
    # Print summary
    print("-" * 60)
    print(f"\nValidation Summary:")
    print(f"  Total polygons:     {results['total']}")
    print(f"  Valid polygons:     {results['valid']} ✓")
    print(f"  Invalid polygons:   {results['invalid']} ✗")
    print(f"  With warnings:      {results['with_warnings']}")
    print(f"  Convex polygons:    {results['convex_count']}")
    print(f"  Total test points:  {results['total_points']}")
    
    if results['valid'] == results['total']:
        print(f"\n✅ All {results['total']} polygons are valid!")
    else:
        print(f"\n⚠️ {results['invalid']} polygon(s) failed validation.")
    
    return results


def main():
    """Main entry point for validation script."""
    # Default to polygons.json in the parent directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    default_file = os.path.join(parent_dir, "polygons.json")
    
    # Allow command line argument for custom file
    input_file = sys.argv[1] if len(sys.argv) > 1 else default_file
    
    results = validate_dataset(input_file, verbose=True)
    
    # Return exit code based on validation
    if results.get('invalid', 0) > 0:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
