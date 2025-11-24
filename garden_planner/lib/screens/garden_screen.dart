import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/garden_provider.dart';
import '../presentation/providers/plant_notes_provider.dart';
import '../presentation/providers/plant_selection_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../domain/models/garden_bed.dart';
import '../models/plant.dart';
import '../widgets/tip.dart';
import '../widgets/plant_info_panel.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> with AutomaticKeepAliveClientMixin {
  Plant? _lastSelectedPlant;
  String _mode = 'planting'; // 'planting', 'selecting', 'deleting'
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final gardenProvider = context.watch<GardenProvider>();
    final selectionProvider = context.watch<PlantSelectionProvider>();
    final notesProvider = context.watch<PlantNotesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    // Track the last selected plant
    if (selectionProvider.selectedPlant != null) {
      _lastSelectedPlant = selectionProvider.selectedPlant;
    }
    
    // Determine if we show the banner
    final showBanner = _lastSelectedPlant != null;
    final showTip = _lastSelectedPlant == null && !settingsProvider.isTipDismissed('garden-select-plant');
    
    return Column(
      children: [
        if (showBanner || showTip)
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showBanner ? _hexColor(_lastSelectedPlant!.color).withOpacity(0.5) : Colors.grey.shade300,
                width: showBanner ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: showBanner 
                      ? _hexColor(_lastSelectedPlant!.color).withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: showBanner
                ? Column(
                    children: [
                      // Mode toggle only - fixed size header
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mode = 'planting';
                                  });
                                  // Select plant in app state
                                  selectionProvider.selectPlant(_lastSelectedPlant!.code);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: _mode == 'planting'
                                        ? LinearGradient(
                                            colors: [
                                              _hexColor(_lastSelectedPlant!.color).withOpacity(0.8),
                                              _hexColor(_lastSelectedPlant!.color),
                                            ],
                                          )
                                        : null,
                                    color: _mode != 'planting' ? Colors.grey.shade100 : null,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _lastSelectedPlant!.icon,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: _mode == 'planting' ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _lastSelectedPlant!.name.toUpperCase(),
                                        style: TextStyle(
                                          color: _mode == 'planting' ? Colors.white : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mode = 'selecting';
                                  });
                                  // Deselect plant in app state
                                  selectionProvider.selectPlant(null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _mode == 'selecting' ? _hexColor(_lastSelectedPlant!.color) : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        color: _mode == 'selecting' ? Colors.white : Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SELECT',
                                        style: TextStyle(
                                          color: _mode == 'selecting' ? Colors.white : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mode = 'deleting';
                                  });
                                  // Deselect plant in app state
                                  selectionProvider.selectPlant(null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _mode == 'deleting' ? Colors.red.shade600 : Colors.white,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: _mode == 'deleting' ? Colors.white : Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'DELETE',
                                        style: TextStyle(
                                          color: _mode == 'deleting' ? Colors.white : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Tip(
                    id: 'garden-select-plant',
                    message: 'Select a plant from the Plants tab, then tap grid cells to place. Tap placed plants to add notes or remove them. Use the undo button to reverse changes. Check Calendar tab for your personalized planting dates!',
                  ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: gardenProvider.beds.length,
            itemBuilder: (context, bedIndex) {
              final bed = gardenProvider.beds[bedIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: Card(
                    elevation: 3,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bed name header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bed.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.undo, size: 18, color: Colors.white),
                            onPressed: gardenProvider.canUndo(bedIndex) 
                              ? () => gardenProvider.undoBed(bedIndex)
                              : null,
                            tooltip: 'Undo last change',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    // Grid
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Fixed cell size: 8 columns should fill the screen width
                              const double spacing = 4.0;
                              const int maxCols = 8;
                              final double actualCellSize = (constraints.maxWidth - (maxCols - 1) * spacing) / maxCols;
                              final double bedWidth = bed.cols * actualCellSize + (bed.cols - 1) * spacing;
                              final double bedHeight = bed.rows * actualCellSize + (bed.rows - 1) * spacing;
                            
                            // Calculate sprawling plant groups
                            final sprawlingGroups = _calculateSprawlingGroups(bed);
                            final sprawlingCellIndices = <int>{};
                            for (final group in sprawlingGroups) {
                              sprawlingCellIndices.addAll(group['cells'] as Set<int>);
                            }
                            
                            // Build list of sprawling overlays to render on top
                            final List<Widget> sprawlingOverlays = [];
                            for (final group in sprawlingGroups) {
                              final plantInGroup = group['plant'] as Plant;
                              final instances = group['instances'] as List<Map<String, dynamic>>;
                              for (final instance in instances) {
                                final cells = instance['cells'] as List<int>;
                                if (cells.isNotEmpty) {
                                  // Calculate bounds
                                  int minRow = bed.rows, maxRow = -1, minCol = bed.cols, maxCol = -1;
                                  for (final cellIdx in cells) {
                                    final r = cellIdx ~/ bed.cols;
                                    final c = cellIdx % bed.cols;
                                    minRow = minRow < r ? minRow : r;
                                    maxRow = maxRow > r ? maxRow : r;
                                    minCol = minCol < c ? minCol : c;
                                    maxCol = maxCol > c ? maxCol : c;
                                  }
                                  
                                  final spanRows = maxRow - minRow + 1;
                                  final spanCols = maxCol - minCol + 1;
                                  
                                  // Calculate position and size to match GridView's layout exactly
                                  final left = minCol * (actualCellSize + spacing);
                                  final top = minRow * (actualCellSize + spacing);
                                  final overlayWidth = spanCols * actualCellSize + (spanCols - 1) * spacing;
                                  final overlayHeight = spanRows * actualCellSize + (spanRows - 1) * spacing;
                                  
                                  final iconSize = min(actualCellSize * 1.8, max(actualCellSize * 0.7, sqrt(cells.length.toDouble()) * actualCellSize * 0.5));
                                  
                                  sprawlingOverlays.add(
                                    Positioned(
                                      left: left,
                                      top: top,
                                      width: overlayWidth,
                                      height: overlayHeight,
                                      child: IgnorePointer(
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 0,
                                                child: Text(
                                                  plantInGroup.icon,
                                                  style: TextStyle(fontSize: iconSize, height: 1),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  plantInGroup.name,
                                                  style: TextStyle(fontSize: _getReadableFontSize(actualCellSize, 0.18, minSize: 10.0), height: 1.1, fontWeight: FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            
                            return SizedBox(
                              width: bedWidth,
                              height: bedHeight,
                              child: Stack(
                                children: [
                                  GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: bed.cols,
                                        mainAxisSpacing: spacing,
                                        crossAxisSpacing: spacing,
                                      ),
                                      itemCount: bed.rows * bed.cols,
                                      itemBuilder: (context, idx) {
                                    final cell = bed.cells[idx];
                                    final plant = cell.plantCode == null ? null : plants.firstWhere((p) => p.code == cell.plantCode);
                                    final isDimmed = sprawlingCellIndices.contains(idx);
                                    final showSprawlFallback = plant != null && 
                                        (plant.cellsRequired ?? 1) > 1 && 
                                        isDimmed && 
                                        !_isPartOfCompleteSprawl(idx, sprawlingGroups);
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        if (_mode == 'deleting' && plant != null) {
                                          // In deleting mode: remove plant
                                          gardenProvider.clearCell(bedIndex, idx);
                                        } else if (selectionProvider.selectedPlantCode != null) {
                                          // In planting mode: always plant (overwrites existing plants)
                                          gardenProvider.placePlant(bedIndex, idx, selectionProvider.selectedPlantCode!);
                                        } else if (plant != null) {
                                          // In selecting mode: show plant details
                                          _showCellSheet(context, bedIndex, idx, plant);
                                        }
                                      },
                                      onLongPress: () {
                                        // Long press shows note dialog
                                        _editNoteDialog(context, bedIndex, idx, plant);
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade400),
                                              color: plant == null 
                                                  ? Colors.white 
                                                  : _hexColor(plant.color).withOpacity(isDimmed ? 0.15 : 0.3),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: _buildCellContent(plant, actualCellSize, showSprawlFallback, isDimmed),
                                            ),
                                          ),
                                          if (plant != null && notesProvider.getNote(plant.code) != null && notesProvider.getNote(plant.code)!.isNotEmpty)
                                            Positioned(
                                              right: 2,
                                              bottom: 2,
                                              child: Icon(Icons.note, size: 14, color: Colors.brown.shade700),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                    ),
                                    // Render sprawling overlays on top of all cells
                                    ...sprawlingOverlays,
                                  ],
                                ),
                            );
                            },
                          ),
                        ),
                    ),
                  ],
                ),
              ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
  
  // Helper to ensure readable font size on small screens
  double _getReadableFontSize(double cellSize, double ratio, {double minSize = 11.0}) {
    return max(minSize, cellSize * ratio);
  }
  
  Widget _buildCellContent(Plant? plant, double cellSize, bool showSprawlFallback, bool isDimmed) {
    if (plant == null) return const SizedBox();
    
    // Fallback: faded icon for incomplete sprawling plants
    if (showSprawlFallback) {
      return Opacity(
        opacity: 0.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.4)),
            Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.18, minSize: 10.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      );
    }
    
    if (isDimmed) return const SizedBox();
    
    final spacing = plant.sqftSpacing;
    
    // Single plant per cell
    if (spacing == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.4)),
          SizedBox(height: cellSize * 0.02),
          Flexible(
            fit: FlexFit.loose,
            child: Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.18, minSize: 10.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    
    // 2 plants per cell - side by side
    if (spacing == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.28)),
              SizedBox(width: cellSize * 0.03),
              Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.28)),
            ],
          ),
          SizedBox(height: cellSize * 0.02),
          Flexible(
            fit: FlexFit.loose,
            child: Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.16, minSize: 9.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    
    // 4 plants per cell - 2x2 grid
    if (spacing == 4) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.01,
              crossAxisSpacing: cellSize * 0.01,
              childAspectRatio: 1,
              children: List.generate(4, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.22)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.14, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // 6 plants per cell - 3x2 grid
    if (spacing == 6) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.005,
              crossAxisSpacing: cellSize * 0.005,
              childAspectRatio: 1,
              children: List.generate(6, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.18)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.12, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // 8 plants per cell - 4x2 grid
    if (spacing == 8) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.005,
              crossAxisSpacing: cellSize * 0.005,
              childAspectRatio: 1,
              children: List.generate(8, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.16)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.12, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // 9 plants per cell - 3x3 grid
    if (spacing == 9) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.005,
              crossAxisSpacing: cellSize * 0.005,
              childAspectRatio: 1,
              children: List.generate(9, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.16)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.11, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // 12 plants per cell - 4x3 grid
    if (spacing == 12) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.003,
              crossAxisSpacing: cellSize * 0.003,
              childAspectRatio: 1,
              children: List.generate(12, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.14)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.11, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // 16 plants per cell - 4x4 grid
    if (spacing == 16) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.003,
              crossAxisSpacing: cellSize * 0.003,
              childAspectRatio: 1,
              children: List.generate(16, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.12)))),
            ),
          ),
          SizedBox(height: cellSize * 0.005),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.10, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    // Default - show as grid based on spacing value
    final crossAxisCount = spacing >= 16 ? 4 : spacing >= 9 ? 3 : spacing >= 4 ? 2 : 1;
    final iconSize = spacing >= 16 ? 0.12 : spacing >= 9 ? 0.16 : spacing >= 4 ? 0.20 : 0.3;
    final nameSize = spacing >= 16 ? 0.10 : spacing >= 9 ? 0.11 : spacing >= 4 ? 0.12 : 0.16;
    
    if (spacing > 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: cellSize * 0.005,
              crossAxisSpacing: cellSize * 0.005,
              childAspectRatio: 1,
              children: List.generate(spacing, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * iconSize)))),
            ),
          ),
          SizedBox(height: cellSize * 0.01),
          Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, nameSize, minSize: 8.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.4)),
        SizedBox(height: cellSize * 0.02),
        Text(plant.name, style: TextStyle(fontSize: _getReadableFontSize(cellSize, 0.18, minSize: 10.0), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
  
  List<Map<String, dynamic>> _calculateSprawlingGroups(GardenBed bed) {
    final result = <Map<String, dynamic>>[];
    final visited = <int>{};
    
    for (int i = 0; i < bed.cells.length; i++) {
      if (visited.contains(i) || bed.cells[i].plantCode == null) continue;
      
      final plantCode = bed.cells[i].plantCode!;
      final plant = plants.firstWhere((p) => p.code == plantCode, orElse: () => plants.first);
      
      final requiredPerPlant = plant.cellsRequired ?? 1;
      if (requiredPerPlant <= 1) continue;
      
      // BFS to find connected cells
      final group = <int>[];
      final queue = <int>[i];
      visited.add(i);
      
      while (queue.isNotEmpty) {
        final idx = queue.removeAt(0);
        group.add(idx);
        
        final row = idx ~/ bed.cols;
        final col = idx % bed.cols;
        
        final neighbors = [
          [row - 1, col],
          [row + 1, col],
          [row, col - 1],
          [row, col + 1],
        ];
        
        for (final n in neighbors) {
          final nr = n[0];
          final nc = n[1];
          if (nr < 0 || nr >= bed.rows || nc < 0 || nc >= bed.cols) continue;
          
          final nIdx = nr * bed.cols + nc;
          if (visited.contains(nIdx)) continue;
          if (bed.cells[nIdx].plantCode != plantCode) continue;
          
          visited.add(nIdx);
          queue.add(nIdx);
        }
      }
      
      if (group.isEmpty) continue;
      
      // Divide group into plant instances
      final groupSet = group.toSet();
      final plantInstances = <Map<String, dynamic>>[];
      final instanceVisited = <int>{};
      
      // Determine if square shape
      final isSquareShape = requiredPerPlant == 4 || requiredPerPlant == 9;
      
      // Helper to try claiming a shape
      bool tryClaimShape(int startIdx, bool preferHorizontal, List<int> outCells) {
        if (instanceVisited.contains(startIdx)) return false;
        
        final startRow = startIdx ~/ bed.cols;
        final startCol = startIdx % bed.cols;
        
        int shapeRows, shapeCols;
        if (isSquareShape) {
          final side = (requiredPerPlant == 4) ? 2 : 3;
          shapeRows = shapeCols = side;
        } else if (requiredPerPlant == 2) {
          if (preferHorizontal) {
            shapeRows = 1;
            shapeCols = 2;
          } else {
            shapeRows = 2;
            shapeCols = 1;
          }
        } else if (requiredPerPlant == 8) {
          if (preferHorizontal) {
            shapeRows = 2;
            shapeCols = 4;
          } else {
            shapeRows = 4;
            shapeCols = 2;
          }
        } else {
          // Fallback
          final side = requiredPerPlant.toDouble();
          if (preferHorizontal) {
            shapeRows = sqrt(side).floor();
            shapeCols = (requiredPerPlant / shapeRows).ceil();
          } else {
            shapeCols = sqrt(side).floor();
            shapeRows = (requiredPerPlant / shapeCols).ceil();
          }
        }
        
        // Check if we can claim this shape
        for (int rOffset = 0; rOffset < shapeRows; rOffset++) {
          for (int cOffset = 0; cOffset < shapeCols; cOffset++) {
            final r = startRow + rOffset;
            final c = startCol + cOffset;
            if (r >= bed.rows || c >= bed.cols) return false;
            
            final idx = r * bed.cols + c;
            if (!groupSet.contains(idx) || instanceVisited.contains(idx)) return false;
          }
        }
        
        // Claim the shape
        outCells.clear();
        for (int rOffset = 0; rOffset < shapeRows; rOffset++) {
          for (int cOffset = 0; cOffset < shapeCols; cOffset++) {
            final idx = (startRow + rOffset) * bed.cols + (startCol + cOffset);
            outCells.add(idx);
            instanceVisited.add(idx);
          }
        }
        
        return true;
      }
      
      // PASS 1: Try horizontal placements
      if (!isSquareShape) {
        for (final idx in group) {
          if (instanceVisited.contains(idx)) continue;
          
          final instanceCells = <int>[];
          if (tryClaimShape(idx, true, instanceCells)) {
            plantInstances.add({'cells': instanceCells});
          }
        }
      }
      
      // PASS 2: Fill gaps (square shapes or vertical fills)
      for (final idx in group) {
        if (instanceVisited.contains(idx)) continue;
        
        final instanceCells = <int>[];
        if (tryClaimShape(idx, isSquareShape, instanceCells)) {
          plantInstances.add({'cells': instanceCells});
        }
      }
      
      result.add({
        'plant': plant,
        'cells': groupSet,
        'instances': plantInstances,
      });
    }
    
    return result;
  }
  
  bool _isPartOfCompleteSprawl(int idx, List<Map<String, dynamic>> groups) {
    for (final group in groups) {
      final instances = group['instances'] as List<Map<String, dynamic>>;
      for (final instance in instances) {
        final cells = instance['cells'] as List<int>;
        if (cells.contains(idx)) return true;
      }
    }
    return false;
  }

  void _showCellSheet(BuildContext context, int bedIndex, int cellIndex, Plant plant) {
    final notesProvider = context.read<PlantNotesProvider>();
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final noteController = TextEditingController(text: notesProvider.getNote(plant.code) ?? '');
        final settingsProvider = context.read<SettingsProvider>();
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              child: PlantInfoPanel(
                plant: plant,
                zone: settingsProvider.zone,
                notesWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_add, color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notes for All ${plant.name}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Add notes for all ${plant.name} plants...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final v = noteController.text.trim();
                              notesProvider.updateNote(plant.code, v.isEmpty ? null : v);
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Save Note'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editNoteDialog(BuildContext context, int bedIndex, int cellIndex, Plant? plant) {
    if (plant == null) return;
    final notesProvider = context.read<PlantNotesProvider>();
    final controller = TextEditingController(text: notesProvider.getNote(plant.code) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notes for All ${plant.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This note applies to all ${plant.name} plants in your garden.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter note'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              notesProvider.updateNote(plant.code, v.isEmpty ? null : v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
