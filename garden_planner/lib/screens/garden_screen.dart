import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/plant.dart';
import '../services/schedule_service.dart';
import '../widgets/tip.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  Plant? _lastSelectedPlant;
  bool _isPlantingMode = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Track the last selected plant
    if (state.selectedPlant != null) {
      _lastSelectedPlant = state.selectedPlant;
    }
    
    // Determine if we show the banner
    final showBanner = _lastSelectedPlant != null;
    final showTip = _lastSelectedPlant == null && !state.isTipDismissed('garden-select-plant');
    
    return Column(
      children: [
        if (showBanner || showTip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: showBanner
                  ? LinearGradient(
                      colors: [
                        _hexColor(_lastSelectedPlant!.color).withOpacity(0.1),
                        _hexColor(_lastSelectedPlant!.color).withOpacity(0.2),
                      ],
                    )
                  : null,
              color: !showBanner ? Colors.green.shade50 : null,
              border: showBanner
                  ? Border.all(color: _hexColor(_lastSelectedPlant!.color).withOpacity(0.6), width: 2)
                  : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: showBanner
                  ? [
                      BoxShadow(
                        color: _hexColor(_lastSelectedPlant!.color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            margin: showBanner
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : EdgeInsets.zero,
            child: showBanner
                ? Column(
                    children: [
                      if (_isPlantingMode) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _hexColor(_lastSelectedPlant!.color), width: 2),
                              ),
                              child: Text(
                                _lastSelectedPlant!.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _lastSelectedPlant!.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap cells to plant • Long press to view',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Mode toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPlantingMode = true;
                                  });
                                  // Select plant in app state
                                  state.selectPlant(_lastSelectedPlant!.code);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isPlantingMode ? _hexColor(_lastSelectedPlant!.color) : Colors.white,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle,
                                        color: _isPlantingMode ? Colors.white : Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PLANTING',
                                        style: TextStyle(
                                          color: _isPlantingMode ? Colors.white : Colors.grey.shade600,
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
                                    _isPlantingMode = false;
                                  });
                                  // Deselect plant in app state
                                  state.selectPlant(null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isPlantingMode ? _hexColor(_lastSelectedPlant!.color) : Colors.white,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        color: !_isPlantingMode ? Colors.white : Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SELECTING',
                                        style: TextStyle(
                                          color: !_isPlantingMode ? Colors.white : Colors.grey.shade600,
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
                    message: 'Go to Plants tab to select what to plant, then tap cells to place plants in your beds.',
                  ),
          ),
        Expanded(
          child: PageView.builder(
            itemCount: state.beds.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, bedIndex) {
              final bed = state.beds[bedIndex];
              return Card(
                elevation: 3,
                child: Column(
                  children: [
                    // Bed name header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                          Text(
                            '${bed.rows}×${bed.cols}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cellSize = (constraints.maxWidth - (bed.cols + 1) * 4.0) / bed.cols;
                            
                            // GridView's actual cell size calculation
                            // GridView.builder with SliverGridDelegateWithFixedCrossAxisCount
                            // divides space as: (width - (cols - 1) * crossAxisSpacing) / cols
                            final actualCellSize = (constraints.maxWidth - (bed.cols - 1) * 4.0) / bed.cols;
                            
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
                                  // GridView uses actualCellSize, not the cellSize we calculate
                                  final gap = 4.0;
                                  final left = minCol * (actualCellSize + gap);
                                  final top = minRow * (actualCellSize + gap);
                                  final overlayWidth = spanCols * actualCellSize + (spanCols - 1) * gap;
                                  final overlayHeight = spanRows * actualCellSize + (spanRows - 1) * gap;
                                  
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
                                            children: [
                                              Text(
                                                plantInGroup.icon,
                                                style: TextStyle(fontSize: iconSize, height: 1),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                plantInGroup.name,
                                                style: TextStyle(fontSize: iconSize * 0.15, height: 1.1),
                                                textAlign: TextAlign.center,
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
                            
                            return SingleChildScrollView(
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: bed.rows * (cellSize + 4) - 4,
                                child: Stack(
                                  children: [
                                    GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: bed.cols,
                                        mainAxisSpacing: 4,
                                        crossAxisSpacing: 4,
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
                                        if (state.selectedPlantCode != null) {
                                          // In planting mode: always plant (overwrites existing plants)
                                          state.placeSelectedPlant(bedIndex, idx);
                                        } else if (plant != null) {
                                          // Not in planting mode: show plant details
                                          _showCellSheet(context, state, bedIndex, idx, plant);
                                        }
                                      },
                                      onLongPress: () {
                                        // Long press shows note dialog
                                        _editNoteDialog(context, state, bedIndex, idx, plant);
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
                                              child: _buildCellContent(plant, cellSize, showSprawlFallback, isDimmed),
                                            ),
                                          ),
                                          if (plant != null && state.plantNotes[plant.code] != null && state.plantNotes[plant.code]!.isNotEmpty)
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
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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
            Text(plant.name, style: TextStyle(fontSize: cellSize * 0.12), textAlign: TextAlign.center, maxLines: 1),
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
        children: [
          Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.4)),
          Text(plant.name, style: TextStyle(fontSize: cellSize * 0.12), textAlign: TextAlign.center, maxLines: 1),
        ],
      );
    }
    
    // 2 plants per cell - side by side
    if (spacing == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.28)),
              SizedBox(width: cellSize * 0.03),
              Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.28)),
            ],
          ),
          Text(plant.name, style: TextStyle(fontSize: cellSize * 0.11), textAlign: TextAlign.center, maxLines: 1),
        ],
      );
    }
    
    // 4 plants per cell - 2x2 grid
    if (spacing == 4) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: cellSize * 0.02,
            crossAxisSpacing: cellSize * 0.02,
            children: List.generate(4, (_) => Center(child: Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.24)))),
          ),
          Text(plant.name, style: TextStyle(fontSize: cellSize * 0.1), textAlign: TextAlign.center, maxLines: 1),
        ],
      );
    }
    
    // Default
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(plant.icon, style: TextStyle(fontSize: cellSize * 0.4)),
        Text(plant.name, style: TextStyle(fontSize: cellSize * 0.12), textAlign: TextAlign.center, maxLines: 1),
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

  void _showCellSheet(BuildContext context, AppState state, int bedIndex, int cellIndex, Plant plant) {
    final springSchedule = ScheduleService.computeSpringSchedule(plant, state.zone);
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final noteController = TextEditingController(text: state.plantNotes[plant.code] ?? '');
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hexColor(plant.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(plant.icon, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plant.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Plant Info
                  Text('Plant Information', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildInfoRow('Direct Sow:', springSchedule.sow != null 
                    ? '${_monthName(springSchedule.sow!.month)} ${springSchedule.sow!.day}'
                    : 'N/A'),
                  _buildInfoRow('Harvest:', springSchedule.harvest != null
                    ? '${_monthName(springSchedule.harvest!.month)} ${springSchedule.harvest!.day}'
                    : 'N/A'),
                  _buildInfoRow('Spacing:', (plant.cellsRequired ?? 1) > 1
                      ? '1 plant / ${plant.cellsRequired} sq ft'
                      : '${plant.sqftSpacing} plant${plant.sqftSpacing > 1 ? "s" : ""} / sq ft'),
                  Row(
                    children: [
                      const Text('Light: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: plant.lightLevel == 'high' ? Colors.orange : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(plant.lightLevel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Plant Notes
                  Row(
                    children: [
                      Text('Notes for All ${plant.name}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'This note applies to all ${plant.name} plants in your garden',
                        child: Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add notes for all ${plant.name} plants...',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final v = noteController.text.trim();
                          state.updatePlantNote(plant.code, v.isEmpty ? null : v);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Note'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          state.clearCell(bedIndex, cellIndex);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Remove Plant', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  void _editNoteDialog(BuildContext context, AppState state, int bedIndex, int cellIndex, Plant? plant) {
    if (plant == null) return;
    final controller = TextEditingController(text: state.plantNotes[plant.code] ?? '');
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
              state.updatePlantNote(plant.code, v.isEmpty ? null : v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
