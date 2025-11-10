import React, { useEffect, useState } from 'react'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { useSelection } from '../hooks/useSelection'
import { PLANTS, USDA_ZONES } from '../data'

/**
 * PlantInfo component shows details for selected plant(s)
 * Displays read-only plant data and editable notes
 * Handles both single and group selections
 */
export function PlantInfo() {
  const { garden, updateNotes } = useGardenOperations()
  const { selection } = useSelection()
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
              const today = new Date()
              const z = USDA_ZONES[zone]
              if (!z) return 'Zone not set'
              let year = today.getFullYear()
              const lastFrost = new Date(year, z.month - 1, z.day)
              if (lastFrost < today) lastFrost.setFullYear(year + 1)
              const indoorDate = new Date(lastFrost)
              indoorDate.setDate(indoorDate.getDate() - plant.startIndoorsWeeks * 7)
              return indoorDate.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        <div className="mb-2">
          <strong>{plant.startIndoorsWeeks > 0 ? 'Transplant Outdoors' : 'Direct Sow Outdoors'}:</strong><br />
          {(() => {
            // Get last frost date from zone
            const zone = garden.zone || '5a'
            const today = new Date()
            const z = USDA_ZONES[zone]
            if (!z) return 'Zone not set'
            let year = today.getFullYear()
            const lastFrost = new Date(year, z.month - 1, z.day)
            if (lastFrost < today) lastFrost.setFullYear(year + 1)
            const plantDate = new Date(lastFrost)
            plantDate.setDate(plantDate.getDate() + plant.plantAfterFrostDays)
            return plantDate.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
          })()}
        </div>
        <div className="mb-3">
          <strong>Harvest:</strong><br />
          {(() => {
            const zone = garden.zone || '5a'
            const today = new Date()
            const z = USDA_ZONES[zone]
            if (!z) return 'Zone not set'
            let year = today.getFullYear()
            const lastFrost = new Date(year, z.month - 1, z.day)
            if (lastFrost < today) lastFrost.setFullYear(year + 1)
            const plantDate = new Date(lastFrost)
            plantDate.setDate(plantDate.getDate() + plant.plantAfterFrostDays)
            const harvestDate = new Date(plantDate)
            harvestDate.setDate(harvestDate.getDate() + plant.harvestWeeks * 7)
            return harvestDate.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
          })()}
        </div>
        {plant.supportsFall && plant.fallStartIndoorsWeeks > 0 && (
          <div className="mb-2">
            <strong>Start Indoors (Fall):</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const today = new Date()
              const z = USDA_ZONES[zone]
              if (!z || !z.firstMonth || !z.firstDay) return 'Not applicable'
              let year = today.getFullYear()
              const spring = new Date(year, z.month - 1, z.day)
              if (spring < today) spring.setFullYear(year + 1)
              const firstFallFrost = new Date(spring.getFullYear(), z.firstMonth - 1, z.firstDay)
              const fallIndoor = new Date(firstFallFrost)
              fallIndoor.setDate(fallIndoor.getDate() - plant.fallStartIndoorsWeeks * 7)
              return fallIndoor.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        {plant.supportsFall && (
          <div className="mb-2">
            <strong>{plant.fallStartIndoorsWeeks > 0 ? 'Transplant Outdoors (Fall)' : 'Direct Sow Outdoors (Fall)'}:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const today = new Date()
              const z = USDA_ZONES[zone]
              if (!z || !z.firstMonth || !z.firstDay) return 'Not applicable'
              let year = today.getFullYear()
              // Align fall frost year to spring frost year logic for consistency
              const spring = new Date(year, z.month - 1, z.day)
              if (spring < today) spring.setFullYear(year + 1)
              const firstFallFrost = new Date(spring.getFullYear(), z.firstMonth - 1, z.firstDay)
              const fallPlant = new Date(firstFallFrost)
              fallPlant.setDate(fallPlant.getDate() - plant.fallPlantBeforeFrostDays)
              return fallPlant.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
            })()}
          </div>
        )}
        {plant.supportsFall && (
          <div className="mb-3">
            <strong>Fall Harvest:</strong><br />
            {(() => {
              const zone = garden.zone || '5a'
              const today = new Date()
              const z = USDA_ZONES[zone]
              if (!z || !z.firstMonth || !z.firstDay) return 'Not applicable'
              let year = today.getFullYear()
              const spring = new Date(year, z.month - 1, z.day)
              if (spring < today) spring.setFullYear(year + 1)
              const firstFallFrost = new Date(spring.getFullYear(), z.firstMonth - 1, z.firstDay)
              const fallPlant = new Date(firstFallFrost)
              fallPlant.setDate(fallPlant.getDate() - plant.fallPlantBeforeFrostDays)
              const fallHarvest = new Date(fallPlant)
              fallHarvest.setDate(fallHarvest.getDate() + plant.harvestWeeks * 7)
              return fallHarvest.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
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
