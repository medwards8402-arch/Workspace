import React, { useEffect, useRef, useState } from 'react'

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

  return (
    <div className={`border rounded-3 d-flex flex-column align-items-center justify-content-center position-relative`} 
         style={{width: 68, height: 68, background: 'var(--cell-bg)', borderStyle: 'dashed', cursor: 'pointer'}}
         onDragOver={e => { e.preventDefault(); e.dataTransfer.dropEffect='copy' }}
         onDrop={onDrop}
         onClick={handleClick}
         onDoubleClick={handleDoubleClick}
         onMouseDown={handleMouseDown}
         onMouseEnter={handleMouseEnter}>
      {plant && <>
        <div style={{fontSize: 26, lineHeight: 1}}>{plant.icon}</div>
        <div className="small text-center" style={{lineHeight: 1.1}}>{plant.name}</div>
      </>}
      {selected && <div className="position-absolute w-100 h-100 rounded-3" style={{outline: '2px solid var(--bs-primary)', outlineOffset: 2}} />}
    </div>
  )
}

export function GardenBed({ bedIndex, bed, onChange, plants, selectedCode, bedRows, bedCols, deselectTrigger }) {
  const [selectedIndices, setSelectedIndices] = useState(new Set())
  const [isDragging, setIsDragging] = useState(false)
  const gridRef = useRef(null)

  useEffect(() => { setSelectedIndices(new Set()) }, [bed])

  // Deselect when triggered from parent (e.g., clicking outside)
  useEffect(() => {
    if (deselectTrigger > 0) {
      setSelectedIndices(new Set())
    }
  }, [deselectTrigger])

  const handleDropAt = (i, code) => {
    const next = bed.slice()
    next[i] = code
    onChange(next)
    setSelectedIndices(new Set())
  }

  const handleClickAt = (i) => {
    if (selectedCode) {
      // Place plant if one is selected
      const next = bed.slice()
      next[i] = selectedCode
      onChange(next)
      setSelectedIndices(new Set())
    } else {
      // Select this cell
      setSelectedIndices(new Set([i]))
    }
  }

  const handleDoubleClickAt = (i) => {
    const plantCode = bed[i]
    if (!plantCode) {
      setSelectedIndices(new Set())
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
    setSelectedIndices(visited)
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
    // Deselect if clicking directly on card or card-body (not on children)
    if (e.target === e.currentTarget) {
      setSelectedIndices(new Set())
    }
  }

  const handleBedClick = (e) => {
    // Deselect if clicking on the card-body background
    if (e.currentTarget === e.target) {
      setSelectedIndices(new Set())
    }
  }

  // Check if any selected indices contain plants
  const hasSelectedPlants = Array.from(selectedIndices).some(i => bed[i] !== null)

  return (
    <div className="card" onClick={handleCardClick}>
      <div className="card-header d-flex justify-content-between align-items-center" onClick={handleCardClick}>
        <span>Bed {bedIndex + 1}</span>
        {selectedIndices.size > 0 && hasSelectedPlants && (
          <button className="btn btn-sm btn-danger" onClick={(e) => { e.stopPropagation(); handleDelete(); }}>
            Delete ({selectedIndices.size})
          </button>
        )}
      </div>
      <div className="card-body d-flex justify-content-center" onClick={handleBedClick} style={{padding: 12, minWidth: 'fit-content'}}>
        <div ref={gridRef} className="d-grid gap-2" style={{gridTemplateColumns: `repeat(${bedCols}, 68px)`}} onClick={handleBedClick}>
          {bed.map((code, i) => {
            const plant = plants.find(p => p.code === code)
            return (
              <Cell key={i} plant={plant} selected={selectedIndices.has(i)}
                onDrop={(e) => { e.preventDefault(); const c = e.dataTransfer.getData('text/plain'); if (c) handleDropAt(i,c) }}
                onClick={() => handleClickAt(i)}
                onDoubleClick={() => handleDoubleClickAt(i)}
                onMouseDown={() => handleMouseDownAt(i)}
                onMouseEnter={() => handleMouseEnterAt(i)} />
            )
          })}
        </div>
      </div>
    </div>
  )
}
