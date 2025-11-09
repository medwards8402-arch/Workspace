import React, { useEffect, useRef, useState } from 'react'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { useSelection } from '../hooks/useSelection'
import { PLANTS } from '../data'

function Cell({ plant, onDrop, onClick, onDoubleClick, onMouseDown, onMouseEnter, selected }) {
  const handleClick = (e) => {
    e.stopPropagation() // Prevent click from bubbling to bed container
    onClick()
  }
  
  const handleDoubleClick = (e) => {
    e.stopPropagation()
    onDoubleClick()
  }

  const handleMouseDown = (e) => {
    e.stopPropagation()
    onMouseDown()
  }

  const handleMouseEnter = (e) => {
    onMouseEnter()
  }

  // Render multiple icons based on sqftSpacing
  const renderPlantIcons = () => {
    if (!plant) return null
    
    const spacing = plant.sqftSpacing || 1
    
    // For single plant per cell
    if (spacing === 1) {
      return (
        <>
          <div style={{fontSize: 26, lineHeight: 1}}>{plant.icon}</div>
          <div className="small text-center" style={{lineHeight: 1.1, fontSize: '10px'}}>{plant.name}</div>
        </>
      )
    }
    
    // For 2 plants per cell - side by side
    if (spacing === 2) {
      return (
        <>
          <div style={{display: 'flex', gap: '2px', fontSize: 18}}>
            {plant.icon}{plant.icon}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: '9px'}}>{plant.name}</div>
        </>
      )
    }
    
    // For 4 plants per cell - 2x2 grid
    if (spacing === 4) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1px', fontSize: 16}}>
            {Array(4).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: '8px'}}>{plant.name}</div>
        </>
      )
    }
    
    // For 8 plants per cell - 2x4 grid
    if (spacing === 8) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1px', fontSize: 11}}>
            {Array(8).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: '7px'}}>{plant.name}</div>
        </>
      )
    }
    
    // For 9 plants per cell - 3x3 grid
    if (spacing === 9) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1px', fontSize: 12}}>
            {Array(9).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: '7px'}}>{plant.name}</div>
        </>
      )
    }
    
    // For 16 plants per cell - 4x4 grid
    if (spacing === 16) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1px', fontSize: 10}}>
            {Array(16).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: '7px'}}>{plant.name}</div>
        </>
      )
    }
    
    // Default fallback
    return (
      <>
        <div style={{fontSize: 26, lineHeight: 1}}>{plant.icon}</div>
        <div className="small text-center" style={{lineHeight: 1.1, fontSize: '10px'}}>{plant.name}</div>
      </>
    )
  }

  return (
    <div className={`border rounded-3 d-flex flex-column align-items-center justify-content-center position-relative`} 
         style={{width: 68, height: 68, background: 'var(--cell-bg)', borderStyle: 'dashed', cursor: 'pointer', userSelect: 'none'}}
         onDragOver={e => { e.preventDefault(); e.dataTransfer.dropEffect='copy' }}
         onDrop={onDrop}
         onClick={handleClick}
         onDoubleClick={handleDoubleClick}
         onMouseDown={handleMouseDown}
         onMouseEnter={handleMouseEnter}>
      {renderPlantIcons()}
      {selected && <div className="position-absolute w-100 h-100 rounded-3" style={{outline: '2px solid var(--bs-primary)', outlineOffset: 2}} />}
    </div>
  )
}

