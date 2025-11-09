/**
 * Garden Generation Service - handles auto-generation logic
 */
import { Bed } from '../models/Bed'

export class GardenGenerationService {
  /**
   * Generate optimized garden layout
   * Integrates legacy algorithm: respects sqftSpacing, light levels, and fills all cells.
   */
  static generate(plants, beds, prioritizeLight = true) {
    // Derive grid parameters
    const bedCount = beds.length
    if (bedCount === 0) return []
    const bedRows = beds[0].rows
    const bedCols = beds[0].cols
    const cellsPerBed = bedRows * bedCols
    const totalCells = bedCount * cellsPerBed

    // Light levels from Bed models
    const lightLevels = beds.map(b => b.lightLevel || 'high')

    // If no plants, return original beds
    if (!plants || plants.length === 0) {
      return beds
    }

    // Calculate a weight based on sqftSpacing (legacy heuristic)
    const allocations = plants.map(p => {
      const cellsPerPlant = Math.max(1, Math.round(1 / (p.sqftSpacing || 1)))
      return { code: p.code, plant: p, cellsPerPlant }
    })

    const totalWeight = allocations.reduce((sum, a) => sum + a.cellsPerPlant, 0)
    let scaled = allocations.map(a => ({
      ...a,
      // Proportional to total garden space, min 2, max a single bed
      cellCount: Math.max(2, Math.min(cellsPerBed, Math.round((a.cellsPerPlant / totalWeight) * totalCells)))
    }))

    // Downscale if we exceeded available cells
    let allocated = scaled.reduce((s, a) => s + a.cellCount, 0)
    if (allocated > totalCells) {
      const factor = totalCells / allocated
      scaled = scaled.map(a => ({ ...a, cellCount: Math.max(2, Math.floor(a.cellCount * factor)) }))
    }

    // Sort large first for better packing
    scaled.sort((a, b) => b.cellCount - a.cellCount)

    // Build primitive cell arrays for placement
    const resultCells = beds.map(b => Array.from({ length: b.cells.length }, () => null))

    // Helper: try to place a rectangle cluster of approximately targetCells in a given bed
    const findBestCluster = (targetCells, bedIndex) => {
      const shapes = []
      for (let r = 1; r <= bedRows; r++) {
        for (let c = 1; c <= bedCols; c++) {
          const size = r * c
          if (size >= Math.max(2, Math.ceil(targetCells * 0.8)) && size <= Math.min(cellsPerBed, Math.ceil(targetCells * 1.2))) {
            const aspect = Math.max(r, c) / Math.min(r, c)
            const sizeScore = Math.abs(size - targetCells)
            const score = sizeScore * 10 + aspect
            shapes.push({ r, c, size, score })
          }
        }
      }
      shapes.sort((a, b) => a.score - b.score)

      const cells = resultCells[bedIndex]
      for (const shape of shapes) {
        for (let startR = 0; startR <= bedRows - shape.r; startR++) {
          for (let startC = 0; startC <= bedCols - shape.c; startC++) {
            let canPlace = true
            for (let rr = 0; rr < shape.r && canPlace; rr++) {
              for (let cc = 0; cc < shape.c && canPlace; cc++) {
                const idx = (startR + rr) * bedCols + (startC + cc)
                if (cells[idx] !== null) canPlace = false
              }
            }
            if (canPlace) {
              return { startR, startC, rows: shape.r, cols: shape.c }
            }
          }
        }
      }
      return null
    }

    // Place each plant as one contiguous cluster, preferring matching-light beds
    for (const a of scaled) {
      const plantLight = a.plant.lightLevel || 'high'
      // Build a bed order using preference scoring to satisfy fallback rules:
      // - In low-light beds, prefer medium over high when low isn't available
      // - In high-light beds, prefer medium over low when high isn't available
      const bedOrder = Array.from({ length: bedCount }, (_, i) => i)
        .sort((i, j) => this.getBedPreferenceScore(plantLight, lightLevels[i], prioritizeLight) - this.getBedPreferenceScore(plantLight, lightLevels[j], prioritizeLight))

      let placed = false
      for (const bi of bedOrder) {
        // Enough empty cells in this bed?
        const empty = resultCells[bi].filter(x => x === null).length
        if (empty < a.cellCount) continue
        const cluster = findBestCluster(a.cellCount, bi)
        if (cluster) {
          for (let rr = 0; rr < cluster.rows; rr++) {
            for (let cc = 0; cc < cluster.cols; cc++) {
              const idx = (cluster.startR + rr) * bedCols + (cluster.startC + cc)
              resultCells[bi][idx] = a.code
            }
          }
          placed = true
          break
        }
      }
      if (!placed) {
        // Could not place as a single cluster; try to place greedily cell-by-cell
        for (let bi = 0; bi < bedCount && a.cellCount > 0; bi++) {
          for (let idx = 0; idx < resultCells[bi].length && a.cellCount > 0; idx++) {
            if (resultCells[bi][idx] === null) {
              resultCells[bi][idx] = a.code
              a.cellCount--
            }
          }
        }
      }
    }

    // Fill remaining nulls by extending adjacent groups within each bed
    for (let b = 0; b < bedCount; b++) {
      const cells = resultCells[b]
      for (let i = 0; i < cells.length; i++) {
        if (cells[i] === null) {
          const row = Math.floor(i / bedCols)
          const col = i % bedCols
          const neighbors = []
          if (row > 0) neighbors.push(cells[(row - 1) * bedCols + col])
          if (row < bedRows - 1) neighbors.push(cells[(row + 1) * bedCols + col])
          if (col > 0) neighbors.push(cells[row * bedCols + (col - 1)])
          if (col < bedCols - 1) neighbors.push(cells[row * bedCols + (col + 1)])
          const valid = neighbors.filter(n => n !== null)
          if (valid.length > 0) {
            const counts = {}
            valid.forEach(n => counts[n] = (counts[n] || 0) + 1)
            const mostCommon = Object.entries(counts).sort((x, y) => y[1] - x[1])[0][0]
            cells[i] = mostCommon
          }
        }
      }
    }

    // Convert back to Bed instances
    return beds.map((b, i) => new Bed(b.rows, b.cols, b.lightLevel, resultCells[i]))
  }

