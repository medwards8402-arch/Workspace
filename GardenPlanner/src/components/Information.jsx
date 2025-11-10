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
              {/* New Garden Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">🌱 New Layout</h6>
                <p>
                  Use this tab to set up your raised bed garden:
                </p>
                <ul className="small">
                  <li><strong>Configure Beds:</strong> Customize each bed's name, size (rows × columns), and light level (low/high for shade vs full sun).</li>
                  <li><strong>Add/Remove Beds:</strong> Click "+ Add Another Bed" to add more raised beds, or remove beds you don't need.</li>
                  <li><strong>Create Layout:</strong> Click "Create Beds" to set up your garden structure with empty beds.</li>
                  <li><strong>Next Steps:</strong> After creating your beds, switch to the Plan tab to manually add crops by dragging and dropping from the plant palette.</li>
                  <li><strong>Note:</strong> Creating a new layout will overwrite your current design.</li>
                </ul>
              </div>

              {/* Layout Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">🏡 Layout</h6>
                <p>
                  Your main workspace for viewing and editing your raised bed layout:
                </p>
                <ul className="small">
                  <li><strong>Crop Palette:</strong> Select a crop from the left sidebar (use filters to narrow by type, light level, or search). Click any cell in your beds to place it. Selected crops stick as you scroll.</li>
                  <li><strong>Drag & Drop:</strong> You can drag crops directly from the palette onto bed cells for faster placement.</li>
                  <li><strong>Edit Cells:</strong> Click a planted cell to select it. Press Delete or Backspace to remove crops. Click and drag to select multiple cells.</li>
                  <li><strong>Crop Details:</strong> Click any planted cell to see detailed growing information in the right panel, including target dates based on your USDA zone and spacing requirements.</li>
                  <li><strong>Save/Load:</strong> Use the Save button to export your layout to a .pln file. Use Load to import a previously saved plan.</li>
                  <li><strong>Undo/Redo:</strong> Use the buttons or Ctrl+Z (undo) and Ctrl+Y (redo) to step through changes.</li>
                  <li><strong>Plan Name:</strong> Click the 📝 icon next to your plan name in the header to rename it.</li>
                </ul>
              </div>

              {/* Calendar Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">📅 Calendar</h6>
                <p>
                  View your planting schedule organized by month:
                </p>
                <ul className="small">
                  <li><strong>Monthly View:</strong> See which crops to start indoors, transplant outdoors, direct sow, and harvest each month.</li>
                  <li><strong>Zone-Based:</strong> All dates are calculated based on your selected USDA hardiness zone and the last frost date for your area.</li>
                  <li><strong>Color-Coded:</strong> Each plant appears in its designated color for easy identification.</li>
                  <li><strong>Activity Types:</strong> 
                    <ul>
                      <li><em>Start Indoors:</em> Begin seeds in trays or pots</li>
                      <li><em>Plant Outdoors:</em> Transplant seedlings or direct sow</li>
                      <li><em>Harvest:</em> Expected harvest window</li>
                    </ul>
                  </li>
                  <li><strong>Tip:</strong> Change your USDA zone using the dropdown in the header to see how planting dates adjust.</li>
                </ul>
              </div>
            </div>

            <hr className="my-3" />

            {/* PDF Export Section */}
            <div className="row">
              <div className="col-12">
                <h6 className="text-primary">🖨️ PDF Export</h6>
                <p className="small">
                  Create a printable plan to take outside to your raised beds. Click the 🖨️ PDF button in the header to generate a comprehensive PDF with:
                </p>
                <ul className="small mb-0">
                  <li><strong>Layout:</strong> Color-coded visual map of beds showing where each crop is located</li>
                  <li><strong>Planting Instructions:</strong> Each crop displays quantity info—fractions (1/2, 1/4) show sq ft per plant for large crops like squash, while numbers show how many to plant per sq ft</li>
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
