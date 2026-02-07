"""
Point class for 2D geometry operations.
"""

from __future__ import annotations
import math


class Point:
    """Represents a 2D point with x and y coordinates."""
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y
    
    def __repr__(self) -> str:
        return f"Point({self.x}, {self.y})"
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Point):
            return False
        return math.isclose(self.x, other.x) and math.isclose(self.y, other.y)
    
    def __hash__(self) -> int:
        return hash((round(self.x, 10), round(self.y, 10)))
    
    def distance_to(self, other: Point) -> float:
        """Calculate Euclidean distance to another point."""
        return math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2)
    
    def to_tuple(self) -> tuple[float, float]:
        """Return point as a tuple (x, y)."""
        return (self.x, self.y)
    
    @staticmethod
    def from_tuple(t: tuple[float, float]) -> Point:
        """Create a Point from a tuple."""
        return Point(t[0], t[1])
    
    def __sub__(self, other: Point) -> Point:
        """Subtract two points (vector subtraction)."""
        return Point(self.x - other.x, self.y - other.y)
    
    def __add__(self, other: Point) -> Point:
        """Add two points (vector addition)."""
        return Point(self.x + other.x, self.y + other.y)
    
    def cross(self, other: Point) -> float:
        """Calculate cross product of two vectors (as points from origin)."""
        return self.x * other.y - self.y * other.x
