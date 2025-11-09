import React, { useEffect, useRef, useState } from 'react'
import { flushSync } from 'react-dom'

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

export function GardenBed({ bedIndex, bed, onChange, plants, selectedCode, bedRows, bedCols, deselectTrigger, activeBed, setActiveBed, notes, onNotesChange, onSelectionChange, lightLevel }) {
  const [selectedIndices, setSelectedIndices] = useState(new Set())
  const [isDragging, setIsDragging] = useState(false)
  const gridRef = useRef(null)

  useEffect(() => { setSelectedIndices(new Set()) }, [bed])

  // Notify parent when selection changes
  useEffect(() => {
    if (onSelectionChange) {
      onSelectionChange(bedIndex, selectedIndices)
    }
  }, [selectedIndices, bedIndex, onSelectionChange])

  // Deselect when triggered from parent (e.g., clicking outside)
  useEffect(() => {
    if (deselectTrigger > 0) {
      setSelectedIndices(new Set())
    }
  }, [deselectTrigger])

  // Deselect if another bed becomes active - but do it BEFORE the new bed sets its selection
  useEffect(() => {
    // Only clear if activeBed is set to a DIFFERENT bed (not this one, not null)
    if (activeBed !== null && activeBed !== bedIndex && selectedIndices.size > 0) {
      flushSync(() => {
        setSelectedIndices(new Set());
      });
    }
  }, [activeBed, bedIndex, selectedIndices])

  const handleDropAt = (i, code) => {
    const next = bed.slice()
    next[i] = code
    onChange(next)
    setSelectedIndices(new Set())
  }

  const handleClickAt = (i) => {
    // Set active bed first - this will trigger other beds to deselect synchronously
    flushSync(() => {
      setActiveBed(bedIndex);
    });
    
    // If a plant is selected from the palette
    if (selectedCode) {
      // If clicking on a cell that already has the same plant, select it instead of replacing
      if (bed[i] === selectedCode) {
        setSelectedIndices(new Set([i]));
      } else {
        // Place plant if it's a different plant or empty cell
        const next = bed.slice();
        next[i] = selectedCode;
        onChange(next);
        setSelectedIndices(new Set());
      }
    } else {
      // No plant selected from palette - just select this cell
      setSelectedIndices(new Set([i]));
    }
  }

  const handleDoubleClickAt = (i) => {
    // Set active bed first - this will trigger other beds to deselect synchronously
    flushSync(() => {
      setActiveBed(bedIndex);
    });
    
    const plantCode = bed[i]
    if (!plantCode) {
      setSelectedIndices(new Set());
      return
    }
    // BFS to find all orthogonally connected same-plant cells
    const visited = new Set()
    const queue = [i]
    visited.add(i)
    while (queue.length > 0) {
      const curr = queue.shift()
      const row = Math.floor(curr / bedCols)
      const col = curr % bedCols
      // Check 4 directions
      const neighbors = [
        [row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]
      ]
      for (const [r, c] of neighbors) {
        if (r < 0 || r >= bedRows || c < 0 || c >= bedCols) continue
        const idx = r * bedCols + c
        if (visited.has(idx)) continue
        if (bed[idx] === plantCode) {
          visited.add(idx)
          queue.push(idx)
        }
      }
    }
    setSelectedIndices(visited);
  }

  const handleMouseDownAt = (i) => {
    if (selectedCode) {
      setIsDragging(true)
      const next = bed.slice()
      next[i] = selectedCode
      onChange(next)
    }
  }

  const handleMouseEnterAt = (i) => {
    if (isDragging && selectedCode) {
      const next = bed.slice()
      next[i] = selectedCode
      onChange(next)
    }
  }

  useEffect(() => {
    const handleMouseUp = () => {
      setIsDragging(false)
    }
    window.addEventListener('mouseup', handleMouseUp)
    return () => window.removeEventListener('mouseup', handleMouseUp)
  }, [])

  const handleDelete = () => {
    if (selectedIndices.size === 0) return
    const next = bed.slice()
    selectedIndices.forEach(i => { next[i] = null })
    onChange(next)
    setSelectedIndices(new Set())
  }

  // Delete key listener
  useEffect(() => {
    const handler = (e) => {
      if (e.key === 'Delete' && selectedIndices.size > 0) {
        handleDelete()
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [selectedIndices, bed])

  // Click-away deselection - handle clicks on card or card-body backgrounds
  const handleCardClick = (e) => {
    // Stop propagation to prevent container-level deselection
    e.stopPropagation()
    // Deselect if clicking directly on card or card-body (not on children)
    if (e.target === e.currentTarget) {
      setSelectedIndices(new Set())
    }
  }

  const handleBedClick = (e) => {
    // Stop propagation to prevent container-level deselection
    e.stopPropagation()
    // Deselect if clicking on the card-body background
    if (e.currentTarget === e.target) {
      setSelectedIndices(new Set())
    }
  }

  // Check if any selected indices contain plants
  const hasSelectedPlants = Array.from(selectedIndices).some(i => bed[i] !== null)

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
            {bed.map((code, i) => {
              const plant = plants.find(p => p.code === code)
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
