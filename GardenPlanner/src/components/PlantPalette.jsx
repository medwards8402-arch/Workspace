import React, { useMemo } from 'react'

export function PlantPalette({ plants, selectedCode, onSelect }) {
  const sortedPlants = useMemo(() => {
    return plants.slice().sort((a,b) => a.name.localeCompare(b.name))
  }, [plants])
  
  const handlePlantClick = (e, code) => {
    e.stopPropagation() // Prevent bubbling to container
    onSelect(code)
  }

  const handleCardClick = (e) => {
    // Deselect if clicking on card background (not on a plant button)
    if (e.target === e.currentTarget || e.target.classList.contains('card-header')) {
      onSelect(null)
    }
  }
  
  return (
    <div className="card h-100" onClick={handleCardClick}>
      <div className="card-header" onClick={handleCardClick}>Plant Palette</div>
      <div className="list-group list-group-flush overflow-auto" style={{maxHeight: '70vh'}}>
        {sortedPlants.map(p => (
          <button key={p.code} className={`list-group-item list-group-item-action d-flex align-items-center gap-2 ${selectedCode===p.code?'active':''}`}
            onClick={(e) => handlePlantClick(e, p.code)} draggable
            onDragStart={e => { e.dataTransfer.setData('text/plain', p.code) }}>
            <span style={{fontSize: 22}}>{p.icon}</span>
            <span className="fw-semibold">{p.name}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
