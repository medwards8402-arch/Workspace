"""
Polygon Visualizer using Pygame.

A simple viewer for exploring the polygon dataset with forward/backward navigation.
This is the foundation for a future polygon-based game.
"""

import pygame
import sys
import os
import json
import random

# Add parent directory to path for geometry imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from geometry import Polygon, Point


# ============================================================================
# Constants
# ============================================================================

# Window settings
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 768
FPS = 60

# Colors
COLOR_BACKGROUND = (30, 30, 40)
COLOR_POLYGON_FILL = (60, 120, 180, 128)
COLOR_POLYGON_EDGE = (100, 200, 255)
COLOR_VERTEX = (255, 200, 50)
COLOR_VERTEX_OUTLINE = (255, 255, 255)
COLOR_TEXT = (255, 255, 255)
COLOR_TEXT_DIM = (150, 150, 150)
COLOR_BUTTON = (70, 70, 90)
COLOR_BUTTON_HOVER = (90, 90, 120)
COLOR_BUTTON_TEXT = (255, 255, 255)
COLOR_INFO_BG = (40, 40, 55)

# Test point colors based on location
COLOR_POINT_INSIDE = (50, 255, 50)      # Green - inside polygon
COLOR_POINT_OUTSIDE = (255, 50, 50)     # Red - outside polygon
COLOR_POINT_EDGE = (255, 255, 50)       # Yellow - on edge

# Sizes
VERTEX_RADIUS = 8
TEST_POINT_RADIUS = 6
EDGE_WIDTH = 3
BUTTON_WIDTH = 120
BUTTON_HEIGHT = 50
BUTTON_MARGIN = 20


# ============================================================================
# UI Components
# ============================================================================

class Button:
    """Simple clickable button for the UI."""
    
    def __init__(self, x: int, y: int, width: int, height: int, text: str):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.hovered = False
        self.font = None
    
    def set_font(self, font: pygame.font.Font):
        self.font = font
    
    def handle_event(self, event: pygame.event.Event) -> bool:
        """Handle mouse events. Returns True if button was clicked."""
        if event.type == pygame.MOUSEMOTION:
            self.hovered = self.rect.collidepoint(event.pos)
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if event.button == 1 and self.rect.collidepoint(event.pos):
                return True
        return False
    
    def draw(self, surface: pygame.Surface):
        """Draw the button on the surface."""
        color = COLOR_BUTTON_HOVER if self.hovered else COLOR_BUTTON
        pygame.draw.rect(surface, color, self.rect, border_radius=8)
        pygame.draw.rect(surface, COLOR_TEXT_DIM, self.rect, width=2, border_radius=8)
        
        if self.font:
            text_surface = self.font.render(self.text, True, COLOR_BUTTON_TEXT)
            text_rect = text_surface.get_rect(center=self.rect.center)
            surface.blit(text_surface, text_rect)


# ============================================================================
# Polygon Loading
# ============================================================================

def load_polygons_from_json(filepath: str) -> list:
    """
    Load polygons and test points from a JSON file.
    
    Args:
        filepath: Path to the JSON file.
    
    Returns:
        List of dictionaries containing polygon data and test points.
    """
    with open(filepath, 'r') as f:
        dataset = json.load(f)
    
    polygons = []
    
    for polygon_data in dataset.get('polygons', []):
        # Create polygon from vertices
        vertices = polygon_data['vertices']
        coords = [[v['x'], v['y']] for v in vertices]
        polygon = Polygon.from_list(coords)
        
        # Load test points
        test_points = []
        for tp in polygon_data.get('test_points', []):
            test_points.append({
                'point': Point(tp['x'], tp['y']),
                'location': tp['location']
            })
        
        polygons.append({
            'id': polygon_data['id'],
            'num_vertices': polygon.num_vertices,
            'polygon': polygon,
            'coords': coords,
            'test_points': test_points
        })
    
    return polygons


# ============================================================================
# Polygon Rendering
# ============================================================================

