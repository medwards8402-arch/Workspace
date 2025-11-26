import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/plant.dart';
import '../models/gardening_term.dart';

class LibraryScreen extends StatefulWidget {
  final Plant? initialPlant;
  final String? initialTerm;
  
  const LibraryScreen({super.key, this.initialPlant, this.initialTerm});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

enum LibraryMode { plants, terms }

// History entry to track navigation
class _HistoryEntry {
  final int tabIndex;
  final Plant? plant;
  final GardeningTerm? term;
  
  _HistoryEntry({required this.tabIndex, this.plant, this.term});
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late Plant selectedPlant;
  GardeningTerm? selectedTerm;
  late TabController _tabController;
  
  // Build clickable terms list dynamically from gardening terms data
  late final List<String> clickableTerms;
  
  // Navigation history with max depth of 20
  final List<_HistoryEntry> _history = [];
  static const int _maxHistoryDepth = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Build clickable terms list from all searchableVariations in gardeningTerms
    clickableTerms = gardeningTerms
        .expand((term) => term.searchableVariations)
        .toList();
    
    // Check if we should show a term or plant
    if (widget.initialTerm != null) {
      _tabController.index = 1;
      selectedTerm = gardeningTerms.firstWhere(
        (t) => t.term.toLowerCase() == widget.initialTerm!.toLowerCase(),
        orElse: () => gardeningTerms.first,
      );
    }
    // Find the plant in the plants list that matches the initial plant by code
    if (widget.initialPlant != null) {
      selectedPlant = plants.firstWhere(
        (p) => p.code == widget.initialPlant!.code,
        orElse: () => plants.first,
      );
    } else {
      selectedPlant = plants.first;
    }
    
    // Add initial state to history
    _addToHistory();
  }
  
  void _addToHistory() {
    final entry = _HistoryEntry(
      tabIndex: _tabController.index,
      plant: _tabController.index == 0 ? selectedPlant : null,
      term: _tabController.index == 1 ? selectedTerm : null,
    );
    
    _history.add(entry);
    
    // Keep history at reasonable depth
    if (_history.length > _maxHistoryDepth) {
      _history.removeAt(0);
    }
  }
  
