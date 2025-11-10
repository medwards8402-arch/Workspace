import React, { useState, useMemo } from 'react'
import { PLANTS } from '../data'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { useSettings } from '../context/SettingsContext'
import { Tip } from './Tip'

/**
 * NewGarden component for initial garden setup
 * Single-page form with Family Garden defaults
 * Allows configuration of bed count/size and plant selection
 * Generates populated garden using auto-population algorithm
 */
export function NewGarden({ onAfterGenerate }) {
  const { generateGarden } = useGardenOperations()
  const { settings } = useSettings()
  const autoPlannerEnabled = settings.experimental?.autoPlanner || false

  // Dynamic beds state: array of { name, rows, cols, lightLevel, allowedTypes }
  // Defaults set to Family Garden configuration
  const [beds, setBeds] = useState([
    { name: 'Bed 1', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Bed 2', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Bed 3', rows: 4, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
    { name: 'Herb Bed', rows: 2, cols: 4, lightLevel: 'high', allowedTypes: ['herb'] }
  ])

  // Plant selection state
  const [selectedPlants, setSelectedPlants] = useState(new Set())
  const [plantFilter, setPlantFilter] = useState({ type: 'all', light: 'all', search: '' })
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

  const handleSelectAllVisible = () => {
    const newSet = new Set(selectedPlants)
    filteredPlants.forEach(plant => newSet.add(plant.code))
    setSelectedPlants(newSet)
  }

  const handleDeselectAllVisible = () => {
    const newSet = new Set(selectedPlants)
    filteredPlants.forEach(plant => newSet.delete(plant.code))
    setSelectedPlants(newSet)
  }

  const handleSelectByType = (type) => {
    const plantsOfType = PLANTS.filter(p => p.type === type)
    const allSelected = plantsOfType.every(plant => selectedPlants.has(plant.code))
    const newSet = new Set(selectedPlants)
    
    if (allSelected) {
      // Deselect all of this type
      plantsOfType.forEach(plant => newSet.delete(plant.code))
    } else {
      // Select all of this type
      plantsOfType.forEach(plant => newSet.add(plant.code))
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

  // Filtered plants based on current filter settings
  const filteredPlants = useMemo(() => {
    return sortedPlants.filter(plant => {
      const typeMatch = plantFilter.type === 'all' || plant.type === plantFilter.type
      const lightMatch = plantFilter.light === 'all' || plant.lightLevel === plantFilter.light
      const searchMatch = plantFilter.search === '' || 
        plant.name.toLowerCase().includes(plantFilter.search.toLowerCase())
      return typeMatch && lightMatch && searchMatch
    })
  }, [plantFilter, sortedPlants])

  return (
    <div className="row g-3">
      {/* Header Tip */}
      <div className="col-12">
        {autoPlannerEnabled ? (
          <Tip id="garden-setup-guide">
            Configure your raised beds and select crops to generate your garden layout. Adjust bed sizes, light levels, and allowed crop types, then choose which plants you want to grow.
          </Tip>
        ) : (
          <Tip id="basic-garden-setup">
            Configure your raised beds below. Adjust the bed names, sizes, and light levels to match your garden space. 
            When you're ready, click "Create Beds" to set up your garden, then use the Plan tab to add plants manually.
          </Tip>
        )}
      </div>

      {/* Bed Configuration Section */}
      <div className="col-12">
        <div className="card">
          <div className="card-header d-flex justify-content-between align-items-center">
            <h5 className="card-title m-0">Raised Beds</h5>
            <span className="badge bg-info">
              {beds.length} {beds.length === 1 ? 'bed' : 'beds'} • {totalCells} sq ft total
            </span>
          </div>
          <div className="card-body">
            <div className="table-responsive">
              <table className="table table-hover align-middle">
                <thead className="table-light">
                  <tr>
                    <th style={{ width: '25%' }}>Name</th>
                    <th style={{ width: '10%' }}>Size</th>
                    <th style={{ width: '15%' }}>Light</th>
                    {autoPlannerEnabled && <th style={{ width: '30%' }}>Allowed Crop Types</th>}
                    <th style={{ width: '10%' }}>Area</th>
                    <th style={{ width: '10%' }}></th>
                  </tr>
                </thead>
                <tbody>
                  {beds.map((bed, i) => (
                    <tr key={i}>
                      <td>
                        <input
                          type="text"
                          className="form-control form-control-sm"
                          value={bed.name}
                          onChange={e => handleBedChange(i, 'name', e.target.value)}
                          maxLength={32}
                          placeholder="Bed name"
                        />
                      </td>
                      <td>
                        <div className="d-flex gap-1 align-items-center">
                          <input
                            type="number"
                            className="form-control form-control-sm"
                            style={{ width: '50px' }}
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
                          <span className="text-muted">×</span>
                          <input
                            type="number"
                            className="form-control form-control-sm"
                            style={{ width: '50px' }}
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
                        </div>
                      </td>
                      <td>
                        <select
                          className="form-select form-select-sm"
                          value={bed.lightLevel}
                          onChange={e => handleBedChange(i, 'lightLevel', e.target.value)}
                        >
                          <option value="low">☁️ Low</option>
                          <option value="high">☀️ High</option>
                        </select>
                      </td>
                      {autoPlannerEnabled && (
                        <td>
                          <div className="btn-group btn-group-sm w-100" role="group">
                            {['vegetable', 'fruit', 'herb'].map(type => (
                              <button
                              key={type}
                              type="button"
                              className={`btn ${(bed.allowedTypes || []).includes(type) ? 'btn-success' : 'btn-outline-secondary'}`}
                              onClick={() => handleTypeToggle(i, type)}
                              title={`${type.charAt(0).toUpperCase() + type.slice(1)}`}
                            >
                              {type === 'vegetable' && '🥕'}
                              {type === 'fruit' && '🍓'}
                              {type === 'herb' && '🌿'}
                            </button>
                          ))}
                        </div>
                      </td>
                      )}
                      <td className="text-center">
                        <span className="badge bg-light text-dark">
                          {bed.rows * bed.cols} sq ft
                        </span>
                      </td>
                      <td>
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => handleRemoveBed(i)}
                          disabled={beds.length <= MIN_BEDS}
                          title="Remove bed"
                        >
                          ×
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <button
              className="btn btn-success btn-sm"
              onClick={handleAddBed}
              disabled={beds.length >= MAX_BEDS}
            >
              <span className="me-1">+</span> Add Another Bed
            </button>
          </div>
        </div>
      </div>

      {/* Plant Selection Section - Only show if auto-planner is enabled */}
      {autoPlannerEnabled && (
        <div className="col-12">
          <div className="card">
            <div className="card-header">
              <div className="row align-items-center g-2">
                <div className="col-md-8">
                  <h5 className="card-title m-0">
                    Select Crops
                    <span className="badge bg-primary ms-2">{selectedPlants.size} selected</span>
                  </h5>
                </div>
                <div className="col-md-4 text-md-end">
                  <div className="btn-group btn-group-sm" role="group">
                    <button 
                      className="btn btn-outline-success"
                      onClick={handleSelectAllVisible}
                      title="Select all visible plants"
                    >
                      Select All
                    </button>
                    <button 
                      className="btn btn-outline-danger"
                      onClick={handleDeselectAllVisible}
                      title="Deselect all visible plants"
                  >
                    Clear
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div className="card-body">
            {/* Quick Select Buttons */}
            <div className="mb-3">
              <label className="form-label fw-bold small">Quick Select by Type:</label>
              <div className="btn-group btn-group-sm" role="group">
                <button 
                  className={`btn ${
                    PLANTS.filter(p => p.type === 'vegetable').every(p => selectedPlants.has(p.code))
                      ? 'btn-primary'
                      : 'btn-outline-primary'
                  }`}
                  onClick={() => handleSelectByType('vegetable')}
                  title={
                    PLANTS.filter(p => p.type === 'vegetable').every(p => selectedPlants.has(p.code))
                      ? 'Click to deselect all vegetables'
                      : 'Click to select all vegetables'
                  }
                >
                  🥕 All Vegetables
                </button>
                <button 
                  className={`btn ${
                    PLANTS.filter(p => p.type === 'fruit').every(p => selectedPlants.has(p.code))
                      ? 'btn-primary'
                      : 'btn-outline-primary'
                  }`}
                  onClick={() => handleSelectByType('fruit')}
                  title={
                    PLANTS.filter(p => p.type === 'fruit').every(p => selectedPlants.has(p.code))
                      ? 'Click to deselect all fruits'
                      : 'Click to select all fruits'
                  }
                >
                  🍓 All Fruits
                </button>
                <button 
                  className={`btn ${
                    PLANTS.filter(p => p.type === 'herb').every(p => selectedPlants.has(p.code))
                      ? 'btn-primary'
                      : 'btn-outline-primary'
                  }`}
                  onClick={() => handleSelectByType('herb')}
                  title={
                    PLANTS.filter(p => p.type === 'herb').every(p => selectedPlants.has(p.code))
                      ? 'Click to deselect all herbs'
                      : 'Click to select all herbs'
                  }
                >
                  🌿 All Herbs
                </button>
              </div>
            </div>

            {/* Filters */}
            <div className="row g-2 mb-3">
              <div className="col-md-4">
                <label className="form-label small">Filter by Type</label>
                <select 
                  className="form-select form-select-sm"
                  value={plantFilter.type}
                  onChange={e => setPlantFilter({...plantFilter, type: e.target.value})}
                >
                  <option value="all">All Types</option>
                  <option value="vegetable">🥕 Vegetables</option>
                  <option value="fruit">🍓 Fruits</option>
                  <option value="herb">🌿 Herbs</option>
                </select>
              </div>
              <div className="col-md-4">
                <label className="form-label small">Filter by Light</label>
                <select 
                  className="form-select form-select-sm"
                  value={plantFilter.light}
                  onChange={e => setPlantFilter({...plantFilter, light: e.target.value})}
                >
                  <option value="all">All Light Levels</option>
                  <option value="high">☀️ High Light</option>
                  <option value="low">☁️ Low Light</option>
                </select>
              </div>
              <div className="col-md-4">
                <label className="form-label small">Search</label>
                <input
                  type="text"
                  className="form-control form-control-sm"
                  placeholder="Search by name..."
                  value={plantFilter.search}
                  onChange={e => setPlantFilter({...plantFilter, search: e.target.value})}
                />
              </div>
            </div>

            {/* Plant List */}
            <div style={{ maxHeight: '400px', overflowY: 'auto' }} className="border rounded p-2">
              {filteredPlants.length === 0 ? (
                <div className="text-center text-muted py-4">
                  No plants match your filters
                </div>
              ) : (
                <div className="row g-2">
                  {filteredPlants.map(plant => (
                    <div key={plant.code} className="col-md-6">
                      <div 
                        className={`card ${selectedPlants.has(plant.code) ? 'border-primary bg-light' : ''}`}
                        style={{ cursor: 'pointer' }}
                        onClick={() => handlePlantToggle(plant.code)}
                      >
                        <div className="card-body p-2">
                          <div className="d-flex align-items-center gap-2">
                            <input
                              type="checkbox"
                              className="form-check-input mt-0"
                              checked={selectedPlants.has(plant.code)}
                              onChange={() => handlePlantToggle(plant.code)}
                              onClick={(e) => e.stopPropagation()}
                            />
                            <span style={{ fontSize: '1.5em' }}>{plant.icon}</span>
                            <div className="flex-grow-1">
                              <div className="fw-bold">{plant.name}</div>
                              <div className="small text-muted">
                                {plant.cellsRequired && plant.cellsRequired > 1
                                  ? `1 plant per ${plant.cellsRequired} sq ft`
                                  : `${plant.sqftSpacing}/sq ft`} • {plant.lightLevel === 'high' ? '☀️' : '☁️'} {plant.lightLevel}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
      )}

      {/* Generate Button */}
      <div className="col-12">
        <button
          className="btn btn-success btn-lg w-100"
          onClick={handleGenerateClick}
          disabled={autoPlannerEnabled && selectedPlants.size === 0}
        >
          <span className="me-2">{autoPlannerEnabled ? '🌱' : '📐'}</span>
          {autoPlannerEnabled ? (
            <>
              Generate Garden Layout
              {selectedPlants.size > 0 && ` (${selectedPlants.size} crops)`}
            </>
          ) : (
            'Create Beds'
          )}
        </button>
      </div>

      {/* Confirmation Modal */}
      {showConfirm && (
        <div 
          className="modal show d-block" 
          style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}
          onClick={handleCancelGenerate}
        >
          <div className="modal-dialog modal-dialog-centered" onClick={(e) => e.stopPropagation()}>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Generate New Garden?</h5>
                <button type="button" className="btn-close" onClick={handleCancelGenerate}></button>
              </div>
              <div className="modal-body">
                <p>This will replace your current garden layout with a new auto-generated design using:</p>
                <ul>
                  <li><strong>{beds.length}</strong> raised {beds.length === 1 ? 'bed' : 'beds'} ({totalCells} sq ft total)</li>
                  <li><strong>{selectedPlants.size}</strong> selected {selectedPlants.size === 1 ? 'crop' : 'crops'}</li>
                </ul>
                <p className="text-warning mb-0">⚠️ Your current garden will be replaced.</p>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={handleCancelGenerate}>
                  Cancel
                </button>
                <button type="button" className="btn btn-success" onClick={handleConfirmGenerate}>
                  Generate Garden
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
