import React, { useMemo } from 'react'
import { useSelection } from '../hooks/useSelection'

export function PlantPalette({ plants }) {
  const { selectedPlant, setSelectedPlant } = useSelection()
  
  const sortedPlants = useMemo(() => {
    return plants.slice().sort((a,b) => a.name.localeCompare(b.name))
  }, [plants])
  
  const handlePlantClick = (e, code) => {
    e.stopPropagation() // Prevent bubbling to container
    setSelectedPlant(code)
  }

  const handleCardClick = (e) => {
    // Deselect if clicking on card background (not on a plant button)
    if (e.target === e.currentTarget || e.target.classList.contains('card-header')) {
      setSelectedPlant(null)
    }
  }
  
  return (
    <div className="card" style={{width: 200, minWidth: 200, maxWidth: 200, maxHeight: '80vh', display: 'flex', flexDirection: 'column', position: 'sticky', top: '1rem'}} onClick={handleCardClick} title="Select a crop to add to your raised beds">
      <div className="card-header" onClick={handleCardClick}>Crop Palette</div>
      <div className="list-group list-group-flush overflow-auto" style={{flex: 1, minHeight: 0}}>
        {sortedPlants.map(p => (
          <button key={p.code} className={`list-group-item list-group-item-action d-flex align-items-center gap-2 ${selectedPlant===p.code?'active':''}`}
            onClick={(e) => handlePlantClick(e, p.code)} draggable
            onDragStart={e => { e.dataTransfer.setData('text/plain', p.code) }}
            title={`${p.name} - ${p.sqftSpacing}/sqft, ${p.lightLevel} light${p.cellsRequired ? `, needs ${p.cellsRequired} cells` : ''}`}>
            <span style={{fontSize: 22}}>{p.icon}</span>
            <span className="fw-semibold">{p.name}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