def transform_polygon_to_screen(polygon: Polygon, 
                                 screen_width: int, 
                                 screen_height: int,
                                 padding: int = 100) -> list:
    """
    Transform polygon coordinates to fit within screen bounds.
    Uses a fixed coordinate system from -100 to 100.
    
    Args:
        polygon: The Polygon to transform.
        screen_width: Width of the display area.
        screen_height: Height of the display area.
        padding: Padding around the polygon.
    
    Returns:
        List of (x, y) tuples in screen coordinates.
    """
    coords = polygon.to_list()
    
    if not coords:
        return []
    
    # Use fixed coordinate range -100 to 100
    min_x, max_x = -100, 100
    min_y, max_y = -100, 100
    
    # Calculate scale to fit in screen
    poly_width = max_x - min_x   # 200
    poly_height = max_y - min_y  # 200
    
    available_width = screen_width - 2 * padding
    available_height = screen_height - 2 * padding - 150  # Extra space for UI
    
    scale_x = available_width / poly_width
    scale_y = available_height / poly_height
    scale = min(scale_x, scale_y)
    
    # Center the polygon
    scaled_width = poly_width * scale
    scaled_height = poly_height * scale
    offset_x = (screen_width - scaled_width) / 2
    offset_y = (screen_height - scaled_height) / 2 - 50  # Shift up for UI
    
    # Transform coordinates
    screen_coords = []
    for x, y in coords:
        sx = (x - min_x) * scale + offset_x
        sy = (y - min_y) * scale + offset_y
        screen_coords.append((sx, sy))
    
    return screen_coords


def draw_polygon(surface: pygame.Surface, 
                 screen_coords: list,
                 draw_fill: bool = True):
    """
    Draw a polygon with vertices and edges clearly visible.
    
    Args:
        surface: Pygame surface to draw on.
        screen_coords: List of (x, y) screen coordinates.
        draw_fill: Whether to draw a filled polygon.
    """
    if len(screen_coords) < 3:
        return
    
    # Draw filled polygon (with transparency)
    if draw_fill:
        # Create a temporary surface for transparency
        temp_surface = pygame.Surface(surface.get_size(), pygame.SRCALPHA)
        pygame.draw.polygon(temp_surface, COLOR_POLYGON_FILL, screen_coords)
        surface.blit(temp_surface, (0, 0))
    
    # Draw edges
    for i in range(len(screen_coords)):
        start = screen_coords[i]
        end = screen_coords[(i + 1) % len(screen_coords)]
        pygame.draw.line(surface, COLOR_POLYGON_EDGE, start, end, EDGE_WIDTH)
    
    # Draw vertices (on top of edges)
    for i, (x, y) in enumerate(screen_coords):
        # Outer circle (outline)
        pygame.draw.circle(surface, COLOR_VERTEX_OUTLINE, (int(x), int(y)), 
                          VERTEX_RADIUS + 2)
        # Inner circle (filled)
        pygame.draw.circle(surface, COLOR_VERTEX, (int(x), int(y)), 
                          VERTEX_RADIUS)


def draw_info_panel(surface: pygame.Surface, 
                    polygon_data: dict,
                    current_index: int,
                    total_count: int,
                    font: pygame.font.Font,
                    small_font: pygame.font.Font):
    """
    Draw information panel about the current polygon.
    
    Args:
        surface: Pygame surface to draw on.
        polygon_data: Dictionary with polygon information.
        current_index: Current polygon index (0-based).
        total_count: Total number of polygons.
        font: Main font for text.
        small_font: Smaller font for details.
    """
    # Draw info background
    info_rect = pygame.Rect(20, 20, 300, 140)
    pygame.draw.rect(surface, COLOR_INFO_BG, info_rect, border_radius=10)
    pygame.draw.rect(surface, COLOR_TEXT_DIM, info_rect, width=1, border_radius=10)
    
    # Title
    title = f"Polygon {polygon_data['id']} of {total_count}"
    title_surface = font.render(title, True, COLOR_TEXT)
    surface.blit(title_surface, (35, 30))
    
    # Polygon details
    polygon = polygon_data['polygon']
    details = [
        f"Vertices: {polygon_data['num_vertices']}",
        f"Area: {polygon.area():.2f}",
        f"Perimeter: {polygon.perimeter():.2f}",
        f"Convex: {'Yes' if polygon.is_convex() else 'No'}",
    ]
    
    y_offset = 65
    for detail in details:
        detail_surface = small_font.render(detail, True, COLOR_TEXT_DIM)
        surface.blit(detail_surface, (35, y_offset))
        y_offset += 22


def draw_controls_help(surface: pygame.Surface, 
                       font: pygame.font.Font,
                       screen_height: int):
    """Draw keyboard controls help text."""
    help_text = "← → Arrow Keys or A/D to navigate  |  ESC to quit"
    help_surface = font.render(help_text, True, COLOR_TEXT_DIM)
    help_rect = help_surface.get_rect(centerx=surface.get_width() // 2, 
                                       bottom=screen_height - 15)
    surface.blit(help_surface, help_rect)


