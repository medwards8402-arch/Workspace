import React, { useMemo, useState } from 'react'
import { useSelection } from '../hooks/useSelection'

export function PlantPalette({ plants }) {
  const { selectedPlant, setSelectedPlant } = useSelection()
  const [plantFilter, setPlantFilter] = useState({ type: 'all', light: 'all', search: '' })
  
  const sortedPlants = useMemo(() => {
    return plants.slice().sort((a,b) => a.name.localeCompare(b.name))
  }, [plants])

  const filteredPlants = useMemo(() => {
    return sortedPlants.filter(plant => {
      const typeMatch = plantFilter.type === 'all' || plant.type === plantFilter.type
      const lightMatch = plantFilter.light === 'all' || plant.lightLevel === plantFilter.light
      const searchMatch = plantFilter.search === '' || 
        plant.name.toLowerCase().includes(plantFilter.search.toLowerCase())
      return typeMatch && lightMatch && searchMatch
    })
  }, [plantFilter, sortedPlants])
  
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
      <div className="card-header p-2" onClick={handleCardClick}>
        <div className="d-flex justify-content-between align-items-center">
          <small className="fw-bold">Crop Palette</small>
          <span className="badge bg-secondary" style={{fontSize: '0.65rem'}}>{filteredPlants.length}</span>
        </div>
      </div>
      
      {/* Filters */}
      <div className="p-2" style={{borderBottom: '1px solid #dee2e6'}}>
        <select 
          className="form-select form-select-sm mb-1"
          style={{fontSize: '0.75rem', padding: '0.25rem 0.5rem'}}
          value={plantFilter.type}
          onChange={e => setPlantFilter({...plantFilter, type: e.target.value})}
        >
          <option value="all">All Types</option>
          <option value="vegetable">🥕 Veg</option>
          <option value="fruit">🍓 Fruit</option>
          <option value="herb">🌿 Herb</option>
        </select>
        <select 
          className="form-select form-select-sm mb-1"
          style={{fontSize: '0.75rem', padding: '0.25rem 0.5rem'}}
          value={plantFilter.light}
          onChange={e => setPlantFilter({...plantFilter, light: e.target.value})}
        >
          <option value="all">All Light</option>
          <option value="high">☀️ High</option>
          <option value="low">☁️ Low</option>
        </select>
        <input
          type="text"
          className="form-control form-control-sm"
          style={{fontSize: '0.75rem', padding: '0.25rem 0.5rem'}}
          placeholder="Search..."
          value={plantFilter.search}
          onChange={e => setPlantFilter({...plantFilter, search: e.target.value})}
        />
      </div>

      <div className="list-group list-group-flush overflow-auto" style={{flex: 1, minHeight: 0}}>
        {filteredPlants.length === 0 ? (
          <div className="text-center text-muted p-2" style={{fontSize: '0.75rem'}}>
            No matches
          </div>
        ) : (
          filteredPlants.map(p => (
            <button key={p.code} className={`list-group-item list-group-item-action d-flex align-items-center gap-2 ${selectedPlant===p.code?'active':''}`}
              onClick={(e) => handlePlantClick(e, p.code)} draggable
              onDragStart={e => { e.dataTransfer.setData('text/plain', p.code) }}
              title={`${p.name} - ${p.sqftSpacing}/sqft, ${p.lightLevel} light${p.cellsRequired ? `, needs ${p.cellsRequired} sq ft` : ''}`}
              style={{fontSize: '0.85rem', padding: '0.5rem 0.75rem'}}>
              <span style={{fontSize: 20}}>{p.icon}</span>
              <span className="fw-semibold">{p.name}</span>
            </button>
          ))
        )}
      </div>
    </div>
  )
}
