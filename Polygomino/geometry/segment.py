"""
Segment class for line segment operations.
"""

from __future__ import annotations
from .point import Point


class Segment:
    """Represents a line segment between two points."""
    
    def __init__(self, p1: Point, p2: Point):
        self.p1 = p1
        self.p2 = p2
    
    def __repr__(self) -> str:
        return f"Segment({self.p1}, {self.p2})"
    
    @staticmethod
    def _ccw(a: Point, b: Point, c: Point) -> float:
        """
        Returns the cross product of vectors (b-a) and (c-a).
        Positive if counter-clockwise, negative if clockwise, 0 if collinear.
        """
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    
    @staticmethod
    def _on_segment(p: Point, q: Point, r: Point) -> bool:
        """
        Check if point q lies on segment pr, given that p, q, r are collinear.
        """
        return (min(p.x, r.x) <= q.x <= max(p.x, r.x) and
                min(p.y, r.y) <= q.y <= max(p.y, r.y))
    
    def intersects(self, other: Segment, proper: bool = False) -> bool:
        """
        Check if this segment intersects with another segment.
        
        Args:
            other: The other segment to check intersection with.
            proper: If True, only count proper intersections (not at endpoints).
                   If False, also count intersections at endpoints.
        
        Returns:
            True if segments intersect, False otherwise.
        """
        p1, q1 = self.p1, self.p2
        p2, q2 = other.p1, other.p2
        
        d1 = self._ccw(p2, q2, p1)
        d2 = self._ccw(p2, q2, q1)
        d3 = self._ccw(p1, q1, p2)
        d4 = self._ccw(p1, q1, q2)
        
        if proper:
            # For proper intersection, we need strictly opposite signs
            # This excludes touching at endpoints
            if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
               ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                return True
            return False
        else:
            # General intersection including endpoints
            if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
               ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                return True
            
            # Check collinear cases
            if d1 == 0 and self._on_segment(p2, p1, q2):
                return True
            if d2 == 0 and self._on_segment(p2, q1, q2):
                return True
            if d3 == 0 and self._on_segment(p1, p2, q1):
                return True
            if d4 == 0 and self._on_segment(p1, q2, q1):
                return True
            
            return False
    
    def shares_endpoint(self, other: Segment) -> bool:
        """Check if two segments share an endpoint."""
        return (self.p1 == other.p1 or self.p1 == other.p2 or
                self.p2 == other.p1 or self.p2 == other.p2)
    
    def length(self) -> float:
        """Calculate the length of the segment."""
        return self.p1.distance_to(self.p2)
    
    def contains_point(self, point: Point, tolerance: float = 0.5) -> bool:
        """
        Check if a point lies on this segment.
        
        Args:
            point: The point to check.
            tolerance: Numerical tolerance for comparisons.
                       Default of 0.5 is suitable for integer coordinates.
        
        Returns:
            True if the point lies on the segment, False otherwise.
        """
        # Check if point is within the bounding box first (fast rejection)
        if not (min(self.p1.x, self.p2.x) - tolerance <= point.x <= max(self.p1.x, self.p2.x) + tolerance and
                min(self.p1.y, self.p2.y) - tolerance <= point.y <= max(self.p1.y, self.p2.y) + tolerance):
            return False
        
        # Check if point is collinear with segment endpoints using cross product
        # For integer coordinates, cross product should be exactly 0 for collinear points
        cross = self._ccw(self.p1, self.p2, point)
        
        return abs(cross) <= tolerance
    
    def random_point_on_segment(self) -> Point:
        """
        Generate a random point on this segment with integer coordinates.
        
        Returns:
            A Point with integer coordinates that lies on the segment (not at endpoints).
        """
        import random
        # Use t between 0.1 and 0.9 to avoid endpoints
        t = random.uniform(0.1, 0.9)
        x = int(round(self.p1.x + t * (self.p2.x - self.p1.x)))
        y = int(round(self.p1.y + t * (self.p2.y - self.p1.y)))
        return Point(x, y)
    
    def overlaps(self, other: 'Segment', tolerance: float = 0.5) -> bool:
        """
        Check if this segment overlaps with another segment.
        Two segments overlap if they are collinear and share more than a single point.
        
        Args:
            other: The other segment to check.
            tolerance: Numerical tolerance for collinearity check.
        
        Returns:
            True if segments overlap (share a line portion), False otherwise.
        """
        # Check if all four points are collinear
        d1 = self._ccw(self.p1, self.p2, other.p1)
        d2 = self._ccw(self.p1, self.p2, other.p2)
        
        # If not collinear, they can't overlap
        if abs(d1) > tolerance or abs(d2) > tolerance:
            return False
        
        # All points are collinear - check if ranges overlap
        # Project onto x-axis (or y-axis if vertical)
        if abs(self.p2.x - self.p1.x) > abs(self.p2.y - self.p1.y):
            # Use x-axis projection
            min1, max1 = min(self.p1.x, self.p2.x), max(self.p1.x, self.p2.x)
            min2, max2 = min(other.p1.x, other.p2.x), max(other.p1.x, other.p2.x)
        else:
            # Use y-axis projection
            min1, max1 = min(self.p1.y, self.p2.y), max(self.p1.y, self.p2.y)
            min2, max2 = min(other.p1.y, other.p2.y), max(other.p1.y, other.p2.y)
        
        # Calculate overlap length
        overlap_start = max(min1, min2)
        overlap_end = min(max1, max2)
        overlap_length = overlap_end - overlap_start
        
        # Overlap if they share more than a single point (length > 0)
        return overlap_length > tolerance