# ============================================================================
# Test Point Rendering
# ============================================================================


def transform_point_to_screen(point: Point, polygon: Polygon,
                               screen_width: int, screen_height: int,
                               padding: int = 100) -> tuple:
    """
    Transform a point to screen coordinates using the same transformation
    as the polygon. Uses fixed coordinate system from -100 to 100.
    
    Args:
        point: The point to transform.
        polygon: The polygon (unused, kept for API compatibility).
        screen_width: Width of the display area.
        screen_height: Height of the display area.
        padding: Padding around the polygon.
    
    Returns:
        Tuple (x, y) in screen coordinates.
    """
    # Use fixed coordinate range -100 to 100
    min_x, max_x = -100, 100
    min_y, max_y = -100, 100
    
    poly_width = max_x - min_x   # 200
    poly_height = max_y - min_y  # 200
    
    available_width = screen_width - 2 * padding
    available_height = screen_height - 2 * padding - 150
    
    scale_x = available_width / poly_width
    scale_y = available_height / poly_height
    scale = min(scale_x, scale_y)
    
    scaled_width = poly_width * scale
    scaled_height = poly_height * scale
    offset_x = (screen_width - scaled_width) / 2
    offset_y = (screen_height - scaled_height) / 2 - 50
    
    # Transform point
    sx = (point.x - min_x) * scale + offset_x
    sy = (point.y - min_y) * scale + offset_y
    
    return (sx, sy)


def draw_test_points(surface: pygame.Surface, test_points: list,
                     polygon: Polygon, screen_width: int, screen_height: int):
    """
    Draw test points with colors based on their location relative to the polygon.
    
    Args:
        surface: Pygame surface to draw on.
        test_points: List of test point dictionaries with 'point' and 'location'.
        polygon: The polygon (used for coordinate transformation).
        screen_width: Width of the display area.
        screen_height: Height of the display area.
    """
    for test_point in test_points:
        point = test_point['point']
        location = test_point['location']
        
        # Choose color based on location
        if location == 'INSIDE':
            color = COLOR_POINT_INSIDE
        elif location == 'OUTSIDE':
            color = COLOR_POINT_OUTSIDE
        else:  # BOUNDARY
            color = COLOR_POINT_EDGE
        
        # Transform to screen coordinates
        sx, sy = transform_point_to_screen(point, polygon, 
                                           screen_width, screen_height)
        
        # Draw the point
        pygame.draw.circle(surface, COLOR_VERTEX_OUTLINE, 
                          (int(sx), int(sy)), TEST_POINT_RADIUS + 2)
        pygame.draw.circle(surface, color, (int(sx), int(sy)), TEST_POINT_RADIUS)


def draw_test_point_legend(surface: pygame.Surface, font: pygame.font.Font,
                           test_points: list):
    """
    Draw a legend showing test point colors and their counts.
    
    Args:
        surface: Pygame surface to draw on.
        font: Font for legend text.
        test_points: List of test point dictionaries.
    """
    # Count points by location
    counts = {'INSIDE': 0, 'OUTSIDE': 0, 'BOUNDARY': 0}
    for tp in test_points:
        counts[tp['location']] += 1
    
    # Draw legend in top-right corner
    legend_x = surface.get_width() - 180
    legend_y = 20
    
    # Background
    legend_rect = pygame.Rect(legend_x - 10, legend_y - 5, 170, 95)
    pygame.draw.rect(surface, COLOR_INFO_BG, legend_rect, border_radius=10)
    pygame.draw.rect(surface, COLOR_TEXT_DIM, legend_rect, width=1, border_radius=10)
    
    # Legend items
    items = [
        (COLOR_POINT_INSIDE, f"Inside: {counts['INSIDE']}"),
        (COLOR_POINT_OUTSIDE, f"Outside: {counts['OUTSIDE']}"),
        (COLOR_POINT_EDGE, f"Boundary: {counts['BOUNDARY']}"),
    ]
    
    for i, (color, text) in enumerate(items):
        y = legend_y + 10 + i * 25
        pygame.draw.circle(surface, color, (legend_x + 10, y + 8), 8)
        text_surface = font.render(text, True, COLOR_TEXT)
        surface.blit(text_surface, (legend_x + 30, y))


# ============================================================================
# Main Application
# ============================================================================

