import React, { useState, useMemo } from 'react'
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

  // Step wizard state (1: Preset/Beds, 2: Plants, 3: Review)
  const [currentStep, setCurrentStep] = useState(1)

  // Dynamic beds state: array of { name, rows, cols, lightLevel, allowedTypes }
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

  const applyPreset = (presetName) => {
    const presets = {
      beginner: [
        { name: 'Main Bed', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Herb Bed', rows: 2, cols: 4, lightLevel: 'high', allowedTypes: ['herb'] }
      ],
      family: [
        { name: 'Bed 1', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 2', rows: 4, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 3', rows: 4, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Herb Bed', rows: 2, cols: 4, lightLevel: 'high', allowedTypes: ['herb'] }
      ],
      largeProduction: [
        { name: 'Bed 1', rows: 8, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 2', rows: 8, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 3', rows: 8, cols: 8, lightLevel: 'high', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 4', rows: 6, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 5', rows: 6, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Herb Bed', rows: 4, cols: 4, lightLevel: 'high', allowedTypes: ['herb'] }
      ],
      shadyGarden: [
        { name: 'Bed 1', rows: 4, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 2', rows: 4, cols: 8, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit'] },
        { name: 'Bed 3', rows: 3, cols: 6, lightLevel: 'low', allowedTypes: ['vegetable', 'fruit', 'herb'] }
      ]
    }
    if (presets[presetName]) {
      setBeds(presets[presetName])
    }
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
      {/* Progress Steps Header */}
      <div className="col-12">
        <div className="d-flex justify-content-center mb-3">
          <div className="d-flex align-items-center gap-2">
            <button
              className={`btn ${currentStep === 1 ? 'btn-primary' : 'btn-outline-secondary'}`}
              onClick={() => setCurrentStep(1)}
              style={{ minWidth: '140px' }}
            >
              <span className="me-1">🏡</span> 1. Raised Beds
            </button>
            <span className="text-muted">→</span>
            <button
              className={`btn ${currentStep === 2 ? 'btn-primary' : 'btn-outline-secondary'}`}
              onClick={() => setCurrentStep(2)}
              style={{ minWidth: '140px' }}
            >
              <span className="me-1">🌱</span> 2. Select Crops
            </button>
            <span className="text-muted">→</span>
            <button
              className={`btn ${currentStep === 3 ? 'btn-primary' : 'btn-outline-secondary'}`}
              onClick={() => setCurrentStep(3)}
              style={{ minWidth: '140px' }}
            >
              <span className="me-1">✅</span> 3. Review
            </button>
          </div>
        </div>
      </div>

      {/* Step 1: Bed Configuration */}
      {currentStep === 1 && (
        <>
          <div className="col-12">
            <Tip id="bed-configuration-guide">
              Configure your raised beds and select some crops to get started.
            </Tip>
          </div>

          {/* Preset Templates */}
          <div className="col-12">
            <div className="card">
              <div className="card-body p-3">
                <div className="d-flex align-items-center justify-content-between mb-2">
                  <h6 className="mb-0 text-muted">Quick Start Templates</h6>
                </div>
                <div className="row g-2">
                  <div className="col-6 col-md-3">
                    <button 
                      className="btn btn-outline-secondary w-100 text-start"
                      onClick={() => applyPreset('beginner')}
                    >
                      <div className="d-flex align-items-center gap-2">
                        <span style={{ fontSize: '1.5em' }}>🌱</span>
                        <div>
                          <div className="fw-bold small">Beginner</div>
                          <div className="text-muted" style={{ fontSize: '0.75rem' }}>2 beds, 40 sq ft</div>
                        </div>
                      </div>
                    </button>
                  </div>
                  <div className="col-6 col-md-3">
                    <button 
                      className="btn btn-outline-secondary w-100 text-start"
                      onClick={() => applyPreset('family')}
                    >
                      <div className="d-flex align-items-center gap-2">
                        <span style={{ fontSize: '1.5em' }}>👨‍👩‍👧‍👦</span>
                        <div>
                          <div className="fw-bold small">Family Garden</div>
                          <div className="text-muted" style={{ fontSize: '0.75rem' }}>4 beds, 104 sq ft</div>
                        </div>
                      </div>
                    </button>
                  </div>
                  <div className="col-6 col-md-3">
                    <button 
                      className="btn btn-outline-secondary w-100 text-start"
                      onClick={() => applyPreset('largeProduction')}
                    >
                      <div className="d-flex align-items-center gap-2">
                        <span style={{ fontSize: '1.5em' }}>🚜</span>
                        <div>
                          <div className="fw-bold small">Large Production</div>
                          <div className="text-muted" style={{ fontSize: '0.75rem' }}>6 beds, 384 sq ft</div>
                        </div>
                      </div>
                    </button>
                  </div>
                  <div className="col-6 col-md-3">
                    <button 
                      className="btn btn-outline-secondary w-100 text-start"
                      onClick={() => applyPreset('shadyGarden')}
                    >
                      <div className="d-flex align-items-center gap-2">
                        <span style={{ fontSize: '1.5em' }}>☁️</span>
                        <div>
                          <div className="fw-bold small">Shady Garden</div>
                          <div className="text-muted" style={{ fontSize: '0.75rem' }}>3 beds, low light</div>
                        </div>
                      </div>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Bed Configuration Table */}
          <div className="col-12">
            <div className="card">
              <div className="card-header d-flex justify-content-between align-items-center">
                <h5 className="card-title m-0">Customize Beds</h5>
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
                        <th style={{ width: '30%' }}>Allowed Crop Types</th>
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

          <div className="col-12">
            <button
              className="btn btn-primary btn-lg w-100"
              onClick={() => setCurrentStep(2)}
            >
              Next: Select Crops →
            </button>
          </div>
        </>
      )}

      {/* Step 2: Plant Selection */}
      {currentStep === 2 && (
        <>
          <div className="col-12">
            <Tip id="plant-selection-guide">
              Don't overthink your crop selection! Garden generation creates a starting layout that you'll refine on the Layout tab. 
              Select a variety of crops you're interested in, then fine-tune placement and quantities later.
            </Tip>
          </div>

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
                                    {plant.sqftSpacing}/sq ft • {plant.lightLevel === 'high' ? '☀️' : '☁️'} {plant.lightLevel}
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

          <div className="col-12">
            <div className="d-flex gap-2">
              <button
                className="btn btn-outline-secondary btn-lg"
                onClick={() => setCurrentStep(1)}
              >
                ← Back to Beds
              </button>
              <button
                className="btn btn-primary btn-lg flex-grow-1"
                onClick={() => setCurrentStep(3)}
              >
                Next: Review & Generate →
              </button>
            </div>
          </div>
        </>
      )}

      {/* Step 3: Review & Generate */}
      {currentStep === 3 && (
        <>
          <div className="col-12">
            <Tip id="review-guide">
              Review your configuration below. Click Generate to create your garden layout.
            </Tip>
          </div>

          <div className="col-md-6">
            <div className="card">
              <div className="card-header bg-success text-white">
                <h5 className="card-title m-0">📋 Raised Beds Summary</h5>
              </div>
              <div className="card-body">
                <div className="mb-3">
                  <strong>Total:</strong> {beds.length} {beds.length === 1 ? 'bed' : 'beds'}, {totalCells} sq ft
                </div>
                <div className="list-group list-group-flush">
                  {beds.map((bed, i) => (
                    <div key={i} className="list-group-item px-0">
                      <div className="d-flex justify-content-between align-items-center">
                        <div>
                          <strong>{bed.name}</strong>
                          <div className="small text-muted">
                            {bed.rows}×{bed.cols} ft • {bed.lightLevel === 'high' ? '☀️' : '☁️'} {bed.lightLevel} light
                            <br />
                            Allows: {bed.allowedTypes.map(t => 
                              t === 'vegetable' ? '🥕' : t === 'fruit' ? '🍓' : '🌿'
                            ).join(' ')}
                          </div>
                        </div>
                        <span className="badge bg-secondary">{bed.rows * bed.cols} sq ft</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          <div className="col-md-6">
            <div className="card">
              <div className="card-header bg-primary text-white">
                <h5 className="card-title m-0">🌱 Selected Crops</h5>
              </div>
              <div className="card-body">
                {selectedPlants.size === 0 ? (
                  <div className="alert alert-info mb-0">
                    <strong>No crops selected.</strong> Empty beds will be generated.
                  </div>
                ) : (
                  <>
                    <div className="mb-3">
                      <strong>Total:</strong> {selectedPlants.size} plant {selectedPlants.size === 1 ? 'variety' : 'varieties'}
                    </div>
                    <div style={{ maxHeight: '300px', overflowY: 'auto' }}>
                      <div className="row g-2">
                        {Array.from(selectedPlants).map(code => {
                          const plant = PLANTS.find(p => p.code === code)
                          return plant ? (
                            <div key={code} className="col-6">
                              <div className="d-flex align-items-center gap-2 small">
                                <span>{plant.icon}</span>
                                <span>{plant.name}</span>
                              </div>
                            </div>
                          ) : null
                        })}
                      </div>
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>

          <div className="col-12">
            <div className="d-flex gap-2">
              <button
                className="btn btn-outline-secondary btn-lg"
                onClick={() => setCurrentStep(2)}
              >
                ← Back to Crops
              </button>
              <button
                className="btn btn-success btn-lg flex-grow-1"
                onClick={handleGenerateClick}
              >
                🚀 Generate Layout
              </button>
            </div>
          </div>
        </>
      )}

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