  void _navigateBack() {
    if (_history.length > 1) {
      // Remove current state
      _history.removeLast();
      
      // Get previous state
      final previous = _history.last;
      
      setState(() {
        _tabController.index = previous.tabIndex;
        if (previous.plant != null) {
          selectedPlant = previous.plant!;
        }
        if (previous.term != null) {
          selectedTerm = previous.term;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToTerm(String term) {
    // Normalize the term for matching
    final normalizedInput = term.toLowerCase().trim();
    
    // Find the term by checking if the input matches any searchable variation
    final termData = gardeningTerms.firstWhere(
      (t) => t.searchableVariations.any((variation) => 
        variation.toLowerCase() == normalizedInput),
      orElse: () => gardeningTerms.first,
    );
    
    setState(() {
      _tabController.index = 1;
      selectedTerm = termData;
      _addToHistory();
    });
  }
  
  void _selectPlant(Plant plant) {
    setState(() {
      selectedPlant = plant;
      _addToHistory();
    });
  }
  
  void _selectTerm(GardeningTerm term) {
    setState(() {
      selectedTerm = term;
      _addToHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Library'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: _history.length > 1
          ? [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
                tooltip: 'Previous Page',
              ),
            ]
          : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.eco), text: 'Plants'),
            Tab(icon: Icon(Icons.menu_book), text: 'Terms & Techniques'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlantsTab(),
          _buildTermsTab(),
        ],
      ),
    );
  }

  Widget _buildPlantsTab() {
    return Column(
      children: [
        // Compact plant selector dropdown
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                selectedPlant.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<Plant>(
                  value: selectedPlant,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  items: plants.map((plant) {
                    return DropdownMenuItem<Plant>(
                      value: plant,
                      child: Text(plant.name),
                    );
                  }).toList(),
                  onChanged: (Plant? newPlant) {
                    if (newPlant != null) {
                      _selectPlant(newPlant);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Plant details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant header
                _buildSection(
                  icon: Icons.eco,
                  title: 'About',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPlant.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedPlant.type[0].toUpperCase()}${selectedPlant.type.substring(1)} • ${selectedPlant.lightLevel == 'high' ? 'Full Sun' : 'Partial Shade'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Care Instructions with clickable terms
                if (selectedPlant.careInstructions.isNotEmpty)
                  _buildSection(
                    icon: Icons.spa,
                    title: 'Care Instructions',
                    child: _buildTextWithClickableTerms(selectedPlant.careInstructions),
                  ),
                
                if (selectedPlant.careInstructions.isEmpty)
                  _buildSection(
                    icon: Icons.spa,
                    title: 'Care Instructions',
                    child: _buildDefaultCare(),
                  ),
                
                const SizedBox(height: 16),
                
                // Watering
                if (selectedPlant.watering.isNotEmpty)
                  _buildSection(
                    icon: Icons.water_drop,
                    title: 'Watering',
                    child: _buildTextWithClickableTerms(selectedPlant.watering),
                  ),
                
                const SizedBox(height: 16),
                
                // Soil Requirements
                if (selectedPlant.soil.isNotEmpty)
                  _buildSection(
                    icon: Icons.terrain,
                    title: 'Soil Requirements',
                    child: _buildTextWithClickableTerms(selectedPlant.soil),
                  ),
                
                const SizedBox(height: 16),
                
                // Companion Plants
                if (selectedPlant.companions.isNotEmpty)
                  _buildSection(
                    icon: Icons.diversity_3,
                    title: 'Companion Plants',
                    child: _buildTextWithClickableTerms(selectedPlant.companions),
                  ),
                
                const SizedBox(height: 16),
                
                // Varieties
                if (selectedPlant.varieties.isNotEmpty)
                  _buildSection(
                    icon: Icons.nature,
                    title: 'Popular Varieties',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedPlant.varieties.asMap().entries.map((entry) {
                        final variety = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: entry.key < selectedPlant.varieties.length - 1 ? 16 : 0),
                          child: _buildVarietyCard(variety),
                        );
                      }).toList(),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Quick Tips
                if (selectedPlant.tips.isNotEmpty)
                  _buildSection(
                    icon: Icons.lightbulb_outline,
                    title: 'Quick Tips',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedPlant.tips.map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(fontSize: 15, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Growing Info
                _buildSection(
                  icon: Icons.calendar_today,
                  title: 'Growing Information',
                  child: Column(
                    children: [
                      _buildInfoRow('Spacing', '${selectedPlant.sqftSpacing} plants per sq ft'),
                      _buildInfoRow('Time to Harvest', '${selectedPlant.harvestWeeks} weeks'),
                      if (selectedPlant.startIndoorsWeeks > 0)
                        _buildInfoRow('Start Indoors', '${selectedPlant.startIndoorsWeeks} weeks before transplant'),
                      if (selectedPlant.supportsFall)
                        _buildInfoRow('Fall Planting', 'Supports fall planting'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsTab() {
    if (selectedTerm == null && gardeningTerms.isNotEmpty) {
      selectedTerm = gardeningTerms.first;
    }

    return Column(
      children: [
        // Terms selector dropdown
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.menu_book, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<GardeningTerm>(
                  value: selectedTerm,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  items: gardeningTerms.map((term) {
                    return DropdownMenuItem<GardeningTerm>(
                      value: term,
                      child: Text(term.term),
                    );
                  }).toList(),
                  onChanged: (GardeningTerm? newTerm) {
                    if (newTerm != null) {
                      _selectTerm(newTerm);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Term details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: selectedTerm != null ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  icon: Icons.article,
                  title: selectedTerm!.term,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Definition
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          selectedTerm!.definition,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Details
                      Text(
                        selectedTerm!.details,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                      
                      // Related Terms
                      if (selectedTerm!.relatedTerms.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Related Terms:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedTerm!.relatedTerms.map((relatedTerm) {
                            final termData = gardeningTerms.where((t) =>
                              t.term.toLowerCase() == relatedTerm.toLowerCase()).firstOrNull;
                            
                            return InkWell(
                              onTap: () {
                                if (termData != null) {
                                  _selectTerm(termData);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.link, size: 14, color: Colors.green.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      relatedTerm,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ) : const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextWithClickableTerms(String text) {
    final List<TextSpan> spans = [];
    final words = text.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '');
      
      // Check for two-word terms first
      if (i < words.length - 1) {
        final twoWords = '$cleanWord ${words[i + 1].toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '')}';
        if (clickableTerms.any((term) => term.toLowerCase() == twoWords)) {
          spans.add(
            TextSpan(
              text: '${word} ${words[i + 1]}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _navigateToTerm(twoWords),
            ),
          );
          i++; // Skip next word
          if (i < words.length - 1) spans.add(const TextSpan(text: ' '));
          continue;
        }
      }
      
      // Check for single-word terms
      if (clickableTerms.any((term) => term.toLowerCase() == cleanWord)) {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToTerm(cleanWord),
          ),
        );
      } else {
        spans.add(TextSpan(text: word));
      }
      
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        children: spans,
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCare() {
    String careText = '';
    
    // Generate basic care based on plant properties
    if (selectedPlant.lightLevel == 'high') {
      careText += 'Requires full sun (6-8 hours daily). ';
    } else {
      careText += 'Prefers partial shade to full sun. ';
    }
    
    if (selectedPlant.type == 'herb') {
      careText += 'Most herbs prefer well-drained soil and moderate watering. Harvest regularly to encourage growth.';
    } else if (selectedPlant.type == 'fruit') {
      careText += 'Requires consistent watering and feeding during growing season. Mulch to retain moisture.';
    } else {
      careText += 'Keep soil consistently moist but not waterlogged. Feed with balanced fertilizer as needed.';
    }
    
    return Text(
      careText,
      style: const TextStyle(fontSize: 15, height: 1.5),
    );
  }

  Widget _buildVarietyCard(String variety) {
    // Parse variety format: "Name: Description"
    final parts = variety.split(':');
    if (parts.length < 2) {
      return Text(
        variety,
        style: const TextStyle(fontSize: 15, height: 1.5),
      );
    }

    final name = parts[0].trim();
    final description = parts.sublist(1).join(':').trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
