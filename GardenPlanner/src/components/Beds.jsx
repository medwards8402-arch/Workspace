import React, { useEffect, useMemo, useRef, useState } from 'react'
import { GardenBed } from './GardenBed'
// No header-level actions here; add/remove is handled in App header

export function Beds({ beds }) {
  const containerRef = useRef(null)
  const [containerWidth, setContainerWidth] = useState(0)
  // No hooks needed here beyond layout sizing

  useEffect(() => {
    if (!containerRef.current) return
    const ro = new ResizeObserver(entries => {
      for (const entry of entries) {
        const cw = entry.contentRect?.width || entry.target.clientWidth
        setContainerWidth(cw)
      }
    })
    ro.observe(containerRef.current)
    return () => ro.disconnect()
  }, [])

  const cellSize = useMemo(() => {
    const DEFAULT_CELL = 68
    const GAP = 8
    const PADDING = 24
    if (!containerWidth || beds.length === 0) return DEFAULT_CELL
    const maxCols = Math.max(...beds.map(b => b.cols || 0))
    if (maxCols <= 0) return DEFAULT_CELL
    const available = Math.max(0, containerWidth - PADDING)
    const neededAtDefault = maxCols * DEFAULT_CELL + (maxCols - 1) * GAP
    if (neededAtDefault <= available) return DEFAULT_CELL
    const fitted = Math.floor((available - (maxCols - 1) * GAP) / maxCols)
    // Clamp to a sensible minimum to keep UI legible
    return Math.max(40, Math.min(DEFAULT_CELL, fitted))
  }, [containerWidth, beds])

  return (
    <div ref={containerRef} className="d-flex flex-wrap gap-3">
      {beds.map((bed, idx) => (
        <GardenBed key={idx} bedIndex={idx} cellSize={cellSize} />
      ))}
    </div>
  )
}