  /**
   * Check if plant light requirement is compatible with bed light level
   */
  static isLightCompatible(plantLight, bedLight) {
    const levels = { low: 1, medium: 2, high: 3 }
    const plantLevel = levels[plantLight] || 2
    const bedLevel = levels[bedLight] || 3
    
    // Allow plants to be in same or higher light
    return bedLevel >= plantLevel
  }

  /**
   * Returns a numeric score for how suitable a bed light level is for a given plant.
   * Lower is better. Implements requested fallback preferences:
   *  - Low bed: low best (0), then medium (1), then high (2)
   *  - High bed: high best (0), then medium (1), then low (2)
   *  - Medium bed: medium best (0), low and high equal secondary (1)
   * If prioritizeLight=false, all scores are equal (0) to ignore light preferences.
   */
  static getBedPreferenceScore(plantLight, bedLight, prioritizeLight = true) {
    if (!prioritizeLight) return 0

    const pl = (plantLight || 'medium').toLowerCase()
    const bl = (bedLight || 'high').toLowerCase()

    if (bl === 'low') {
      if (pl === 'low') return 0
      if (pl === 'medium') return 1
      return 2 // high
    }
    if (bl === 'high') {
      if (pl === 'high') return 0
      if (pl === 'medium') return 1
      return 2 // low
    }
    // medium bed
    if (pl === 'medium') return 0
    return 1 // low or high are equally acceptable second choices
  }

  /**
   * Find best placement for a plant group (prefer square-ish shapes)
   */
  static findBestPlacement(cells, rows, cols, plantCode, count, startIndex) {
    // Find available positions
    const available = cells
      .map((cell, i) => cell === null ? i : -1)
      .filter(i => i !== -1)

    if (available.length < count) {
      console.warn(`Not enough space for ${plantCode}`)
      return available.slice(0, count)
    }

    // For single cell, just take first available
    if (count === 1) {
      return [available[0]]
    }

    // Try to find best square-ish arrangement
    const bestShape = this.findSquareShape(count)
    const positions = this.findContiguousBlock(
      available,
      rows,
      cols,
      bestShape.rows,
      bestShape.cols
    )

    return positions.slice(0, count)
  }

  /**
   * Find most square-like dimensions for given count
   */
  static findSquareShape(count) {
    const sqrt = Math.sqrt(count)
    let bestRows = Math.floor(sqrt)
    let bestCols = Math.ceil(count / bestRows)
    
    // Adjust to ensure rows * cols >= count
    while (bestRows * bestCols < count) {
      bestCols++
    }

    return { rows: bestRows, cols: bestCols }
  }

  /**
   * Find contiguous block of cells
   */
  static findContiguousBlock(available, gridRows, gridCols, targetRows, targetCols) {
    // Try to find a rectangular block
    for (let startRow = 0; startRow <= gridRows - targetRows; startRow++) {
      for (let startCol = 0; startCol <= gridCols - targetCols; startCol++) {
        const block = []
        let valid = true

        for (let r = 0; r < targetRows && valid; r++) {
          for (let c = 0; c < targetCols && valid; c++) {
            const index = (startRow + r) * gridCols + (startCol + c)
            if (available.includes(index)) {
              block.push(index)
            } else {
              valid = false
            }
          }
        }

        if (valid && block.length >= targetRows * targetCols) {
          return block
        }
      }
    }

    // Fallback: return available cells in order
    return available
  }
}
