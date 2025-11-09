import React, { useState } from 'react'
import { PLANTS } from '../data'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { Tip } from './Tip'

/**
 * NewGarden component for initial garden setup
 * Allows configuration of bed count/size and plant selection
 * Generates populated garden using auto-population algorithm
 */
export function NewGarden({ onAfterGenerate }) {
  const { generateGarden } = useGardenOperations()

  // Dynamic beds state: array of { name, rows, cols, lightLevel, allowedTypes }
  const [beds, setBeds] = useState([
    { name: 'Bed 1', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Bed 2', rows: 4, cols: 8, lightLevel: 'medium', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Bed 3', rows: 4, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Herb Bed', rows: 2, cols: 4, lightLevel: 'high', allowedTypes: ['herb'] }
  ])

  // Plant selection state
  const [selectedPlants, setSelectedPlants] = useState(new Set())
  const [showConfirm, setShowConfirm] = useState(false)

  // Min/max validation constants
  const MIN_BEDS = 1
  const MAX_BEDS = 10
  const MIN_ROWS = 2
  const MAX_ROWS = 12
  const MIN_COLS = 2
  const MAX_COLS = 12

  // Bed management handlers
  const handleAddBed = () => {
    if (beds.length < MAX_BEDS) {
      setBeds([...beds, {
        name: `Bed ${beds.length + 1}`,
        rows: 4,
        cols: 8,
        lightLevel: 'high',
        allowedTypes: ['vegetable', 'fruit', 'herb']
      }])
    }
  }

  const handleRemoveBed = (index) => {
    if (beds.length > MIN_BEDS) {
      setBeds(beds.filter((_, i) => i !== index))
    }
  }

  const handleBedChange = (index, field, value) => {
    setBeds(beds.map((bed, i) => i === index ? { ...bed, [field]: value } : bed))
  }

  const handleTypeToggle = (bedIndex, type) => {
    setBeds(beds.map((bed, i) => {
      if (i !== bedIndex) return bed
      const currentTypes = bed.allowedTypes || []
      const newTypes = currentTypes.includes(type)
        ? currentTypes.filter(t => t !== type)
        : [...currentTypes, type]
      return { ...bed, allowedTypes: newTypes.length > 0 ? newTypes : ['vegetable'] } // Prevent empty
    }))
  }

  const handlePlantToggle = (code) => {
    const newSet = new Set(selectedPlants)
    if (newSet.has(code)) {
      newSet.delete(code)
    } else {
      newSet.add(code)
    }
    setSelectedPlants(newSet)
  }

  const handleGenerateClick = (e) => {
    e.stopPropagation()
    setShowConfirm(true)
  }

  const handleConfirmGenerate = (e) => {
    e.stopPropagation()
    // Use new architecture's generateGarden
    generateGarden({
      beds,
      plantCodes: Array.from(selectedPlants)
    })
    setShowConfirm(false)
    setSelectedPlants(new Set()) // Clear selection after generation
    if (typeof onAfterGenerate === 'function') {
      onAfterGenerate()
    }
  }

  const handleCancelGenerate = (e) => {
    e.stopPropagation()
    setShowConfirm(false)
  }

  const totalCells = beds.reduce((sum, bed) => sum + bed.rows * bed.cols, 0)
  const sortedPlants = [...PLANTS].sort((a, b) => a.name.localeCompare(b.name))

  return (
    <div className="row g-3">
      <div className="col-12">
        <Tip id="auto-planting-guide">
          Select your crops and configure your raised beds below. When you generate, the planner will automatically arrange crops in 
          contiguous blocks based on spacing requirements and sun exposure needs. Fruiting crops favor high-light beds while leafy greens 
          can occupy shadier spots. Spacing follows square foot gardening methods for intensive raised bed production.
        </Tip>
      </div>
      <div className="col-md-6">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">Raised Beds</h5>
          </div>
          <div className="card-body">
            <table className="table table-bordered align-middle">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Rows (ft)</th>
                  <th>Cols (ft)</th>
                  <th>Light</th>
                  <th>Crop Types</th>
                  <th>Remove</th>
                </tr>
              </thead>
              <tbody>
                {beds.map((bed, i) => (
                  <tr key={i}>
                    <td>
                      <input
                        type="text"
                        className="form-control"
                        value={bed.name}
                        onChange={e => handleBedChange(i, 'name', e.target.value)}
                        maxLength={32}
                        title="Edit bed name"
                      />
                    </td>
                    <td>
                      <input
                        type="number"
                        className="form-control"
                        value={bed.rows}
                        min={MIN_ROWS}
                        max={MAX_ROWS}
                        onChange={e => {
                          const val = parseInt(e.target.value)
                          if (!isNaN(val) && val >= MIN_ROWS && val <= MAX_ROWS) {
                            handleBedChange(i, 'rows', val)
                          }
                        }}
                        title="Rows (feet)"
                      />
                    </td>
                    <td>
                      <input
                        type="number"
                        className="form-control"
                        value={bed.cols}
                        min={MIN_COLS}
                        max={MAX_COLS}
                        onChange={e => {
                          const val = parseInt(e.target.value)
                          if (!isNaN(val) && val >= MIN_COLS && val <= MAX_COLS) {
                            handleBedChange(i, 'cols', val)
                          }
                        }}
                        title="Columns (feet)"
                      />
                    </td>
                    <td>
                      <select
                        className="form-select"
                        value={bed.lightLevel}
                        onChange={e => handleBedChange(i, 'lightLevel', e.target.value)}
                        title="Sunlight level"
                      >
                        <option value="low">☁️ Low</option>
                        <option value="medium">⛅ Medium</option>
                        <option value="high">☀️ High</option>
                      </select>
                    </td>
                    <td>
                      <div className="d-flex flex-column gap-1" style={{fontSize: '0.85rem'}}>
                        {['vegetable', 'fruit', 'herb'].map(type => (
                          <div key={type} className="form-check">
                            <input
                              className="form-check-input"
                              type="checkbox"
                              id={`bed-${i}-type-${type}`}
                              checked={(bed.allowedTypes || []).includes(type)}
                              onChange={() => handleTypeToggle(i, type)}
                            />
                            <label className="form-check-label" htmlFor={`bed-${i}-type-${type}`}>
                              {type}
                            </label>
                          </div>
                        ))}
                      </div>
                    </td>
                    <td>
                      <button
                        className="btn btn-danger btn-sm"
                        onClick={() => handleRemoveBed(i)}
                        disabled={beds.length <= MIN_BEDS}
                        title="Remove this bed"
                      >
                        Remove
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <button
              className="btn btn-success"
              onClick={handleAddBed}
              disabled={beds.length >= MAX_BEDS}
              title="Add a new bed"
            >
              Add Bed
            </button>
            <div className="alert alert-info mt-2">
              <strong>Total Growing Area:</strong> {beds.length} raised {beds.length === 1 ? 'bed' : 'beds'}; {totalCells} sq ft cells
            </div>
          </div>
        </div>
      </div>

      <div className="col-md-6">
        <div className="card">
          <div className="card-header d-flex justify-content-between align-items-center">
            <h5 className="card-title m-0">Select Crops</h5>
            <span className="badge bg-secondary">{selectedPlants.size} selected</span>
          </div>
          <div className="card-body" style={{ maxHeight: '500px', overflowY: 'auto' }}>
            <div className="d-flex flex-column gap-2">
              {sortedPlants.map(plant => (
                <div
                  key={plant.code}
                  className="form-check"
                  onClick={(e) => e.stopPropagation()}
                >
                  <input
                    className="form-check-input"
                    type="checkbox"
                    id={`plant-${plant.code}`}
                    checked={selectedPlants.has(plant.code)}
                    onChange={() => handlePlantToggle(plant.code)}
                    title={`${plant.name} - ${plant.sqftSpacing} per sqft, ${plant.lightLevel} light`}
                  />
                  <label className="form-check-label d-flex align-items-center gap-2" htmlFor={`plant-${plant.code}`} title={`${plant.name} - ${plant.lightLevel} light level`}>
                    <span style={{ fontSize: '1.2em' }}>{plant.icon}</span>
                    <span>{plant.name}</span>
                    <span className="text-muted small" title="Plants per square foot">({plant.sqftSpacing}/sqft)</span>
                  </label>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="col-12">
        <button
          className="btn btn-primary btn-lg w-100"
          onClick={handleGenerateClick}
          title={selectedPlants.size === 0 ? "Generate empty garden beds" : `Generate garden with ${selectedPlants.size} plant varieties`}
        >
          Generate Layout
        </button>
      </div>

      {/* Confirmation Modal */}
      {showConfirm && (
        <div
          className="modal d-block"
          style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}
          onClick={handleCancelGenerate}
        >
          <div className="modal-dialog modal-dialog-centered" onClick={(e) => e.stopPropagation()}>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Confirm Generate Garden</h5>
                <button
                  type="button"
                  className="btn-close"
                  onClick={handleCancelGenerate}
                  aria-label="Close"
                ></button>
              </div>
              <div className="modal-body">
                <div className="alert alert-warning mb-3">
                  <strong>Warning:</strong> This will overwrite your current garden layout.
                </div>
                <p>
                  {selectedPlants.size === 0 ? (
                    <>
                      Generate a new layout with <strong>empty raised beds</strong> ({beds.length} {beds.length === 1 ? 'bed' : 'beds'})?
                    </>
                  ) : (
                    <>
                      Generate a new layout with <strong>{selectedPlants.size} crop varieties</strong> distributed across <strong>{beds.length} {beds.length === 1 ? 'raised bed' : 'raised beds'}</strong>?
                    </>
                  )}
                </p>
                <p className="mb-0">
                  This action cannot be undone (yet).
                </p>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={handleCancelGenerate}
                >
                  Cancel
                </button>
                <button
                  type="button"
                  className="btn btn-primary"
                  onClick={handleConfirmGenerate}
                >
                  Generate
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
