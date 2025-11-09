import React, { useEffect, useState } from 'react'

/**
 * PlantInfo component shows details for selected plant(s)
 * Displays read-only plant data and editable notes
 * Handles both single and group selections
 */
export function PlantInfo({ selectedIndices, bed, bedIndex, plants, notes, onNotesChange }) {
  const [noteText, setNoteText] = useState('')
  const [hasMultipleValues, setHasMultipleValues] = useState(false)

  // Update note text when selection changes
  useEffect(() => {
    if (selectedIndices.size === 0) {
      setNoteText('')
      setHasMultipleValues(false)
      return
    }

    // Get all unique notes for selected cells
    const cellNotes = Array.from(selectedIndices).map(idx => {
      const key = `${bedIndex}.${idx}`
      return notes[key] || ''
    })

    const uniqueNotes = [...new Set(cellNotes)]
    
    if (uniqueNotes.length > 1) {
      setHasMultipleValues(true)
      setNoteText('') // Don't show conflicting notes
    } else {
      setHasMultipleValues(false)
      setNoteText(uniqueNotes[0] || '')
    }
  }, [selectedIndices, notes, bedIndex])

  // Always render the card to prevent layout shifts
  if (selectedIndices.size === 0) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header">
          <h6 className="card-title m-0">Plant Info</h6>
        </div>
        <div className="card-body">
          <p className="text-muted mb-0">Click on a cell to view plant details</p>
        </div>
      </div>
    )
  }

  // Get plant info for selected cells
  const selectedCells = Array.from(selectedIndices)
  const plantCodes = selectedCells.map(idx => bed[idx]).filter(Boolean)
  const uniquePlantCodes = [...new Set(plantCodes)]
  
  // If only empty cells selected
  if (uniquePlantCodes.length === 0) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header">
          <h6 className="card-title m-0">Selection</h6>
        </div>
        <div className="card-body">
          <p className="mb-2">
            <strong>{selectedIndices.size}</strong> empty {selectedIndices.size === 1 ? 'cell' : 'cells'} selected
          </p>
          <div className="alert alert-info small mb-0">
            Select a planted cell to view details
          </div>
        </div>
      </div>
    )
  }
  
  // If multiple different plants selected, show generic message
  if (uniquePlantCodes.length > 1) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header">
          <h6 className="card-title m-0">Selection</h6>
        </div>
        <div className="card-body">
          <p className="mb-2">
            <strong>{selectedIndices.size}</strong> cells selected with <strong>{uniquePlantCodes.length}</strong> different plants
          </p>
          <div className="alert alert-info small mb-0">
            Select cells with the same plant to view details and edit notes
          </div>
        </div>
      </div>
    )
  }

  // Single plant type selected (could be multiple cells)
  const plantCode = uniquePlantCodes[0]
  const plant = plants.find(p => p.code === plantCode)

  if (!plant) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-body">
          <p className="text-muted mb-0">No plant data available</p>
        </div>
      </div>
    )
  }

  const handleNoteChange = (e) => {
    const newNote = e.target.value
    setNoteText(newNote)
    
    // Update all selected cells with the new note
    const updates = {}
    selectedCells.forEach(idx => {
      const key = `${bedIndex}.${idx}`
      updates[key] = newNote
    })
    
    onNotesChange(updates)
  }

  return (
    <div className="card" style={{ width: '300px' }} onClick={(e) => e.stopPropagation()}>
      <div className="card-header" style={{ backgroundColor: plant.color, color: 'white' }}>
        <div className="d-flex align-items-center gap-2">
          <span style={{ fontSize: '1.5em' }}>{plant.icon}</span>
          <h6 className="card-title m-0">{plant.name}</h6>
        </div>
      </div>
      <div className="card-body">
        {selectedIndices.size > 1 && (
          <div className="mb-2">
            <span className="badge bg-secondary">{selectedIndices.size} cells selected</span>
          </div>
        )}
        
        <div className="mb-2">
          <strong>Plant Code:</strong> {plant.code}
        </div>
        
        <div className="mb-2">
          <strong>Planting Time:</strong><br />
          {plant.plantAfterFrostDays >= 0 
            ? `${plant.plantAfterFrostDays} days after last frost`
            : `${Math.abs(plant.plantAfterFrostDays)} days before last frost`
          }
        </div>
        
        {plant.startIndoorsWeeks > 0 && (
          <div className="mb-2">
            <strong>Start Indoors:</strong><br />
            {plant.startIndoorsWeeks} weeks before outdoor planting
          </div>
        )}
        
        <div className="mb-3">
          <strong>Harvest:</strong><br />
          {plant.harvestWeeks} weeks after planting
        </div>
        
        <div className="mb-2">
          <strong>Spacing:</strong><br />
          {plant.sqftSpacing} plant{plant.sqftSpacing > 1 ? 's' : ''} per square foot
        </div>
        
        {plant.cellsRequired && (
          <div className="mb-2">
            <div className="alert alert-warning small mb-0" style={{ padding: '0.5rem' }}>
              <strong>⚠️ Needs {plant.cellsRequired} cells:</strong> This plant sprawls and requires {plant.cellsRequired} square feet of space
            </div>
          </div>
        )}
        
        <div className="mb-2">
          <strong>Light Level:</strong><br />
          <span className="badge" style={{
            backgroundColor: plant.lightLevel === 'high' ? '#fbbf24' : plant.lightLevel === 'medium' ? '#60a5fa' : '#94a3b8'
          }}>
            {plant.lightLevel}
          </span>
        </div>
        
        <hr />
        
        <div>
          <label className="form-label fw-bold">Notes:</label>
          {hasMultipleValues && (
            <div className="alert alert-warning small mb-2">
              Selected cells have different notes. Changes will overwrite all.
            </div>
          )}
          <textarea
            className="form-control"
            rows="4"
            value={noteText}
            onChange={handleNoteChange}
            placeholder="Add notes about this plant..."
          />
        </div>
      </div>
    </div>
  )
}