class PolygonViewer:
    """Main application class for viewing polygons."""
    
    def __init__(self, json_path: str):
        pygame.init()
        pygame.display.set_caption("Polygon Viewer")
        
        self.screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
        self.clock = pygame.time.Clock()
        self.running = True
        
        # Load fonts
        self.font = pygame.font.Font(None, 36)
        self.small_font = pygame.font.Font(None, 24)
        self.button_font = pygame.font.Font(None, 32)
        
        # Load polygons from JSON (includes pre-computed test points)
        self.polygons = load_polygons_from_json(json_path)
        self.current_index = 0
        
        # Create navigation buttons
        button_y = WINDOW_HEIGHT - 80
        self.prev_button = Button(
            BUTTON_MARGIN, button_y, 
            BUTTON_WIDTH, BUTTON_HEIGHT, 
            "◀ Previous"
        )
        self.next_button = Button(
            WINDOW_WIDTH - BUTTON_WIDTH - BUTTON_MARGIN, button_y,
            BUTTON_WIDTH, BUTTON_HEIGHT,
            "Next ▶"
        )
        self.prev_button.set_font(self.button_font)
        self.next_button.set_font(self.button_font)
        
        # Cache transformed coordinates
        self.screen_coords = None
        self.update_screen_coords()
    
    def update_screen_coords(self):
        """Update cached screen coordinates for current polygon."""
        if self.polygons:
            polygon = self.polygons[self.current_index]['polygon']
            self.screen_coords = transform_polygon_to_screen(
                polygon, WINDOW_WIDTH, WINDOW_HEIGHT
            )
    
    def get_current_test_points(self):
        """Get test points for the current polygon from the dataset."""
        if self.polygons:
            return self.polygons[self.current_index].get('test_points', [])
        return []
    
    def go_to_previous(self):
        """Navigate to previous polygon."""
        if self.current_index > 0:
            self.current_index -= 1
            self.update_screen_coords()
    
    def go_to_next(self):
        """Navigate to next polygon."""
        if self.current_index < len(self.polygons) - 1:
            self.current_index += 1
            self.update_screen_coords()
    
    def handle_events(self):
        """Process pygame events."""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.running = False
                elif event.key in (pygame.K_LEFT, pygame.K_a):
                    self.go_to_previous()
                elif event.key in (pygame.K_RIGHT, pygame.K_d):
                    self.go_to_next()
            
            # Button events
            if self.prev_button.handle_event(event):
                self.go_to_previous()
            if self.next_button.handle_event(event):
                self.go_to_next()
    
    def draw(self):
        """Render the current frame."""
        self.screen.fill(COLOR_BACKGROUND)
        
        if self.polygons and self.screen_coords:
            polygon = self.polygons[self.current_index]['polygon']
            test_points = self.get_current_test_points()
            
            # Draw the polygon
            draw_polygon(self.screen, self.screen_coords)
            
            # Draw test points from dataset
            draw_test_points(self.screen, test_points, polygon,
                           WINDOW_WIDTH, WINDOW_HEIGHT)
            
            # Draw test point legend
            draw_test_point_legend(self.screen, self.small_font, test_points)
            
            # Draw info panel
            draw_info_panel(
                self.screen,
                self.polygons[self.current_index],
                self.current_index,
                len(self.polygons),
                self.font,
                self.small_font
            )
        
        # Draw navigation buttons
        self.prev_button.draw(self.screen)
        self.next_button.draw(self.screen)
        
        # Draw controls help
        draw_controls_help(self.screen, self.small_font, WINDOW_HEIGHT)
        
        pygame.display.flip()
    
    def run(self):
        """Main application loop."""
        print(f"Loaded {len(self.polygons)} polygons")
        print("Use arrow keys or buttons to navigate")
        print("Press ESC to quit")
        
        while self.running:
            self.handle_events()
            self.draw()
            self.clock.tick(FPS)
        
        pygame.quit()


def main():
    """Entry point for the polygon viewer."""
    # Find the JSON file
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    json_path = os.path.join(parent_dir, "polygons.json")
    
    # Also check if running from game directory
    if not os.path.exists(json_path):
        json_path = os.path.join(script_dir, "..", "polygons.json")
    
    if not os.path.exists(json_path):
        print(f"Error: Could not find polygons.json")
        print(f"Looked in: {json_path}")
        print("Run scripts/generate_polygons.py first to create the dataset.")
        sys.exit(1)
    
    viewer = PolygonViewer(json_path)
    viewer.run()


if __name__ == "__main__":
    main()
