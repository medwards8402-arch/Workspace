import React, { useState } from 'react'
import { PLANTS } from '../data'
import { useGardenOperations } from '../hooks/useGardenOperations'

/**
 * NewGarden component for initial garden setup
 * Allows configuration of bed count/size and plant selection
 * Generates populated garden using auto-population algorithm
 */
export function NewGarden({ onAfterGenerate }) {
  const { generateGarden } = useGardenOperations()
  
  // Garden configuration state
  const [bedCount, setBedCount] = useState(3)
  // Default rows should be 8 per requirements
  const [bedRows, setBedRows] = useState(8)
  const [bedCols, setBedCols] = useState(4)
  const [bedLightLevels, setBedLightLevels] = useState(['high', 'medium', 'low'])
  
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

  const handlePlantToggle = (code) => {
    const newSet = new Set(selectedPlants)
    if (newSet.has(code)) {
      newSet.delete(code)
    } else {
      newSet.add(code)
    }
    setSelectedPlants(newSet)
  }
  
  const handleBedCountChange = (newCount) => {
    setBedCount(newCount)
    // Adjust bedLightLevels array to match new bed count
    const newLightLevels = [...bedLightLevels]
    while (newLightLevels.length < newCount) {
      const i = newLightLevels.length
      // Bed 1: high, Bed 2: medium, Bed 3: low, rest: high
      if (i === 1) {
        newLightLevels.push('medium')
      } else if (i === 2) {
        newLightLevels.push('low')
      } else {
        newLightLevels.push('high')
      }
    }
    while (newLightLevels.length > newCount) {
      newLightLevels.pop()
    }
    setBedLightLevels(newLightLevels)
  }
  
  const handleLightLevelChange = (bedIndex, level) => {
    const newLightLevels = [...bedLightLevels]
    newLightLevels[bedIndex] = level
    setBedLightLevels(newLightLevels)
  }

  const handleGenerateClick = (e) => {
    e.stopPropagation()
    setShowConfirm(true)
  }

  const handleConfirmGenerate = (e) => {
    e.stopPropagation()
    // Use new architecture's generateGarden
    generateGarden({
      bedCount,
      bedRows,
      bedCols,
      bedLightLevels,
      plantCodes: Array.from(selectedPlants)
    })
    setShowConfirm(false)
    setSelectedPlants(new Set()) // Clear selection after generation
    // Switch to garden plan tab if callback provided
    if (typeof onAfterGenerate === 'function') {
      onAfterGenerate()
    }
  }

  const handleCancelGenerate = (e) => {
    e.stopPropagation()
    setShowConfirm(false)
  }

  const totalCells = bedCount * bedRows * bedCols
  const sortedPlants = [...PLANTS].sort((a, b) => a.name.localeCompare(b.name))

  return (
    <div className="row g-3">
      <div className="col-md-6">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">Garden Configuration</h5>
          </div>
          <div className="card-body">
            <div className="mb-3">
              <label className="form-label">Number of Beds</label>
              <input
                type="number"
                className="form-control"
                value={bedCount}
                onChange={(e) => {
                  const val = parseInt(e.target.value)
                  if (!isNaN(val) && val >= MIN_BEDS && val <= MAX_BEDS) {
                    handleBedCountChange(val)
                  }
                }}
                onClick={(e) => e.stopPropagation()}
                min={MIN_BEDS}
                max={MAX_BEDS}
                title="How many separate garden beds to create"
              />
              <div className="form-text">Between {MIN_BEDS} and {MAX_BEDS} beds</div>
            </div>

            <div className="mb-3">
              <label className="form-label">Rows per Bed</label>
              <input
                type="number"
                className="form-control"
                value={bedRows}
                onChange={(e) => {
                  const val = parseInt(e.target.value)
                  if (!isNaN(val) && val >= MIN_ROWS && val <= MAX_ROWS) {
                    setBedRows(val)
                  }
                }}
                onClick={(e) => e.stopPropagation()}
                min={MIN_ROWS}
                max={MAX_ROWS}
                title="Number of rows in each bed (1 row = 1 foot)"
              />
              <div className="form-text">Between {MIN_ROWS} and {MAX_ROWS} rows</div>
            </div>

            <div className="mb-3">
              <label className="form-label">Columns per Bed</label>
              <input
                type="number"
                className="form-control"
                value={bedCols}
                onChange={(e) => {
                  const val = parseInt(e.target.value)
                  if (!isNaN(val) && val >= MIN_COLS && val <= MAX_COLS) {
                    setBedCols(val)
                  }
                }}
                onClick={(e) => e.stopPropagation()}
                min={MIN_COLS}
                max={MAX_COLS}
                title="Number of columns in each bed (1 column = 1 foot)"
              />
              <div className="form-text">Between {MIN_COLS} and {MAX_COLS} columns</div>
            </div>

            <div className="mb-3">
              <label className="form-label fw-bold" title="Configure sunlight exposure for each bed">Bed Light Levels</label>
              <div className="d-flex flex-column gap-2">
                {Array.from({ length: bedCount }, (_, i) => (
                  <div key={i} className="input-group input-group-sm">
                    <span className="input-group-text" style={{ minWidth: '80px' }}>Bed {i + 1}</span>
                    <select
                      className="form-select"
                      value={bedLightLevels[i] || 'high'}
                      onChange={(e) => handleLightLevelChange(i, e.target.value)}
                      onClick={(e) => e.stopPropagation()}
                      title={`Sunlight level for Bed ${i + 1} - plants prefer matching conditions`}
                    >
                      <option value="low">☁️ Low</option>
                      <option value="medium">⛅ Medium</option>
                      <option value="high">☀️ High</option>
                    </select>
                  </div>
                ))}
              </div>
              <div className="form-text">Plants prefer beds matching their light requirements</div>
            </div>

            <div className="alert alert-info">
              <strong>Total Space:</strong> {bedCount} {bedCount === 1 ? 'bed' : 'beds'} × {bedRows}×{bedCols} = {totalCells} cells
            </div>
          </div>
        </div>
      </div>

      <div className="col-md-6">
        <div className="card">
          <div className="card-header d-flex justify-content-between align-items-center">
            <h5 className="card-title m-0">Select Plants</h5>
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
          disabled={selectedPlants.size === 0}
          title={selectedPlants.size === 0 ? "Select at least one plant to generate garden" : `Generate garden with ${selectedPlants.size} plant varieties`}
        >
          Generate Garden
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
                  Generate a new garden with <strong>{selectedPlants.size} plant varieties</strong> distributed across <strong>{bedCount} {bedCount === 1 ? 'bed' : 'beds'}</strong>?
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
