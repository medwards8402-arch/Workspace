"""
Polygon class for polygon operations.
"""

from __future__ import annotations
from typing import List
from .point import Point
from .segment import Segment


class Polygon:
    """Represents a polygon defined by a list of vertices."""
    
    def __init__(self, vertices: List[Point]):
        """
        Initialize a polygon with a list of vertices.
        
        Args:
            vertices: List of Point objects defining the polygon vertices.
                     The polygon is closed automatically (first vertex connects to last).
        """
        if len(vertices) < 3:
            raise ValueError("A polygon must have at least 3 vertices")
        self.vertices = vertices
    
    def __repr__(self) -> str:
        return f"Polygon({len(self.vertices)} vertices)"
    
    @property
    def num_vertices(self) -> int:
        """Return the number of vertices in the polygon."""
        return len(self.vertices)
    
    def get_edges(self) -> List[Segment]:
        """
        Get all edges of the polygon as segments.
        
        Returns:
            List of Segment objects representing the polygon edges.
        """
        edges = []
        n = len(self.vertices)
        for i in range(n):
            edges.append(Segment(self.vertices[i], self.vertices[(i + 1) % n]))
        return edges
    
    def is_simple(self) -> bool:
        """
        Check if the polygon is simple (no self-intersecting or overlapping edges).
        
        A simple polygon has edges that only meet at their endpoints,
        non-adjacent edges do not intersect, and no edges overlap.
        
        Returns:
            True if the polygon is simple, False otherwise.
        """
        edges = self.get_edges()
        n = len(edges)
        
        for i in range(n):
            for j in range(i + 1, n):
                # Skip adjacent edges for intersection check (they share a vertex)
                is_adjacent = (j == i + 1) or (i == 0 and j == n - 1)
                
                if is_adjacent:
                    # Adjacent edges should not overlap
                    if edges[i].overlaps(edges[j]):
                        return False
                else:
                    # Non-adjacent edges should not intersect or overlap
                    if edges[i].intersects(edges[j], proper=True):
                        return False
                    if edges[i].overlaps(edges[j]):
                        return False
        
        return True
    
    def area(self) -> float:
        """
        Calculate the area of the polygon using the shoelace formula.
        
        Returns:
            The absolute area of the polygon.
        """
        n = len(self.vertices)
        area = 0.0
        for i in range(n):
            j = (i + 1) % n
            area += self.vertices[i].x * self.vertices[j].y
            area -= self.vertices[j].x * self.vertices[i].y
        return abs(area) / 2.0
    
    def perimeter(self) -> float:
        """
        Calculate the perimeter of the polygon.
        
        Returns:
            The total length of all edges.
        """
        return sum(edge.length() for edge in self.get_edges())
    
    def centroid(self) -> Point:
        """
        Calculate the centroid (center of mass) of the polygon.
        
        Returns:
            A Point representing the centroid.
        """
        n = len(self.vertices)
        cx = sum(v.x for v in self.vertices) / n
        cy = sum(v.y for v in self.vertices) / n
        return Point(cx, cy)
    
    def to_list(self) -> List[List[float]]:
        """
        Convert polygon to a list of [x, y] coordinate pairs.
        
        Returns:
            List of [x, y] pairs.
        """
        return [[v.x, v.y] for v in self.vertices]
    
    @staticmethod
    def from_list(coords: List[List[float]]) -> Polygon:
        """
        Create a Polygon from a list of [x, y] coordinate pairs.
        
        Args:
            coords: List of [x, y] pairs.
        
        Returns:
            A Polygon object.
        """
        vertices = [Point(c[0], c[1]) for c in coords]
        return Polygon(vertices)
    
    def is_convex(self) -> bool:
        """
        Check if the polygon is convex.
        
        Returns:
            True if the polygon is convex, False otherwise.
        """
        n = len(self.vertices)
        if n < 3:
            return False
        
        sign = None
        for i in range(n):
            p1 = self.vertices[i]
            p2 = self.vertices[(i + 1) % n]
            p3 = self.vertices[(i + 2) % n]
            
            cross = (p2 - p1).cross(p3 - p2)
            
            if cross != 0:
                current_sign = cross > 0
                if sign is None:
                    sign = current_sign
                elif sign != current_sign:
                    return False
        
        return True
    
    def point_location(self, point: Point, tolerance: float = 0.5) -> str:
        """
        Determine if a point is inside, outside, or on an edge of the polygon.
        
        Uses the ray casting algorithm to determine point location.
        
        Args:
            point: The point to check.
            tolerance: Numerical tolerance for edge detection.
                       Default of 0.5 is suitable for integer coordinates.
        
        Returns:
            'INSIDE': Point is inside the polygon.
            'OUTSIDE': Point is outside the polygon.
            'BOUNDARY': Point is on the boundary of the polygon.
        """
        # First check if point is on any edge (boundary)
        for edge in self.get_edges():
            if edge.contains_point(point, tolerance):
                return 'BOUNDARY'
        
        # Ray casting algorithm
        # Cast a ray from point to the right (positive x direction)
        # Count how many edges the ray crosses
        n = len(self.vertices)
        crossings = 0
        
        for i in range(n):
            v1 = self.vertices[i]
            v2 = self.vertices[(i + 1) % n]
            
            # Check if the edge crosses the horizontal ray from point
            # The ray goes from (point.x, point.y) to (infinity, point.y)
            
            # Skip if edge is entirely above or below the ray
            if (v1.y > point.y and v2.y > point.y) or \
               (v1.y <= point.y and v2.y <= point.y):
                continue
            
            # Calculate x-coordinate where edge crosses the ray's y-level
            # Using linear interpolation
            t = (point.y - v1.y) / (v2.y - v1.y)
            x_intersect = v1.x + t * (v2.x - v1.x)
            
            # Count crossing if intersection is to the right of point
            if x_intersect > point.x:
                crossings += 1
        
        # Odd number of crossings means inside
        if crossings % 2 == 1:
            return 'INSIDE'
        else:
            return 'OUTSIDE'
    
    def contains_point(self, point: Point) -> bool:
        """
        Check if a point is inside or on the boundary of the polygon.
        
        Args:
            point: The point to check.
        
        Returns:
            True if point is inside or on boundary, False if outside.
        """
        location = self.point_location(point)
        return location in ('INSIDE', 'BOUNDARY')
