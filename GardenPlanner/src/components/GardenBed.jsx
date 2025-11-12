import React, { useEffect, useRef, useState, useMemo } from 'react'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { useSelection } from '../hooks/useSelection'
import { PLANTS } from '../data'

function Cell({ plant, onDrop, onClick, onDoubleClick, onMouseDown, onMouseEnter, selected, cellSize, isDimmed, showSprawlFallback }) {
  const scale = useMemo(() => cellSize / 68, [cellSize])
  const fs = (v) => Math.max(7, Math.round(v * scale))
  const gapPx = (v) => Math.max(1, Math.round(v * scale))
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

  // Render multiple icons based on sqftSpacing (only for non-dimmed cells)
  const renderPlantIcons = () => {
    // Fallback: show faded single icon for incomplete sprawling plant placement
    if (plant && showSprawlFallback) {
      return (
        <>
          <div style={{fontSize: fs(26), lineHeight: 1, opacity: 0.55}}>{plant.icon}</div>
          <div className="small text-center" style={{lineHeight: 1.1, fontSize: fs(10), opacity: 0.55}}>{plant.name}</div>
        </>
      )
    }

    if (!plant || isDimmed) return null
    
    const spacing = plant.sqftSpacing || 1
    
    // For single plant per cell
    if (spacing === 1) {
      return (
        <>
          <div style={{fontSize: fs(26), lineHeight: 1}}>{plant.icon}</div>
          <div className="small text-center" style={{lineHeight: 1.1, fontSize: fs(10)}}>{plant.name}</div>
        </>
      )
    }
    
    // For 2 plants per cell - side by side
    if (spacing === 2) {
      return (
        <>
          <div style={{display: 'flex', gap: gapPx(2), fontSize: fs(18)}}>
            {plant.icon}{plant.icon}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: fs(9)}}>{plant.name}</div>
        </>
      )
    }
    
    // For 4 plants per cell - 2x2 grid
    if (spacing === 4) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: gapPx(1), fontSize: fs(16)}}>
            {Array(4).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: fs(8)}}>{plant.name}</div>
        </>
      )
    }
    
    // For 8 plants per cell - 2x4 grid
    if (spacing === 8) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: gapPx(1), fontSize: fs(11)}}>
            {Array(8).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: fs(7)}}>{plant.name}</div>
        </>
      )
    }
    
    // For 9 plants per cell - 3x3 grid
    if (spacing === 9) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: gapPx(1), fontSize: fs(12)}}>
            {Array(9).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: fs(7)}}>{plant.name}</div>
        </>
      )
    }
    
    // For 16 plants per cell - 4x4 grid
    if (spacing === 16) {
      return (
        <>
          <div style={{display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: gapPx(1), fontSize: fs(10)}}>
            {Array(16).fill(plant.icon).map((icon, i) => <span key={i}>{icon}</span>)}
          </div>
          <div className="small text-center" style={{lineHeight: 1, fontSize: fs(7)}}>{plant.name}</div>
        </>
      )
    }
    
    // Default fallback
    return (
      <>
        <div style={{fontSize: fs(26), lineHeight: 1}}>{plant.icon}</div>
        <div className="small text-center" style={{lineHeight: 1.1, fontSize: fs(10)}}>{plant.name}</div>
      </>
    )
  }

  return (
    <div className={`border rounded-3 d-flex flex-column align-items-center justify-content-center position-relative`} 
         style={{
           width: cellSize, 
           height: cellSize, 
           background: 'var(--cell-bg)', 
           borderStyle: 'dashed', 
           cursor: 'pointer', 
           userSelect: 'none',
           opacity: isDimmed ? 0.7 : 1,
         }}
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

export function GardenBed({ bedIndex, cellSize = 68 }) {
  const { garden, updateCell, updateCells, clearCells, updateBed, removeBed } = useGardenOperations()
  const { selectedPlant, selection, setSelection, setActiveBed, activeBed, setSelectedPlant } = useSelection()
  const [isDragging, setIsDragging] = useState(false)
  const [isMouseDown, setIsMouseDown] = useState(false)
  const [justFinishedDrag, setJustFinishedDrag] = useState(false)
  const [dragSelectionStart, setDragSelectionStart] = useState(null)
  const [dragSelectionCurrent, setDragSelectionCurrent] = useState(new Set())
  const gridRef = useRef(null)

  const bed = garden.getBed(bedIndex)
  useEffect(() => {
    // no-op: header controls handle renaming and light toggling
  }, [bed])
  const bedRows = bed.rows
  const bedCols = bed.cols
  const lightLevel = bed.lightLevel

  // Local selection state for this bed
  const isThisBedActive = activeBed === bedIndex
  const isThisBedSelected = selection.bedIndex === bedIndex
  // When drag-selecting, show both committed selection and current drag selection
  const selectedIndices = isThisBedSelected 
    ? (isDragging && !selectedPlant ? dragSelectionCurrent : selection.cellIndices)
    : new Set()

  const handleClickAt = (i) => {
    // Ignore clicks immediately after drag ends to prevent accidental selection
    if (justFinishedDrag) {
      return
    }
    
    const currentCell = bed.getCell(i)
    // If a palette plant is selected, plant without selecting the cell
    if (selectedPlant) {
      const currentCell = bed.getCell(i)
      if (currentCell !== selectedPlant) {
        updateCell(bedIndex, i, selectedPlant)
      }
      return
    }

    // Only set cell selection when no palette plant is active
    setSelection(bedIndex, new Set([i]))
  }

  const handleDoubleClickAt = (i) => {
    // Ignore double-clicks immediately after drag ends
    if (justFinishedDrag) {
      return
    }
    
    // Do not change activeBed on double-click; only adjust selection
    
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
    setIsMouseDown(true)
    if (selectedPlant) {
      // Planting mode: start drag-to-plant
      setIsDragging(true)
      updateCell(bedIndex, i, selectedPlant)
    } else {
      // Selection mode: start drag-to-select
      setIsDragging(true)
      setDragSelectionStart(i)
      setDragSelectionCurrent(new Set([i]))
      // Immediately set this bed as the selection target
      setSelection(bedIndex, new Set([i]))
    }
  }

  const handleMouseEnterAt = (i) => {
    if (isDragging && selectedPlant) {
      // Planting mode: plant on hover
      updateCell(bedIndex, i, selectedPlant)
    } else if (isDragging && !selectedPlant && dragSelectionStart !== null) {
      // Selection mode: expand selection rectangle
      const startRow = Math.floor(dragSelectionStart / bedCols)
      const startCol = dragSelectionStart % bedCols
      const currentRow = Math.floor(i / bedCols)
      const currentCol = i % bedCols
      
      const minRow = Math.min(startRow, currentRow)
      const maxRow = Math.max(startRow, currentRow)
      const minCol = Math.min(startCol, currentCol)
      const maxCol = Math.max(startCol, currentCol)
      
      const newSelection = new Set()
      for (let r = minRow; r <= maxRow; r++) {
        for (let c = minCol; c <= maxCol; c++) {
          newSelection.add(r * bedCols + c)
        }
      }
      setDragSelectionCurrent(newSelection)
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
    const handleMouseUp = () => {
      const wasDragging = isDragging
      
      // Commit drag selection if we were selecting (not planting)
      if (wasDragging && !selectedPlant && dragSelectionCurrent.size > 0) {
        setSelection(bedIndex, dragSelectionCurrent)
      }
      
      setIsDragging(false)
      setIsMouseDown(false)
      setDragSelectionStart(null)
      setDragSelectionCurrent(new Set())
      
      // If we were dragging, set a flag to ignore the next click event
      if (wasDragging) {
        setJustFinishedDrag(true)
        // Clear the flag after a short delay (after click event has fired)
        setTimeout(() => setJustFinishedDrag(false), 10)
      }
    }
    window.addEventListener('mouseup', handleMouseUp)
    return () => window.removeEventListener('mouseup', handleMouseUp)
  }, [isDragging, selectedPlant, dragSelectionCurrent, bedIndex, setSelection])

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
    // Always stop propagation first to prevent event bubbling
    e.stopPropagation()
    
    // Don't handle click events during or immediately after drag operations
    if (isMouseDown || isDragging || justFinishedDrag) {
      return
    }
    
    if (e.target === e.currentTarget) {
      // Clicking bed card background clears cell selection and deselects this bed table
      setSelection(bedIndex, new Set())
      setActiveBed(null)
    }
  }

  const handleBedClick = (e) => {
    // Always stop propagation first to prevent event bubbling
    e.stopPropagation()
    
    // Don't handle click events during or immediately after drag operations
    if (isMouseDown || isDragging || justFinishedDrag) {
      return
    }
    
    if (e.currentTarget === e.target) {
      // Clicking grid background clears cell selection and deselects this bed table
      setSelection(bedIndex, new Set())
      setActiveBed(null)
    }
  }

  // Check if any selected cells have plants
  const hasSelectedPlants = Array.from(selectedIndices).some(i => bed.getCell(i) !== null)

  // Calculate card width based on bed dimensions
  const gap = 8
  const gridWidth = bedCols * cellSize + (bedCols - 1) * gap
  const gridHeight = bedRows * cellSize + (bedRows - 1) * gap
  const cardPadding = 24 // 12px padding on each side
  const cardWidth = gridWidth + cardPadding

  // Compute contiguous groups for sprawling crops to draw enlarged plant visuals
  const sprawlingOverlays = useMemo(() => {
    const overlays = []
    const cells = bed.cells
    const visited = new Set()
    const codeToPlant = new Map(PLANTS.map(p => [p.code, p]))

    const idxToRowCol = (idx) => ({ row: Math.floor(idx / bedCols), col: idx % bedCols })
    const inBounds = (r, c) => r >= 0 && r < bedRows && c >= 0 && c < bedCols
    const idxAt = (r, c) => r * bedCols + c

    for (let i = 0; i < cells.length; i++) {
      const code = cells[i]
      if (!code || visited.has(i)) continue
      const plant = codeToPlant.get(code)
      if (!plant || !(plant.cellsRequired && plant.cellsRequired > 1)) continue

      // BFS to collect contiguous group of the same plant code
      const queue = [i]
      const group = []
      visited.add(i)
      while (queue.length) {
        const idx = queue.shift()
        group.push(idx)
        const { row, col } = idxToRowCol(idx)
        const neighbors = [
          [row-1, col],
          [row+1, col],
          [row, col-1],
          [row, col+1],
        ]
        for (const [nr, nc] of neighbors) {
          if (!inBounds(nr, nc)) continue
          const nIdx = idxAt(nr, nc)
          if (!visited.has(nIdx) && cells[nIdx] === code) {
            visited.add(nIdx)
            queue.push(nIdx)
          }
        }
      }

      // Compute bounding box for this group
      let minR = bedRows, maxR = -1, minC = bedCols, maxC = -1
      group.forEach(idx => {
        const { row, col } = idxToRowCol(idx)
        minR = Math.min(minR, row)
        maxR = Math.max(maxR, row)
        minC = Math.min(minC, col)
        maxC = Math.max(maxC, col)
      })

      const spanRows = maxR - minR + 1
      const spanCols = maxC - minC + 1
      const groupSize = group.length // in sq ft
      const requiredPerPlant = plant.cellsRequired
      const plantCount = Math.max(1, Math.round(groupSize / requiredPerPlant))

      // Divide the group into individual plant instances
      // Each plant instance should occupy requiredPerPlant cells
      // STRATEGY: Try horizontal placements first (left-to-right, top-to-bottom),
      // then vertical placements to fill remaining gaps
      const groupSet = new Set(group)
      const plantInstances = []
      const instanceVisited = new Set()
      
      const isSquareShape = requiredPerPlant === 4 || requiredPerPlant === 9
      
      // Helper: Try to claim a shape starting from an index
      const tryClaimShape = (startIdx, preferHorizontal) => {
        if (instanceVisited.has(startIdx)) return null
        
        const { row: startRow, col: startCol } = idxToRowCol(startIdx)
        const instanceCells = []
        
        // Determine shape dimensions based on requiredPerPlant and orientation preference
        let shapeRows, shapeCols
        if (isSquareShape) {
          // Square shapes don't need rotation (2x2 or 3x3)
          const side = Math.sqrt(requiredPerPlant)
          shapeRows = shapeCols = side
        } else if (requiredPerPlant === 2) {
          // 2-cell shapes: prefer 1x2 (horizontal) or 2x1 (vertical)
          if (preferHorizontal) {
            shapeRows = 1
            shapeCols = 2
          } else {
            shapeRows = 2
            shapeCols = 1
          }
        } else if (requiredPerPlant === 8) {
          // 8-cell shapes: prefer 2x4 (horizontal) or 4x2 (vertical)
          if (preferHorizontal) {
            shapeRows = 2
            shapeCols = 4
          } else {
            shapeRows = 4
            shapeCols = 2
          }
        } else {
          // Fallback: try to approximate a rectangular shape
          const side = Math.sqrt(requiredPerPlant)
          if (preferHorizontal) {
            shapeRows = Math.floor(side)
            shapeCols = Math.ceil(requiredPerPlant / shapeRows)
          } else {
            shapeCols = Math.floor(side)
            shapeRows = Math.ceil(requiredPerPlant / shapeCols)
          }
        }
        
        // Try to claim the shape starting from startIdx
        let canClaim = true
        for (let rOffset = 0; rOffset < shapeRows && canClaim; rOffset++) {
          for (let cOffset = 0; cOffset < shapeCols && canClaim; cOffset++) {
            const r = startRow + rOffset
            const c = startCol + cOffset
            if (!inBounds(r, c)) {
              canClaim = false
              break
            }
            const idx = idxAt(r, c)
            if (!groupSet.has(idx) || instanceVisited.has(idx)) {
              canClaim = false
              break
            }
          }
        }
        
        if (!canClaim) return null
        
        // Claim the shape
        for (let rOffset = 0; rOffset < shapeRows; rOffset++) {
          for (let cOffset = 0; cOffset < shapeCols; cOffset++) {
            const idx = idxAt(startRow + rOffset, startCol + cOffset)
            instanceCells.push(idx)
            instanceVisited.add(idx)
          }
        }
        
        return instanceCells
      }
      
      // PASS 1: Try horizontal placements (scan top-to-bottom, left-to-right)
      if (!isSquareShape) {
        for (let r = minR; r <= maxR; r++) {
          for (let c = minC; c <= maxC; c++) {
            const idx = idxAt(r, c)
            if (!groupSet.has(idx) || instanceVisited.has(idx)) continue
            
            const instanceCells = tryClaimShape(idx, true) // preferHorizontal
            if (instanceCells) {
              // Calculate center and bounds for this instance
              let iMinR = bedRows, iMaxR = -1, iMinC = bedCols, iMaxC = -1
              instanceCells.forEach(idx => {
                const { row, col } = idxToRowCol(idx)
                iMinR = Math.min(iMinR, row)
                iMaxR = Math.max(iMaxR, row)
                iMinC = Math.min(iMinC, col)
                iMaxC = Math.max(iMaxC, col)
              })
              
              const iSpanRows = iMaxR - iMinR + 1
              const iSpanCols = iMaxC - iMinC + 1
              const iCenterLeft = iMinC * (cellSize + gap) + (iSpanCols * cellSize + (iSpanCols - 1) * gap) / 2
              const iCenterTop = iMinR * (cellSize + gap) + (iSpanRows * cellSize + (iSpanRows - 1) * gap) / 2
              const iIconSize = Math.min(cellSize * 1.8, Math.max(cellSize * 0.7, Math.sqrt(instanceCells.length) * cellSize * 0.55))
              
              const iBoundingBox = {
                left: iMinC * (cellSize + gap),
                top: iMinR * (cellSize + gap),
                width: iSpanCols * cellSize + (iSpanCols - 1) * gap,
                height: iSpanRows * cellSize + (iSpanRows - 1) * gap,
              }
              
              plantInstances.push({
                cells: instanceCells,
                centerLeft: iCenterLeft,
                centerTop: iCenterTop,
                iconSize: iIconSize,
                boundingBox: iBoundingBox,
              })
            }
          }
        }
      }
      
      // PASS 2: Fill gaps (square shapes or vertical fills)
      for (let r = minR; r <= maxR; r++) {
        for (let c = minC; c <= maxC; c++) {
          const idx = idxAt(r, c)
          if (!groupSet.has(idx) || instanceVisited.has(idx)) continue
          
          const instanceCells = tryClaimShape(idx, isSquareShape ? true : false) // vertical for non-square
          if (instanceCells) {
            // Calculate center and bounds for this instance
            let iMinR = bedRows, iMaxR = -1, iMinC = bedCols, iMaxC = -1
            instanceCells.forEach(idx => {
              const { row, col } = idxToRowCol(idx)
              iMinR = Math.min(iMinR, row)
              iMaxR = Math.max(iMaxR, row)
              iMinC = Math.min(iMinC, col)
              iMaxC = Math.max(iMaxC, col)
            })
            
            const iSpanRows = iMaxR - iMinR + 1
            const iSpanCols = iMaxC - iMinC + 1
            const iCenterLeft = iMinC * (cellSize + gap) + (iSpanCols * cellSize + (iSpanCols - 1) * gap) / 2
            const iCenterTop = iMinR * (cellSize + gap) + (iSpanRows * cellSize + (iSpanRows - 1) * gap) / 2
            const iIconSize = Math.min(cellSize * 1.8, Math.max(cellSize * 0.7, Math.sqrt(instanceCells.length) * cellSize * 0.55))
            
            const iBoundingBox = {
              left: iMinC * (cellSize + gap),
              top: iMinR * (cellSize + gap),
              width: iSpanCols * cellSize + (iSpanCols - 1) * gap,
              height: iSpanRows * cellSize + (iSpanRows - 1) * gap,
            }
            
            plantInstances.push({
              cells: instanceCells,
              centerLeft: iCenterLeft,
              centerTop: iCenterTop,
              iconSize: iIconSize,
              boundingBox: iBoundingBox,
            })
          }
        }
      }

      overlays.push({
        code,
        plant,
        plantCount,
        requiredPerPlant,
        groupSize,
        cellIndices: group, // Store indices to dim underlying cells
        plantInstances, // Individual plant icons to render
      })
    }

    return overlays
  }, [bed.cells, bedCols, bedRows, cellSize])

  // Create set of indices that are part of sprawling groups (to dim them)
  const sprawlingCellIndices = useMemo(() => {
    const indices = new Set()
    sprawlingOverlays.forEach(ov => {
      ov.cellIndices.forEach(idx => indices.add(idx))
    })
    return indices
  }, [sprawlingOverlays])

  const isSelectedBed = activeBed === bedIndex

  return (
    <div className="d-flex gap-3">
      <div
        className={`card ${isSelectedBed ? 'bg-primary-subtle border-primary' : ''}`}
        style={{
          width: cardWidth,
          minWidth: cardWidth,
          maxWidth: cardWidth,
          height: 'fit-content',
          position: 'relative',
          transition: 'background-color 0.2s ease, border-color 0.2s ease'
        }}
        data-selected={isSelectedBed ? 'true' : 'false'}
        onClick={handleCardClick}
      >
        <div className="card-header d-flex justify-content-between align-items-center"
             onClick={(e) => {
               e.stopPropagation()
               setActiveBed(bedIndex)
             }}>
          <div className="d-flex align-items-center gap-2">
            <span className="fw-semibold">{(bed.name && bed.name.trim()) ? bed.name : `Bed ${bedIndex + 1}`}</span>
            <span aria-label={bed.lightLevel === 'high' ? 'High light' : 'Low light'} title={bed.lightLevel === 'high' ? 'High light' : 'Low light'}>
              {bed.lightLevel === 'high' ? '☀️' : '☁️'}
            </span>
          </div>
          <span style={{minWidth: 120, display: 'inline-block', textAlign: 'right'}}>
            <div className="d-flex align-items-center justify-content-end gap-2">
              <button
                className="btn btn-sm btn-danger"
                style={{minWidth: 90, opacity: selectedIndices.size > 0 && hasSelectedPlants ? 1 : 0.3, pointerEvents: selectedIndices.size > 0 && hasSelectedPlants ? 'auto' : 'none', transition: 'opacity 0.2s'}}
                onClick={(e) => {
                  if (selectedIndices.size > 0 && hasSelectedPlants) {
                    e.stopPropagation();
                    handleDelete();
                  }
                }}
                title="Delete selected cells"
              >
                Delete ({selectedIndices.size})
              </button>
            </div>
          </span>
        </div>
        <div className="card-body" onClick={handleBedClick} style={{ padding: 12, display: 'flex', alignItems: 'flex-start', justifyContent: 'center' }}>
          <div
            ref={gridRef}
            className="d-grid gap-2"
            style={{
              gridTemplateColumns: `repeat(${bedCols}, ${cellSize}px)`,
              gridTemplateRows: `repeat(${bedRows}, ${cellSize}px)`,
              width: gridWidth,
              minWidth: gridWidth,
              maxWidth: gridWidth,
              height: gridHeight,
              minHeight: gridHeight,
              maxHeight: gridHeight,
              position: 'relative',
            }}
            onClick={handleBedClick}
          >
            {(() => {
              // Build set of cells that have a rendered plant instance icon (part of claimed overlay shape)
              const instanceIconCells = new Set()
              sprawlingOverlays.forEach(ov => {
                ov.plantInstances.forEach(inst => {
                  inst.cells.forEach(idx => instanceIconCells.add(idx))
                })
              })
              return bed.cells.map((code, i) => {
                const plant = PLANTS.find(p => p.code === code)
                const isDimmed = sprawlingCellIndices.has(i)
                const showSprawlFallback = !!(plant && plant.cellsRequired && plant.cellsRequired > 1 && isDimmed && !instanceIconCells.has(i))
                return (
                  <Cell
                    key={i}
                    plant={plant}
                    selected={selectedIndices.has(i)}
                    cellSize={cellSize}
                    isDimmed={isDimmed}
                    showSprawlFallback={showSprawlFallback}
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
              })
            })()}

            {/* Large plant icons for sprawling crops - render individual plant instances */}
            {sprawlingOverlays.map((ov, ovIdx) => (
              <React.Fragment key={`sprawl-group-${ovIdx}`}>
                {ov.plantInstances.map((instance, instIdx) => (
                  <React.Fragment key={`sprawl-${ovIdx}-${instIdx}`}>
                    {/* Subtle grouping border around this plant instance */}
                    <div style={{
                      position: 'absolute',
                      left: instance.boundingBox.left,
                      top: instance.boundingBox.top,
                      width: instance.boundingBox.width,
                      height: instance.boundingBox.height,
                      border: `2px solid ${ov.plant.color}`,
                      borderRadius: 8,
                      pointerEvents: 'none',
                      zIndex: 4,
                      opacity: 0.4,
                    }} />
                    
                    {/* Large plant icon */}
                    <div style={{
                         position: 'absolute',
                         left: instance.centerLeft,
                         top: instance.centerTop,
                         transform: 'translate(-50%, -50%)',
                         pointerEvents: 'none',
                         zIndex: 5,
                         display: 'flex',
                         flexDirection: 'column',
                         alignItems: 'center',
                         gap: 2,
                       }}
                    >
                      <div style={{
                        fontSize: instance.iconSize,
                        lineHeight: 1,
                        filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.2))',
                      }}>
                        {ov.plant.icon}
                      </div>
                      {/* Label matching single-cell plant style */}
                      <div className="small text-center" style={{
                        lineHeight: 1.1,
                        fontSize: Math.max(7, Math.round((instance.iconSize * 0.15) * (cellSize / 68)))
                      }}>
                        {ov.plant.name}
                      </div>
                    </div>
                  </React.Fragment>
                ))}
              </React.Fragment>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
