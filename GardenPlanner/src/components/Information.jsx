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
                <h6 className="text-primary">� Layout Tab</h6>
                <p>
                  Your main workspace for creating and managing your raised bed garden:
                </p>
                <h6 className="mt-3">Creating & Managing Beds</h6>
                <ul className="small">
                  <li><strong>Add a Bed:</strong> Use the bed selector dropdown (set to "New Bed"), configure name, size (rows × columns), and light level, then click "Add Bed".</li>
                  <li><strong>Edit a Bed:</strong> Select a bed from the dropdown to load its settings. Modify the name, size, or light level, then click "Update Bed".</li>
                  <li><strong>Reorder Beds:</strong> Use the up/down arrow buttons to change the display order of your beds.</li>
                  <li><strong>Remove a Bed:</strong> Select a bed and click the "Remove" button. Beds with planted crops will prompt for confirmation.</li>
                  <li><strong>Default Size:</strong> New beds default to 4 rows × 8 columns (32 square feet), but you can adjust from 1×1 to 12×12.</li>
                  <li><strong>Light Levels:</strong> Toggle between ☀️ (High/Full Sun) for fruiting plants and ☁️ (Low/Partial Shade) for leafy greens.</li>
                </ul>

                <h6 className="mt-3">Planting Crops</h6>
                <ul className="small">
                  <li><strong>Crop Palette:</strong> Select a crop from the left sidebar. Use filters to narrow by type, light level, or search.</li>
                  <li><strong>Drag & Drop:</strong> Drag crops directly from the palette onto bed cells for quick placement.</li>
                  <li><strong>Click to Plant:</strong> Select a crop, then click any cell to place it. Selected crops stay active as you scroll.</li>
                  <li><strong>Edit Cells:</strong> Click a planted cell to select it. Press Delete or Backspace to remove crops.</li>
                  <li><strong>Multi-Select:</strong> Double-click a planted cell to select the entire plant group (for sprawling crops).</li>
                  <li><strong>Delete Button:</strong> Each bed card shows a "Delete" button when cells are selected to remove crops in bulk.</li>
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
                  <li><strong>Clear All:</strong> Remove all beds at once (with confirmation if crops are present).</li>
                  <li><strong>Undo/Redo:</strong> Use the buttons or Ctrl+Z (undo) and Ctrl+Y (redo) keyboard shortcuts.</li>
                  <li><strong>Crop Details:</strong> Click any planted cell to see detailed growing information in the right panel.</li>
                </ul>

                <h6 className="mt-3 text-primary">💾 Saving Your Work</h6>
                <ul className="small mb-0">
                  <li><strong>Local Storage:</strong> Plans auto-save to your browser, but clearing browser data will erase them.</li>
                  <li><strong>Export Files:</strong> Click "Save" to download a .pln file for permanent backup.</li>
                  <li><strong>Important:</strong> Always export important plans—browser storage is not permanent!</li>
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
                  <li><strong>Plan Your Layout:</strong> Start by creating beds in the New tab, then add crops manually in the Layout tab. Consider plant spacing requirements and your available garden space.</li>
                  <li><strong>Light Requirements:</strong> The planner uses a two-tier light system: High light (☀️) for fruiting plants (tomatoes, peppers, squash) and Low light (☁️) for shade-tolerant crops (leafy greens, root vegetables).</li>
                  <li><strong>Succession Planting:</strong> For continuous harvests, plant cool-season crops (lettuce, spinach) in early spring and again in fall. The calendar shows both spring and fall planting windows where applicable.</li>
                  <li><strong>Companion Planting:</strong> Group compatible plants together. For example, tomatoes grow well with basil, and carrots with onions.</li>
                  <li><strong>Start Small:</strong> If you're new to gardening, start with 1-2 beds (20-40 sq ft) and expand as you gain experience.</li>
                  <li><strong>Use Filters:</strong> When working in the Layout tab, use the crop palette filters to quickly find vegetables, fruits, herbs, or plants suitable for your light conditions.</li>
                  <li><strong>Save Often:</strong> Export your plan regularly to avoid losing your layout. Plans are saved with a .pln extension and can be loaded later.</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
