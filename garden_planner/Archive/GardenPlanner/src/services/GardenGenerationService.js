/**
 * Garden Generation Service - handles auto-generation logic
 */
import { Bed } from '../models/Bed'

export class GardenGenerationService {
  /**
   * Generate optimized garden layout
   * Each plant appears exactly once as a single contiguous group across entire garden.
   * Respects bed allowedTypes to filter eligible plants per bed.
   * Prefers rectangular shapes (2x2, 4x4, 4x2) and optimizes for light preferences.
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

    // Step 1: Calculate global plant allocations (how many cells each plant should get total)
    // IMPORTANT: Consider only the beds where each plant can actually be placed
    const plantAllocations = plants.map(p => {
      const cellsPerPlant = Math.max(1, Math.round(1 / (p.sqftSpacing || 1)))
      const plantType = p.type || 'vegetable'
      
      // Calculate available space in beds that allow this plant type
      const eligibleBedSpace = beds.reduce((sum, bed) => {
        const allowedTypes = bed.allowedTypes || ['vegetable', 'fruit', 'herb']
        if (allowedTypes.includes(plantType)) {
          return sum + (bed.rows * bed.cols)
        }
        return sum
      }, 0)
      
      return { code: p.code, plant: p, cellsPerPlant, eligibleBedSpace }
    })

    // Group plants by their eligible bed space to allocate proportionally within each group
    const plantsByEligibleSpace = plantAllocations.reduce((acc, p) => {
      const key = p.eligibleBedSpace
      if (!acc[key]) acc[key] = []
      acc[key].push(p)
      return acc
    }, {})

    // Distribute cells proportionally within each group's available space
    let scaledAllocations = []
    
    for (const [eligibleSpace, groupPlants] of Object.entries(plantsByEligibleSpace)) {
      const spaceAvailable = parseInt(eligibleSpace)
  const plantCount = groupPlants.length
  const totalWeight = groupPlants.reduce((sum, p) => sum + Math.sqrt(p.cellsPerPlant), 0)
      
  // Calculate adaptive minimum: ensure all plants can fit
  // Use 2 as absolute minimum (needed for placement), but allow smaller allocations if many plants
  // SPECIAL-CASE: Herbs should be allowed to allocate in increments of 1 sq ft.
  const adaptiveMin = Math.max(2, Math.min(4, Math.floor(spaceAvailable / (plantCount * 1.2))))
      
      const groupAllocations = groupPlants.map(({ code, plant, cellsPerPlant }) => {
        const weight = Math.sqrt(cellsPerPlant)
  // Allocate based on this group's available space
        const allocation = Math.round((weight / totalWeight) * spaceAvailable)
        // Minimum per-plant allocation: allow herbs to be 1, others follow adaptiveMin (>=2)
        const minForPlant = (plant.type || 'vegetable') === 'herb' ? 1 : adaptiveMin
        return {
          code,
          plant,
          cellCount: Math.max(minForPlant, Math.min(spaceAvailable, allocation))
        }
      })
      
      // If total allocation exceeds available space for this group, scale down
      let totalAllocated = groupAllocations.reduce((sum, a) => sum + a.cellCount, 0)
      if (totalAllocated > spaceAvailable) {
        const scaleFactor = spaceAvailable / totalAllocated
        groupAllocations.forEach(a => {
          const isHerb = (a.plant.type || 'vegetable') === 'herb'
          a.cellCount = Math.max(isHerb ? 1 : 2, Math.round(a.cellCount * scaleFactor))
        })
      }
      
      scaledAllocations.push(...groupAllocations)
    }

    // Sort by size (larger plants first for better packing)
    scaledAllocations.sort((a, b) => b.cellCount - a.cellCount)

    // Debug: Log plant allocations by type
    const allocationsByType = scaledAllocations.reduce((acc, a) => {
      const type = a.plant.type || 'vegetable'
      if (!acc[type]) acc[type] = { plants: [], totalCells: 0 }
      acc[type].plants.push(`${a.code}(${a.cellCount})`)
      acc[type].totalCells += a.cellCount
      return acc
    }, {})
    console.log('Plant allocations by type:', allocationsByType)
    
    // Debug: Log bed configurations with available space
    console.log('Bed configurations:', beds.map((b, i) => ({
      index: i,
      name: b.name,
      size: `${b.rows}x${b.cols}`,
      cells: b.rows * b.cols,
      types: b.allowedTypes || ['vegetable', 'fruit', 'herb']
    })))

    // Step 2: Initialize result arrays
    const resultCells = beds.map(bed => Array.from({ length: bed.rows * bed.cols }, () => null))

    // Helper: Find best rectangular shape for placing plants in a specific bed
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

    // Helper: Create bed priority list with light and space considerations
    const sortedBeds = beds.map((bed, bedIndex) => ({ bed, bedIndex }))

    // Step 3: Place each plant exactly once as a single contiguous group
    // Filter to only beds that allow this plant's type
    const plantedCodes = new Set()
    
    for (const allocation of scaledAllocations) {
  // Allow herbs to be placed as single 1 sq ft squares; others require >=2 for useful grouping
  if (allocation.cellCount < 2 && (allocation.plant.type || 'vegetable') !== 'herb') continue // Too small to place
      if (plantedCodes.has(allocation.code)) continue // Already placed
      
      let placed = false
      const plantLight = allocation.plant.lightLevel || 'high'
      const plantType = allocation.plant.type || 'vegetable'
      
      // Filter beds by allowed types for this plant
      const candidateBeds = sortedBeds
        .filter(({ bed }) => {
          const allowedTypes = bed.allowedTypes || ['vegetable', 'fruit', 'herb']
          const isEligible = allowedTypes.includes(plantType)
          if (!isEligible) {
            console.log(`  ${allocation.code} (${plantType}) not eligible for bed ${bed.name} (allows: ${allowedTypes.join(',')})`)
          }
          return isEligible
        })
        .map(({ bed, bedIndex }) => {
          const availableCells = resultCells[bedIndex].filter(c => c === null).length
          const bedLight = bed.lightLevel || 'high'
          const lightScore = this.getBedPreferenceScore(plantLight, bedLight, prioritizeLight)
          return { bed, bedIndex, availableCells, lightScore }
        })
  .filter(b => b.availableCells >= ((allocation.plant.type || 'vegetable') === 'herb' ? 1 : 2))

      // Soft light preference: compute adjustedLightScore to avoid monopolizing scarce perfect-light beds
      // If there's only one bed with the perfect light and the group is small vs that bed's free space,
      // add a small penalty so a secondary choice can be selected when reasonable.
      const lightCounts = beds.reduce((acc, b) => {
        const l = (b.lightLevel || 'high').toLowerCase()
        acc[l] = (acc[l] || 0) + 1
        return acc
      }, {})

      const eligibleBeds = candidateBeds
        .map(b => {
          let adjustedLightScore = b.lightScore
          if (prioritizeLight) {
            const bedLightName = (b.bed.lightLevel || 'high').toLowerCase()
            const plantPrefLight = (plantLight || 'high').toLowerCase()
            const isPerfect = bedLightName === plantPrefLight
            const countThisLight = lightCounts[bedLightName] || 0
            const fillRatio = b.availableCells > 0 ? allocation.cellCount / b.availableCells : 1
            // Apply penalty only when perfect match is scarce and this placement would underuse the bed
            if (isPerfect && countThisLight === 1 && fillRatio < 0.35) {
              adjustedLightScore += 0.75
            }
          }
          return { ...b, adjustedLightScore }
        })
        // Sort by (adjusted light) then (space desc)
        .sort((a, b) => {
          const ls = a.adjustedLightScore - b.adjustedLightScore
          if (ls !== 0) return ls
          return b.availableCells - a.availableCells
        })

      console.log(
        `Placing ${allocation.code} (${plantType}, ${allocation.cellCount} cells) - candidates: ${candidateBeds.length}, ` +
        `bestLightScore: ${prioritizeLight && candidateBeds.length ? Math.min(...candidateBeds.map(b => b.lightScore)) : 'n/a'}, ` +
        `topAdjustedLight: ${eligibleBeds.length ? eligibleBeds[0].adjustedLightScore : 'n/a'}`
      )
      
      // Try to place this plant in the best matching eligible bed
      for (const { bed, bedIndex, availableCells } of eligibleBeds) {
        const bedRows = bed.rows
        const bedCols = bed.cols
        
        // Try to place the entire allocation for this plant in one group
        const idealSize = Math.min(allocation.cellCount, availableCells)
        // Herbs may be placed as single-square groups; others maintain a minimum useful size
        const minSize = (allocation.plant.type || 'vegetable') === 'herb'
          ? 1
          : Math.max(2, Math.min(4, idealSize))
        
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
          console.log(`  ✓ Placed ${allocation.code} in bed ${bedIndex} (${bed.name}) as ${shape.rows}x${shape.cols}`)
          plantedCodes.add(allocation.code)
          placed = true
          break // Move to next plant
        }
      }
      
      if (!placed) {
        console.warn(`Could not place plant ${allocation.code} (type: ${plantType}) - no eligible beds with space`)
      }
    }

    // Step 4: Fill remaining nulls by extending adjacent groups within each bed
    // IMPORTANT: Only extend with plants that are allowed in this bed's type restrictions
    for (let b = 0; b < bedCount; b++) {
      const bed = beds[b]
      const bedCols = bed.cols
      const bedRows = bed.rows
      const cells = resultCells[b]
      const allowedTypes = bed.allowedTypes || ['vegetable', 'fruit', 'herb']
      
      // Create a map of plant code -> plant type for quick lookup
      const plantTypeMap = new Map(plants.map(p => [p.code, p.type || 'vegetable']))
      
      for (let i = 0; i < cells.length; i++) {
        if (cells[i] === null) {
          const row = Math.floor(i / bedCols)
          const col = i % bedCols
          const neighbors = []
          if (row > 0) neighbors.push(cells[(row - 1) * bedCols + col])
          if (row < bedRows - 1) neighbors.push(cells[(row + 1) * bedCols + col])
          if (col > 0) neighbors.push(cells[row * bedCols + (col - 1)])
          if (col < bedCols - 1) neighbors.push(cells[row * bedCols + (col + 1)])
          
          // Filter neighbors to only those that are allowed in this bed
          const valid = neighbors
            .filter(n => n !== null)
            .filter(n => {
              const plantType = plantTypeMap.get(n)
              // Do not extend herbs automatically; keep herbs in 1 sq ft increments
              if (plantType === 'herb') return false
              return plantType && allowedTypes.includes(plantType)
            })
          
          if (valid.length > 0) {
            const counts = {}
            valid.forEach(n => counts[n] = (counts[n] || 0) + 1)
            const mostCommon = Object.entries(counts).sort((x, y) => y[1] - x[1])[0][0]
            cells[i] = mostCommon
          }
        }
      }
    }

    // Step 5: Adjust sprawling plants to consume exactly the space they require
    // For plants with specific spacing requirements (e.g., pumpkins = 4 sqft each)
    for (let b = 0; b < bedCount; b++) {
      const bed = beds[b]
      const bedCols = bed.cols
      const bedRows = bed.rows
      const cells = resultCells[b]
      
      // Count how many cells each plant currently occupies
      const plantCounts = {}
      cells.forEach(code => {
        if (code !== null) {
          plantCounts[code] = (plantCounts[code] || 0) + 1
        }
      })
      
      // For each plant in this bed, check if it needs adjustment
      for (const [plantCode, currentCells] of Object.entries(plantCounts)) {
        const plant = plants.find(p => p.code === plantCode)
        if (!plant || !plant.sqftSpacing) continue
        
        // Calculate required cells (each plant needs 1/sqftSpacing cells)
        const requiredCellsPerPlant = Math.round(1 / plant.sqftSpacing)
        
        // Only adjust if plant requires multiple cells (sprawling plants)
        if (requiredCellsPerPlant <= 1) continue
        
        // Calculate how many "plants" we should have based on current cells
        const targetPlantCount = Math.round(currentCells / requiredCellsPerPlant)
        const targetCells = targetPlantCount * requiredCellsPerPlant
        
        // If we need to adjust (remove excess cells)
        if (currentCells > targetCells && targetCells > 0) {
          // Find all cells with this plant code
          const plantCellIndices = []
          cells.forEach((code, idx) => {
            if (code === plantCode) plantCellIndices.push(idx)
          })
          
          // Calculate best shape for this plant (prefer squares for sprawling plants)
          const shapeRows = Math.sqrt(requiredCellsPerPlant)
          const shapeCols = requiredCellsPerPlant / shapeRows
          const isSquare = Math.abs(shapeRows - Math.round(shapeRows)) < 0.01 && 
                          Math.abs(shapeCols - Math.round(shapeCols)) < 0.01
          
          // Remove excess cells (from the edges/non-contiguous areas)
          const cellsToRemove = currentCells - targetCells
          let removed = 0
          
          // Remove from end of list (typically edge cells added by fill step)
          for (let i = plantCellIndices.length - 1; i >= 0 && removed < cellsToRemove; i--) {
            const idx = plantCellIndices[i]
            const row = Math.floor(idx / bedCols)
            const col = idx % bedCols
            
            // Check if this cell has fewer than 2 neighbors with same plant (likely an edge)
            let neighborCount = 0
            if (row > 0 && cells[(row - 1) * bedCols + col] === plantCode) neighborCount++
            if (row < bedRows - 1 && cells[(row + 1) * bedCols + col] === plantCode) neighborCount++
            if (col > 0 && cells[row * bedCols + (col - 1)] === plantCode) neighborCount++
            if (col < bedCols - 1 && cells[row * bedCols + (col + 1)] === plantCode) neighborCount++
            
            // Remove cells with fewer neighbors (edges) first
            if (neighborCount <= 2) {
              cells[idx] = null
              removed++
            }
          }
          
          // If we still need to remove more, remove any remaining cells
          for (let i = plantCellIndices.length - 1; i >= 0 && removed < cellsToRemove; i--) {
            if (cells[plantCellIndices[i]] === plantCode) {
              cells[plantCellIndices[i]] = null
              removed++
            }
          }
          
          console.log(`[GardenGen] Adjusted ${plantCode} in ${bed.name}: ${currentCells} → ${targetCells} cells (${targetPlantCount} plants × ${requiredCellsPerPlant} cells each)`)
        }
      }
    }

    // Convert back to Bed instances, preserving bed names and allowedTypes
    return beds.map((b, i) => new Bed(b.rows, b.cols, b.lightLevel, resultCells[i], b.name, b.allowedTypes))
  }

  /**
   * Check if plant light requirement is compatible with bed light level
   */
  static isLightCompatible(plantLight, bedLight) {
    const levels = { low: 1, high: 2 }
    const plantLevel = levels[plantLight] || 2
    const bedLevel = levels[bedLight] || 2
    
    // Allow plants to be in same or higher light
    return bedLevel >= plantLevel
  }

  /**
   * Returns a numeric score for how suitable a bed light level is for a given plant.
   * Lower is better. Implements requested fallback preferences:
   *  - Low bed: low best (0), then high (1)
   *  - High bed: high best (0), then low (1)
   * If prioritizeLight=false, all scores are equal (0) to ignore light preferences.
   */
  static getBedPreferenceScore(plantLight, bedLight, prioritizeLight = true) {
    if (!prioritizeLight) return 0

    const pl = (plantLight || 'high').toLowerCase()
    const bl = (bedLight || 'high').toLowerCase()

    if (bl === 'low') {
      if (pl === 'low') return 0
      return 1 // high
    }
    if (bl === 'high') {
      if (pl === 'high') return 0
      return 1 // low
    }
    // default: treat as high bed
    if (pl === 'high') return 0
    return 1
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
