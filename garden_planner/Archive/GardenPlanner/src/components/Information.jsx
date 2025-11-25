import React from 'react'

/**
 * Information component - provides usage instructions and about information
 */
export function Information() {
  return (
    <div className="row g-4">
      <div className="col-12">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">📖 How to Use Raised Bed Planner</h5>
          </div>
          <div className="card-body">
            <div className="row g-4">
              {/* Layout Tab */}
              <div className="col-md-6">
                <h6 className="text-primary">🏡 Layout Tab</h6>
                <p>
                  Your main workspace for creating and managing your raised bed garden:
                </p>
                <h6 className="mt-3">Creating & Managing Beds</h6>
                <ul className="small">
                  <li><strong>Add a Bed:</strong> Use the bed selector dropdown (set to "New Bed"), configure name, size (rows × columns), and light level, then click "Add Bed".</li>
                  <li><strong>Edit a Bed:</strong> Select a bed from the dropdown or click the bed's header to load its settings. Modify the name, size, or light level, then click "Update Bed".</li>
                  <li><strong>Reorder Beds:</strong> Use the up/down arrow buttons to change the display order of your beds.</li>
                  <li><strong>Remove a Bed:</strong> Select a bed and click the "Remove" button.</li>
                  <li><strong>Default Size:</strong> New beds default to 4 rows × 8 columns (32 square feet), but you can adjust from 1×1 to 12×12.</li>
                  <li><strong>Light Levels:</strong> Toggle between ☀️ (High/Full Sun) for fruiting plants and ☁️ (Low/Partial Shade) for leafy greens.</li>
                </ul>

                <h6 className="mt-3">Planting Crops</h6>
                <ul className="small">
                  <li><strong>Crop Palette:</strong> Select a crop from the left sidebar. Use filters to narrow by type, light level, or search.</li>
                  <li><strong>Drag & Drop:</strong> Drag crops directly from the palette onto bed cells for quick placement.</li>
                  <li><strong>Click to Plant:</strong> Select a crop, then click any cell to place it. Selected crops stay active as you scroll.</li>
                  <li><strong>Drag to Plant:</strong> Select a crop, then click and drag across multiple cells to plant them all at once.</li>
                  <li><strong>Sprawling Crops:</strong> Some plants (tomatoes, squash, melons) need 2-4 square feet. Plant them in adjacent cells and they'll display with a large icon spanning the area.</li>
                </ul>

                <h6 className="mt-3">Selecting & Managing Plants</h6>
                <ul className="small">
                  <li><strong>Click to Select:</strong> Click any cell to select it.</li>
                  <li><strong>Drag to Select:</strong> Click and drag across multiple cells to select a rectangular area.</li>
                  <li><strong>Double-Click:</strong> Double-click a planted cell to select the entire plant group (for sprawling crops).</li>
                  <li><strong>Delete Plants:</strong> Select cells and press Delete or Backspace to remove crops.</li>
                  <li><strong>Plant Details:</strong> Select planted cells to view growing info and add custom notes in the right panel.</li>
                </ul>
              </div>

              {/* Calendar & Tools */}
              <div className="col-md-6">
                <h6 className="text-primary">📅 Calendar Tab</h6>
                <p>
                  View your planting schedule organized by month:
                </p>
                <ul className="small">
                  <li><strong>Monthly View:</strong> See which crops to start indoors, transplant outdoors, direct sow, and harvest each month.</li>
                  <li><strong>Zone-Based:</strong> All dates are calculated based on your selected USDA hardiness zone and the last frost date.</li>
                  <li><strong>Color-Coded:</strong> Each plant appears in its designated color for easy identification.</li>
                  <li><strong>Activity Types:</strong> Start Indoors, Plant Outdoors, and Harvest windows.</li>
                </ul>

                <h6 className="mt-3 text-primary">🛠️ Tools & Features</h6>
                <ul className="small">
                  <li><strong>Rename Garden:</strong> Click the pencil icon + garden name in the top-left header.</li>
                  <li><strong>USDA Zone:</strong> Select your zone from the dropdown in the header to adjust planting dates.</li>
                  <li><strong>Save/Load:</strong> Export your layout to a .pln file or load a previously saved plan.</li>
                  <li><strong>PDF Export:</strong> Generate a printable plan with layout, planting calendar, and growing instructions.</li>
                  <li><strong>Clear All:</strong> Remove all beds at once.</li>
                  <li><strong>Undo/Redo:</strong> Use the buttons or Ctrl+Z (undo) and Ctrl+Y (redo) keyboard shortcuts.</li>
                  <li><strong>Plant Notes:</strong> Select planted cells to add custom growing notes that save with your plan.</li>
                  <li><strong>Auto-Save:</strong> Your garden layout automatically saves to browser storage as you work.</li>
                </ul>

                <h6 className="mt-3 text-primary">💾 Saving Your Work</h6>
                <ul className="small mb-0">
                  <li><strong>Auto-Save:</strong> Plans automatically save to your browser's local storage as you work.</li>
                  <li><strong>Export Files:</strong> Click "Save" to download a .pln file for permanent backup and sharing.</li>
                  <li><strong>Important:</strong> Browser storage can be cleared. Always export important plans to .pln files!</li>
                </ul>
              </div>
            </div>

            <hr className="my-3" />

            {/* PDF Export Section */}
            <div className="row">
              <div className="col-12">
                <h6 className="text-primary">🖨️ PDF Export</h6>
                <p className="small">
                  Create a printable plan to take outside. Click the PDF button in the header to generate a comprehensive document with:
                </p>
                <ul className="small mb-0">
                  <li><strong>Layout:</strong> Color-coded visual map showing where each crop is located</li>
                  <li><strong>Planting Instructions:</strong> Quantity info per crop (fractions show sq ft per plant; numbers show plants per sq ft)</li>
                  <li><strong>Calendar:</strong> When to start seeds, transplant, and harvest based on your USDA zone</li>
                  <li><strong>Growing Notes:</strong> Detailed care instructions for each crop in your plan</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* About Section */}
      <div className="col-12">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">ℹ️ About Raised Bed Planner</h5>
          </div>
          <div className="card-body">
            <div className="row g-4">
              <div className="col-md-6">
                <h6>🌿 Square Foot Gardening</h6>
                <p className="small">
                  Raised Bed Planner uses <strong>square foot gardening</strong> techniques, a space-efficient method developed by Mel Bartholomew. 
                  Each garden square represents one square foot, and plants are spaced based on their size:
                </p>
                <ul className="small">
                  <li>Large plants (tomatoes, peppers): 1 per square foot</li>
                  <li>Medium plants (lettuce, beets): 4 per square foot</li>
                  <li>Small plants (radishes, carrots): 9-16 per square foot</li>
                </ul>
                <p className="small">
                  This intensive planting method maximizes yield while minimizing water usage and weeding.
                </p>
              </div>

              <div className="col-md-6">
                <h6>📜 License & Usage</h6>
                <p className="small">
                  <strong>Raised Bed Planner</strong> is provided free of charge for personal and educational use only. 
                  You may use this tool to plan your home gardens, share your garden plans with friends, 
                  or use it in educational settings.
                </p>
                <p className="small">
                  <strong>Restrictions:</strong> Commercial use, redistribution, and copying of source code are prohibited 
                  without explicit written permission from the author.
                </p>
                <p className="small mb-0">
                  <strong>Author:</strong> Matthew Edwards<br />
                  <strong>Technology:</strong> React, JavaScript, Bootstrap<br />
                  <strong>Data Storage:</strong> All plan data is stored locally in your browser. Nothing is sent to external servers.
                </p>
              </div>
            </div>

            <hr className="my-4" />

            <div className="row">
              <div className="col-12">
                <h6>💡 Tips & Best Practices</h6>
                <ul className="small mb-0">
                  <li><strong>Plan Your Layout:</strong> Create beds, then add crops. Consider plant spacing requirements and your available garden space.</li>
                  <li><strong>Light Requirements:</strong> High light (☀️) for fruiting plants (tomatoes, peppers, squash) and Low light (☁️) for shade-tolerant crops (leafy greens, root vegetables).</li>
                  <li><strong>Sprawling Crops:</strong> Tomatoes, peppers, squash, and melons need 2-4 square feet. Plant them in adjacent cells for proper spacing.</li>
                  <li><strong>Succession Planting:</strong> For continuous harvests, plant cool-season crops (lettuce, spinach) in early spring and again in fall.</li>
                  <li><strong>Companion Planting:</strong> Group compatible plants together. Tomatoes grow well with basil, and carrots with onions.</li>
                  <li><strong>Start Small:</strong> New gardeners should start with 1-2 beds (20-40 sq ft) and expand as you gain experience.</li>
                  <li><strong>Use Filters:</strong> Use the crop palette filters to quickly find vegetables, fruits, herbs, or plants suitable for your light conditions.</li>
                  <li><strong>Mobile Friendly:</strong> The planner works on smartphones and tablets with optimized touch controls.</li>
                  <li><strong>Save Often:</strong> Export your plan regularly. Plans are saved with a .pln extension and can be loaded later.</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
