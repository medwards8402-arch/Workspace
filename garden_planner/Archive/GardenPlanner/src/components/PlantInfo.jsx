import React, { useEffect, useState } from 'react'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { useSelection } from '../hooks/useSelection'
import { PLANTS, USDA_ZONES } from '../data'
import { computeSpringSchedule, computeFallSchedule } from '../schedule'

/**
 * PlantInfo component shows details for selected plant(s)
 * Displays read-only plant data and editable notes
 * Handles both single and group selections
 */
export function PlantInfo() {
  const { garden, updateNotes } = useGardenOperations()
  const { selection, selectedPlant } = useSelection()
  const [noteText, setNoteText] = useState('')
  const [hasMultipleValues, setHasMultipleValues] = useState(false)

  const { bedIndex, cellIndices: selectedIndices } = selection
  const bed = bedIndex !== null ? garden.getBed(bedIndex) : null

  // Update note text when selection changes
  useEffect(() => {
    if (selectedIndices.size === 0 || bedIndex === null) {
      setNoteText('')
      setHasMultipleValues(false)
      return
    }

    // Get all unique notes for selected cells
    const cellNotes = Array.from(selectedIndices).map(idx => {
      return garden.getNote(bedIndex, idx)
    })

    const uniqueNotes = [...new Set(cellNotes)]
    
    if (uniqueNotes.length > 1) {
      setHasMultipleValues(true)
      setNoteText('') // Don't show conflicting notes
    } else {
      setHasMultipleValues(false)
      setNoteText(uniqueNotes[0] || '')
    }
  }, [selectedIndices, bedIndex, garden])

  // Always render the card to prevent layout shifts
  // Palette plant selected (show read-only info, no notes editor)
  if (selectedPlant && (selectedIndices.size === 0 || bedIndex === null)) {
    const plant = PLANTS.find(p => p.code === selectedPlant)
    if (!plant) {
      return (
        <div className="card" style={{ width: '300px' }}>
          <div className="card-header">
            <h6 className="card-title m-0">Crop Info</h6>
          </div>
          <div className="card-body">
            <p className="text-muted mb-0">Select a crop from the palette to view details</p>
          </div>
        </div>
      )
    }
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header" style={{ backgroundColor: plant.color, color: 'white' }}>
          <div className="d-flex align-items-center gap-2">
            <span style={{ fontSize: '1.5em' }}>{plant.icon}</span>
            <h6 className="card-title m-0">{plant.name}</h6>
          </div>
        </div>
        <div className="card-body">
          {plant.startIndoorsWeeks > 0 && (
            <div className="mb-2">
              <strong>Start Indoors:</strong><br />
              {(() => {
                const zone = garden.zone || '5a'
                const spring = computeSpringSchedule(plant, zone)
                if (!spring.indoor) return 'Not applicable'
                return spring.indoor.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
              })()}
            </div>
          )}
          <div className="mb-2">
            <strong>{plant.startIndoorsWeeks > 0 ? 'Transplant Outdoors' : 'Direct Sow Outdoors'}:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const spring = computeSpringSchedule(plant, zone)
              if (!spring.sow) return 'Zone not set'
              return spring.sow.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
          <div className="mb-3">
            <strong>Harvest:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const spring = computeSpringSchedule(plant, zone)
              if (!spring.harvest) return 'Zone not set'
              return spring.harvest.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
          {plant.supportsFall && plant.fallStartIndoorsWeeks > 0 && (
            <div className="mb-2">
              <strong>Start Indoors (Fall):</strong><br />
              {(() => {
                const zone = garden.zone || '5a'
                const fall = computeFallSchedule(plant, zone)
                if (!fall.indoor) return 'Not applicable'
                return fall.indoor.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
              })()}
            </div>
          )}
          {plant.supportsFall && (
            <div className="mb-2">
              <strong>{plant.fallStartIndoorsWeeks > 0 ? 'Transplant Outdoors (Fall)' : 'Direct Sow Outdoors (Fall)'}:</strong><br />
              {(() => {
                const zone = garden.zone || '5a'
                const fall = computeFallSchedule(plant, zone)
                if (!fall.sow) return 'Not applicable'
                return fall.sow.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
              })()}
            </div>
          )}
          {plant.supportsFall && (
            <div className="mb-3">
              <strong>Fall Harvest:</strong><br />
              {(() => {
                const zone = garden.zone || '5a'
                const fall = computeFallSchedule(plant, zone)
                if (!fall.harvest) return 'Not applicable'
                return fall.harvest.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
              })()}
            </div>
          )}
          <div className="mb-2">
            <strong>Spacing:</strong><br />
            {plant.cellsRequired && plant.cellsRequired > 1 ? (
              <>1 plant / {plant.cellsRequired} sq ft <span className="badge bg-warning text-dark ms-1">sprawling</span></>
            ) : (
              <>{plant.sqftSpacing} plant{plant.sqftSpacing > 1 ? 's' : ''} / sq ft</>
            )}
          </div>
          <div className="mb-2">
            <strong>Light:</strong><br />
            <span className="badge" style={{backgroundColor: plant.lightLevel === 'high' ? '#fbbf24' : '#94a3b8'}}>{plant.lightLevel}</span>
          </div>
          {plant.tips && plant.tips.length > 0 && (
            <div className="mb-2">
              <strong>Tips:</strong>
              <ul className="small mb-0">
                {plant.tips.slice(0,3).map((t,i)=>(<li key={i}>{t}</li>))}
              </ul>
            </div>
          )}
          <div className="alert alert-info small mb-0">Plant not placed yet — notes available after planting.</div>
        </div>
      </div>
    )
  }

  if (selectedIndices.size === 0 || bedIndex === null) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header">
          <h6 className="card-title m-0">Crop Info</h6>
        </div>
        <div className="card-body">
          <p className="text-muted mb-0">Click a square (1 sq ft) to view crop details</p>
        </div>
      </div>
    )
  }

  // Get plant info for selected cells
  const selectedCells = Array.from(selectedIndices)
  const plantCodes = selectedCells.map(idx => bed.getCell(idx)).filter(Boolean)
  const uniquePlantCodes = [...new Set(plantCodes)]
  
  // If only empty squares selected
  if (uniquePlantCodes.length === 0) {
    return (
      <div className="card" style={{ width: '300px' }}>
        <div className="card-header">
          <h6 className="card-title m-0">Selection</h6>
        </div>
        <div className="card-body">
          <p className="mb-2">
            <strong>{selectedIndices.size}</strong> empty {selectedIndices.size === 1 ? 'square' : 'squares'} selected
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
            <strong>{selectedIndices.size}</strong> squares selected with <strong>{uniquePlantCodes.length}</strong> different crops
          </p>
          <div className="alert alert-info small mb-0">
            Select cells with the same crop to view details and edit notes
          </div>
        </div>
      </div>
    )
  }

  // Single plant type selected (could be multiple cells)
  const plantCode = uniquePlantCodes[0]
  const plant = PLANTS.find(p => p.code === plantCode)

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
    
    updateNotes(updates)
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
            <span className="badge bg-secondary">{selectedIndices.size} sq ft selected</span>
          </div>
        )}
        
        {plant.startIndoorsWeeks > 0 && (
          <div className="mb-2">
            <strong>Start Indoors:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const spring = computeSpringSchedule(plant, zone)
              if (!spring.indoor) return 'Not applicable'
              return spring.indoor.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        <div className="mb-2">
          <strong>{plant.startIndoorsWeeks > 0 ? 'Transplant Outdoors' : 'Direct Sow Outdoors'}:</strong><br />
          {(() => {
            const zone = garden.zone || '5a'
            const spring = computeSpringSchedule(plant, zone)
            if (!spring.sow) return 'Zone not set'
            return spring.sow.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
          })()}
        </div>
        <div className="mb-3">
          <strong>Harvest:</strong><br />
          {(() => {
            const zone = garden.zone || '5a'
            const spring = computeSpringSchedule(plant, zone)
            if (!spring.harvest) return 'Zone not set'
            return spring.harvest.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
          })()}
        </div>
        {plant.supportsFall && plant.fallStartIndoorsWeeks > 0 && (
          <div className="mb-2">
            <strong>Start Indoors (Fall):</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const fall = computeFallSchedule(plant, zone)
              if (!fall.indoor) return 'Not applicable'
              return fall.indoor.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        {plant.supportsFall && (
          <div className="mb-2">
            <strong>{plant.fallStartIndoorsWeeks > 0 ? 'Transplant Outdoors (Fall)' : 'Direct Sow Outdoors (Fall)'}:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const fall = computeFallSchedule(plant, zone)
              if (!fall.sow) return 'Not applicable'
              return fall.sow.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        {plant.supportsFall && (
          <div className="mb-3">
            <strong>Fall Harvest:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const fall = computeFallSchedule(plant, zone)
              if (!fall.harvest) return 'Not applicable'
              return fall.harvest.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        
        <div className="mb-2">
          <strong>Spacing:</strong><br />
          {plant.cellsRequired && plant.cellsRequired > 1 ? (
            <>
              1 plant / {plant.cellsRequired} sq ft{' '}
              <span className="badge bg-warning text-dark" title={`Sprawling crop: reserve ${plant.cellsRequired} sq ft per plant`}>sprawling</span>
            </>
          ) : (
            <>
              {plant.sqftSpacing} plant{plant.sqftSpacing > 1 ? 's' : ''} / sq ft
            </>
          )}
        </div>
        
        <div className="mb-2">
          <strong>Light Level:</strong><br />
          <span className="badge" style={{
            backgroundColor: plant.lightLevel === 'high' ? '#fbbf24' : '#94a3b8'
          }}>
            {plant.lightLevel}
          </span>
        </div>

        {plant.tips && plant.tips.length > 0 && (
          <div className="mb-2">
            <strong>Tips:</strong>
            <ul className="small mb-0">
              {plant.tips.slice(0,3).map((t, i) => (
                <li key={i}>{t}</li>
              ))}
            </ul>
          </div>
        )}
        
        <hr />
        
        <div>
          <label className="form-label fw-bold">Notes:</label>
          {hasMultipleValues && (
            <div className="alert alert-warning small mb-2">
              Selected squares have different notes. Changes will overwrite all.
            </div>
          )}
          <textarea
            className="form-control"
            rows="4"
            value={noteText}
            onChange={handleNoteChange}
            placeholder="Add notes about this crop..."
          />
        </div>
      </div>
    </div>
  )
}
