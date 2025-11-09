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
            <h5 className="card-title m-0">📖 How to Use Garden Planner</h5>
          </div>
          <div className="card-body">
            <div className="row g-4">
              {/* New Garden Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">🌱 New Garden</h6>
                <p>
                  Use this tab to create a new garden layout from scratch:
                </p>
                <ul className="small">
                  <li><strong>Configure Beds:</strong> Add, remove, or customize garden beds. Set the dimensions (rows × columns), light level (low/medium/high), and name for each bed.</li>
                  <li><strong>Select Plants:</strong> Choose which vegetables, herbs, and fruits you want to grow. Each plant shows its spacing density (plants per square foot).</li>
                  <li><strong>Generate:</strong> Click "Generate Garden" to automatically arrange your selected plants across all beds using square foot gardening techniques. Plants are placed in contiguous groups based on spacing needs and light preferences.</li>
                  <li><strong>Note:</strong> Generating a new garden will overwrite your current layout.</li>
                </ul>
              </div>

              {/* Garden Plan Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">🏡 Garden Plan</h6>
                <p>
                  Your main workspace for viewing and editing your garden:
                </p>
                <ul className="small">
                  <li><strong>Plant Palette:</strong> Select a plant from the left sidebar, then click any cell in your beds to place it. Selected plants stick as you scroll.</li>
                  <li><strong>Edit Cells:</strong> Click a planted cell to select it. Press Delete or Backspace to remove plants. Click and drag to select multiple cells.</li>
                  <li><strong>Plant Details:</strong> Click any planted cell to see detailed growing information in the right panel, including actual planting dates based on your USDA zone and spacing requirements.</li>
                  <li><strong>Save/Load:</strong> Use the Save button to export your garden to a .pln file. Use Load to import a previously saved plan.</li>
                  <li><strong>Undo/Redo:</strong> Use the buttons or Ctrl+Z (undo) and Ctrl+Y (redo) to step through changes.</li>
                  <li><strong>Garden Name:</strong> Click the 📝 icon next to your garden name in the header to rename it.</li>
                </ul>
              </div>

              {/* Planting Calendar Tab */}
              <div className="col-md-4">
                <h6 className="text-primary">📅 Planting Calendar</h6>
                <p>
                  View your planting schedule organized by month:
                </p>
                <ul className="small">
                  <li><strong>Monthly View:</strong> See which plants to start indoors, transplant outdoors, direct sow, and harvest each month.</li>
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
          </div>
        </div>
      </div>

      {/* About Section */}
      <div className="col-12">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">ℹ️ About Garden Planner</h5>
          </div>
          <div className="card-body">
            <div className="row g-4">
              <div className="col-md-6">
                <h6>🌿 Square Foot Gardening</h6>
                <p className="small">
                  Garden Planner uses <strong>square foot gardening</strong> techniques, a space-efficient method developed by Mel Bartholomew. 
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
                  <strong>Garden Planner</strong> is provided free of charge for personal and educational use. 
                  You may use this tool to plan your home gardens, share your garden plans with friends, 
                  or use it in educational settings.
                </p>
                <p className="small mb-0">
                  <strong>Author:</strong> Matthew Edwards<br />
                  <strong>Technology:</strong> React, JavaScript, Bootstrap<br />
                  <strong>Data Storage:</strong> All garden data is stored locally in your browser. Nothing is sent to external servers.
                </p>
              </div>
            </div>

            <hr className="my-4" />

            <div className="row">
              <div className="col-12">
                <h6>💡 Tips & Best Practices</h6>
                <ul className="small mb-0">
                  <li><strong>Succession Planting:</strong> For continuous harvests, plant cool-season crops (lettuce, spinach) in early spring and again in fall.</li>
                  <li><strong>Companion Planting:</strong> Group compatible plants together. For example, tomatoes grow well with basil, and carrots with onions.</li>
                  <li><strong>Crop Rotation:</strong> Each year, plant different crop families in different beds to maintain soil health and reduce pests.</li>
                  <li><strong>Light Requirements:</strong> Pay attention to light levels. Most fruiting plants (tomatoes, peppers, squash) need high light, while leafy greens can tolerate partial shade.</li>
                  <li><strong>Start Small:</strong> If you're new to gardening, start with 1-2 beds and expand as you gain experience.</li>
                  <li><strong>Save Often:</strong> Export your garden plan regularly to avoid losing your layout. Plans are saved with a .pln extension.</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