export function GardenBed({ bedIndex }) {
  const { garden, updateCell, updateCells, clearCells } = useGardenOperations()
  const { selectedPlant, selection, setSelection, setActiveBed, activeBed } = useSelection()
  const [isDragging, setIsDragging] = useState(false)
  const gridRef = useRef(null)

  const bed = garden.getBed(bedIndex)
  const bedRows = bed.rows
  const bedCols = bed.cols
  const lightLevel = bed.lightLevel

  // Local selection state for this bed
  const isThisBedActive = activeBed === bedIndex
  const isThisBedSelected = selection.bedIndex === bedIndex
  const selectedIndices = isThisBedSelected ? selection.cellIndices : new Set()

  const handleClickAt = (i) => {
    // Activate this bed and set selection atomically
    setActiveBed(bedIndex)
    setSelection(bedIndex, new Set([i]))
    
    // If a plant is selected from palette
    if (selectedPlant) {
      const currentCell = bed.getCell(i)
      // If clicking on cell with same plant, just select (don't replace)
      if (currentCell !== selectedPlant) {
        // Place plant
        updateCell(bedIndex, i, selectedPlant)
      }
    }
  }

  const handleDoubleClickAt = (i) => {
    setActiveBed(bedIndex)
    
    const plantCode = bed.getCell(i)
    if (!plantCode) {
      setSelection(bedIndex, new Set())
      return
    }
    
    // Get connected cells using BFS (from bed model)
    const connected = bed.getConnectedCells(i)
    setSelection(bedIndex, connected)
  }

  const handleMouseDownAt = (i) => {
    if (selectedPlant) {
      setIsDragging(true)
      updateCell(bedIndex, i, selectedPlant)
    }
  }

  const handleMouseEnterAt = (i) => {
    if (isDragging && selectedPlant) {
      updateCell(bedIndex, i, selectedPlant)
    }
  }

  const handleDropAt = (i, code) => {
    updateCell(bedIndex, i, code)
    setSelection(bedIndex, new Set())
  }

  const handleDelete = () => {
    if (selectedIndices.size === 0) return
    clearCells(bedIndex, Array.from(selectedIndices))
    setSelection(bedIndex, new Set())
  }

  // Mouse up handler for drag
  useEffect(() => {
    const handleMouseUp = () => setIsDragging(false)
    window.addEventListener('mouseup', handleMouseUp)
    return () => window.removeEventListener('mouseup', handleMouseUp)
  }, [])

  // Delete key listener
  useEffect(() => {
    const handler = (e) => {
      if (e.key === 'Delete' && isThisBedSelected && selectedIndices.size > 0) {
        handleDelete()
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [isThisBedSelected, selectedIndices])

  // Click-away deselection
  const handleCardClick = (e) => {
    e.stopPropagation()
    if (e.target === e.currentTarget) {
      setSelection(bedIndex, new Set())
    }
  }

  const handleBedClick = (e) => {
    e.stopPropagation()
    if (e.currentTarget === e.target) {
      setSelection(bedIndex, new Set())
    }
  }

  // Check if any selected cells have plants
  const hasSelectedPlants = Array.from(selectedIndices).some(i => bed.getCell(i) !== null)

  return (
    <div className="d-flex gap-3" onClick={handleCardClick}>
      <div className="card" style={{ width: 320, minWidth: 320, maxWidth: 320 }}>
        <div className="card-header d-flex justify-content-between align-items-center" onClick={handleCardClick}>
          <span>
            Bed {bedIndex + 1}
            {lightLevel && (
              <span className="ms-2" title={`${lightLevel} light`} style={{ fontSize: '1.2em' }}>
                {lightLevel === 'high' ? '☀️' : lightLevel === 'medium' ? '⛅' : '☁️'}
              </span>
            )}
          </span>
          <span style={{width: 100, display: 'inline-block', textAlign: 'right'}}>
            <button
              className="btn btn-sm btn-danger"
              style={{minWidth: 90, opacity: selectedIndices.size > 0 && hasSelectedPlants ? 1 : 0.3, pointerEvents: selectedIndices.size > 0 && hasSelectedPlants ? 'auto' : 'none', transition: 'opacity 0.2s'}}
              onClick={(e) => {
                if (selectedIndices.size > 0 && hasSelectedPlants) {
                  e.stopPropagation();
                  handleDelete();
                }
              }}
            >
              Delete ({selectedIndices.size})
            </button>
          </span>
        </div>
        <div className="card-body d-flex justify-content-center" onClick={handleBedClick} style={{ padding: 12 }}>
          <div
            ref={gridRef}
            className="d-grid gap-2"
            style={{
              gridTemplateColumns: `repeat(${bedCols}, 68px)`,
              width: bedCols * 68 + (bedCols - 1) * 8,
              minWidth: bedCols * 68 + (bedCols - 1) * 8,
              maxWidth: bedCols * 68 + (bedCols - 1) * 8,
            }}
            onClick={handleBedClick}
          >
            {bed.cells.map((code, i) => {
              const plant = PLANTS.find(p => p.code === code)
              return (
                <Cell
                  key={i}
                  plant={plant}
                  selected={selectedIndices.has(i)}
                  onDrop={(e) => {
                    e.preventDefault();
                    const c = e.dataTransfer.getData('text/plain');
                    if (c) handleDropAt(i, c);
                  }}
                  onClick={() => handleClickAt(i)}
                  onDoubleClick={() => handleDoubleClickAt(i)}
                  onMouseDown={() => handleMouseDownAt(i)}
                  onMouseEnter={() => handleMouseEnterAt(i)}
                />
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
