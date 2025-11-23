import 'package:flutter/foundation.dart';

/// Immutable model representing a single garden bed cell
@immutable
class BedCell {
  final String? plantCode;
  final String? note;

  const BedCell({
    this.plantCode,
    this.note,
  });

  /// Create empty cell
  const BedCell.empty() : plantCode = null, note = null;

  /// Check if cell is empty
  bool get isEmpty => plantCode == null;

  /// Check if cell has a note
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Copy with modifications
  BedCell copyWith({
    String? Function()? plantCode,
    String? Function()? note,
  }) {
    return BedCell(
      plantCode: plantCode != null ? plantCode() : this.plantCode,
      note: note != null ? note() : this.note,
    );
  }

  /// Clear the cell
  BedCell clear() => const BedCell.empty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BedCell &&
          runtimeType == other.runtimeType &&
          plantCode == other.plantCode &&
          note == other.note;

  @override
  int get hashCode => Object.hash(plantCode, note);

  @override
  String toString() => 'BedCell(plantCode: $plantCode, note: $note)';
}

/// Immutable model representing a garden bed
@immutable
class GardenBed {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final List<BedCell> cells;

  const GardenBed({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.cells,
  });

  /// Create a new bed with empty cells
  factory GardenBed.create({
    required String id,
    required String name,
    required int rows,
    required int cols,
  }) {
    return GardenBed(
      id: id,
      name: name,
      rows: rows,
      cols: cols,
      cells: List.generate(rows * cols, (_) => const BedCell.empty()),
    );
  }

  /// Total number of cells
  int get totalCells => rows * cols;

  /// Get cell at index
  BedCell cellAt(int index) {
    if (index < 0 || index >= cells.length) {
      return const BedCell.empty();
    }
    return cells[index];
  }

  /// Get cell at row and column
  BedCell cellAtPosition(int row, int col) {
    final index = row * cols + col;
    return cellAt(index);
  }

  /// Update a specific cell
  GardenBed updateCell(int index, BedCell newCell) {
    if (index < 0 || index >= cells.length) return this;
    
    final newCells = List<BedCell>.from(cells);
    newCells[index] = newCell;
    
    return copyWith(cells: newCells);
  }

  /// Clear a specific cell
  GardenBed clearCell(int index) {
    return updateCell(index, const BedCell.empty());
  }

  /// Copy with modifications
  GardenBed copyWith({
    String? id,
    String? name,
    int? rows,
    int? cols,
    List<BedCell>? cells,
  }) {
    final newRows = rows ?? this.rows;
    final newCols = cols ?? this.cols;
    
    // If dimensions changed, create new cells and copy existing where possible
    final newCells = cells ?? _resizeCells(newRows, newCols);
    
    return GardenBed(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: newRows,
      cols: newCols,
      cells: newCells,
    );
  }

  /// Resize cells when dimensions change
  List<BedCell> _resizeCells(int newRows, int newCols) {
    final newCells = List.generate(newRows * newCols, (_) => const BedCell.empty());
    
    // Copy existing cells where they fit
    for (var r = 0; r < newRows && r < rows; r++) {
      for (var c = 0; c < newCols && c < cols; c++) {
        final oldIndex = r * cols + c;
        final newIndex = r * newCols + c;
        newCells[newIndex] = cells[oldIndex];
      }
    }
    
    return newCells;
  }

  /// Get all unique plant codes in this bed
  Set<String> get plantedCodes {
    return cells
        .where((cell) => cell.plantCode != null)
        .map((cell) => cell.plantCode!)
        .toSet();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenBed &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          rows == other.rows &&
          cols == other.cols &&
          listEquals(cells, other.cells);

  @override
  int get hashCode => Object.hash(id, name, rows, cols, Object.hashAll(cells));

  @override
  String toString() => 'GardenBed(id: $id, name: $name, rows: $rows, cols: $cols)';
}
