/**
 * Garden Generation Service - handles auto-generation logic
 */
import { Bed } from '../models/Bed'

export class GardenGenerationService {
  /**
   * Generate optimized garden layout
   * Each plant appears as a single contiguous group across the entire garden.
   * Prefers rectangular shapes (2x2, 4x4, 4x2).
   */
  static generate(plants, beds, prioritizeLight = true) {
    const bedCount = beds.length
    if (bedCount === 0) return []
    
    // Calculate total available space
    const totalCells = beds.reduce((sum, bed) => sum + bed.rows * bed.cols, 0)

    // If no plants, return original beds
    if (!plants || plants.length === 0) {
      return beds
    }

    // Step 1: Sort beds by light level (low, medium, high)
    const bedLightOrder = { low: 0, medium: 1, high: 2 }
    const sortedBeds = beds.map((bed, i) => ({ bed, bedIndex: i }))
      .sort((a, b) => bedLightOrder[a.bed.lightLevel || 'high'] - bedLightOrder[b.bed.lightLevel || 'high'])

    // Step 2: Calculate cell allocation per plant to fill ALL beds
    // Goal: More uniform plant quantities, allowing diverse planting across beds
    const allocations = plants.map(p => {
      const cellsPerPlant = Math.max(1, Math.round(1 / (p.sqftSpacing || 1)))
      return { code: p.code, plant: p, cellsPerPlant }
    })

    // Use sqrt of cellsPerPlant to reduce disparity while still respecting spacing
    // Also enforce stricter caps for more uniform distribution
    const avgCellsPerPlant = totalCells / plants.length
    const maxCellsPerPlant = Math.floor(avgCellsPerPlant * 1.8) // Max 1.8x average
    const minCellsPerPlant = Math.max(4, Math.floor(avgCellsPerPlant * 0.5)) // Min 0.5x average
    
    const totalWeight = allocations.reduce((sum, a) => sum + Math.sqrt(a.cellsPerPlant), 0)
    let plantAllocations = allocations.map(a => {
      const weight = Math.sqrt(a.cellsPerPlant)
      const allocation = Math.round((weight / totalWeight) * totalCells)
      return {
        ...a,
        cellCount: Math.max(minCellsPerPlant, Math.min(allocation, maxCellsPerPlant))
      }
    })

    // Scale allocations to EXACTLY match totalCells (ensure all beds are filled)
    let allocated = plantAllocations.reduce((s, a) => s + a.cellCount, 0)
    
    if (allocated !== totalCells) {
      // Proportionally adjust to fill exactly totalCells
      const factor = totalCells / allocated
      plantAllocations = plantAllocations.map(a => ({ 
        ...a, 
        cellCount: Math.max(minCellsPerPlant, Math.min(Math.round(a.cellCount * factor), maxCellsPerPlant)) 
      }))
      
      // Fine-tune to hit exact total (handle rounding errors)
      allocated = plantAllocations.reduce((s, a) => s + a.cellCount, 0)
      const diff = totalCells - allocated
      
      if (diff > 0) {
        // Add to smaller allocations first (to balance sizes)
        plantAllocations.sort((a, b) => a.cellCount - b.cellCount)
        for (let i = 0; i < diff && i < plantAllocations.length; i++) {
          if (plantAllocations[i].cellCount < maxCellsPerPlant) {
            plantAllocations[i].cellCount++
          }
        }
      } else if (diff < 0) {
        // Remove from larger allocations
        plantAllocations.sort((a, b) => b.cellCount - a.cellCount)
        for (let i = 0; i < Math.abs(diff) && i < plantAllocations.length; i++) {
          plantAllocations[i].cellCount = Math.max(minCellsPerPlant, plantAllocations[i].cellCount - 1)
        }
      }
    }

    // Sort plants by light level and size for better placement
    plantAllocations.sort((a, b) => {
      const aLight = bedLightOrder[a.plant.lightLevel || 'high']
      const bLight = bedLightOrder[b.plant.lightLevel || 'high']
      if (aLight !== bLight) return aLight - bLight
      return b.cellCount - a.cellCount
    })

    // Build result cell arrays
    const resultCells = beds.map(bed => Array.from({ length: bed.rows * bed.cols }, () => null))

    // Helper: Find best rectangular shape for target cell count, preferring 2x2, 4x4, 4x2
    const findBestShape = (targetCells, bedRows, bedCols, bedIndex) => {
      const preferredShapes = [
        { r: 2, c: 2 }, // 2x2 = 4 cells
        { r: 4, c: 4 }, // 4x4 = 16 cells
        { r: 4, c: 2 }, // 4x2 = 8 cells
        { r: 2, c: 4 }, // 2x4 = 8 cells
        { r: 3, c: 3 }, // 3x3 = 9 cells
      ]

      const cells = resultCells[bedIndex]
      const allShapes = []

      // Try preferred shapes first
      for (const shape of preferredShapes) {
        if (shape.r > bedRows || shape.c > bedCols) continue
        const size = shape.r * shape.c
        if (size <= targetCells && size >= Math.ceil(targetCells * 0.5)) {
          allShapes.push({ ...shape, size, score: Math.abs(size - targetCells) })
        }
      }

      // Generate all possible rectangular shapes
      for (let r = 1; r <= bedRows; r++) {
        for (let c = 1; c <= bedCols; c++) {
          const size = r * c
          if (size <= targetCells && size >= Math.ceil(targetCells * 0.5)) {
            const isPreferred = preferredShapes.some(s => s.r === r && s.c === c)
            const aspect = Math.max(r, c) / Math.min(r, c)
            const sizeScore = Math.abs(size - targetCells)
            const score = isPreferred ? sizeScore : sizeScore * 10 + aspect * 5
            allShapes.push({ r, c, size, score })
          }
        }
      }

      // Sort by score (lower is better)
      allShapes.sort((a, b) => a.score - b.score)

      // Try to place each shape
      for (const shape of allShapes) {
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
              return { startR, startC, rows: shape.r, cols: shape.c, size: shape.size }
            }
          }
        }
      }
      return null
    }

    // Step 3: Place each plant exactly once as a single contiguous group
    const plantedCodes = new Set()
    
    for (const allocation of plantAllocations) {
      if (allocation.cellCount < 2) continue // Too small to place
      if (plantedCodes.has(allocation.code)) continue // Already placed
      
      let placed = false
      const plantLight = allocation.plant.lightLevel || 'high'
      
      // Sort beds by: 1) available space (prefer emptier beds to fill evenly), 2) light preference
      const bedsWithSpace = sortedBeds
        .map(({ bed, bedIndex }) => {
          const availableCells = resultCells[bedIndex].filter(c => c === null).length
          const bedLight = bed.lightLevel || 'high'
          const lightScore = this.getBedPreferenceScore(plantLight, bedLight, prioritizeLight)
          return { bed, bedIndex, availableCells, lightScore }
        })
        .filter(b => b.availableCells >= 2)
        .sort((a, b) => {
          // Prioritize filling beds with more empty space first
          const spaceDiff = b.availableCells - a.availableCells
          if (Math.abs(spaceDiff) > 8) return spaceDiff // Significant difference in space
          
          // Within similar space availability, prefer better light match
          return a.lightScore - b.lightScore
        })
      
      // Try to place this plant in the best matching bed
      for (const { bed, bedIndex, availableCells } of bedsWithSpace) {
        const bedRows = bed.rows
        const bedCols = bed.cols
        
        // Try to place the entire allocation for this plant in one group
        const idealSize = Math.min(allocation.cellCount, availableCells)
        const minSize = Math.max(2, Math.min(4, idealSize))
        
        let shape = findBestShape(idealSize, bedRows, bedCols, bedIndex)
        
        // If ideal size doesn't work, try smaller sizes down to minSize
        if (!shape && idealSize > minSize) {
          for (let trySize = idealSize - 1; trySize >= minSize; trySize--) {
            shape = findBestShape(trySize, bedRows, bedCols, bedIndex)
            if (shape) break
          }
        }

        if (shape) {
          // Place the plant in the found shape
          for (let rr = 0; rr < shape.rows; rr++) {
            for (let cc = 0; cc < shape.cols; cc++) {
              const idx = (shape.startR + rr) * bedCols + (shape.startC + cc)
              resultCells[bedIndex][idx] = allocation.code
            }
          }
          plantedCodes.add(allocation.code)
          placed = true
          break // Move to next plant
        }
      }
      
      if (!placed) {
        console.warn(`Could not place plant ${allocation.code} with ${allocation.cellCount} cells`)
      }
    }

    // Fill remaining nulls by extending adjacent groups within each bed
    for (let b = 0; b < bedCount; b++) {
      const bed = beds[b]
      const bedCols = bed.cols
      const bedRows = bed.rows
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

    // Convert back to Bed instances, preserving bed names
    return beds.map((b, i) => new Bed(b.rows, b.cols, b.lightLevel, resultCells[i], b.name))
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
