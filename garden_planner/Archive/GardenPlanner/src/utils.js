/**
 * Breadth-first search to find all orthogonally connected cells with the same plant code
 * @param {number} startIndex - The starting cell index
 * @param {Array} bed - The bed array containing plant codes
 * @param {number} rows - Number of rows in the bed
 * @param {number} cols - Number of columns in the bed
 * @returns {Set<number>} Set of connected cell indices
 */
export function findConnectedPlants(startIndex, bed, rows, cols) {
  const plantCode = bed[startIndex];
  if (!plantCode) return new Set();

  const visited = new Set();
  const queue = [startIndex];
  visited.add(startIndex);

  while (queue.length > 0) {
    const curr = queue.shift();
    const row = Math.floor(curr / cols);
    const col = curr % cols;

    // Check 4 orthogonal directions
    const neighbors = [
      [row - 1, col], // up
      [row + 1, col], // down
      [row, col - 1], // left
      [row, col + 1], // right
    ];

    for (const [r, c] of neighbors) {
      if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
      const idx = r * cols + c;
      if (visited.has(idx)) continue;
      if (bed[idx] === plantCode) {
        visited.add(idx);
        queue.push(idx);
      }
    }
  }

  return visited;
}

/**
 * Calculate the last frost date for a given USDA zone and year
 * @param {string} zoneKey - The USDA zone key (e.g., '5a')
 * @param {Object} zones - The USDA_ZONES lookup object
 * @param {Date} referenceDate - The reference date (usually today)
 * @returns {Date|null} The calculated frost date or null if zone not found
 */
export function calculateLastFrostDate(zoneKey, zones, referenceDate = new Date()) {
  const zone = zones[zoneKey];
  if (!zone) return null;

  let year = referenceDate.getFullYear();
  const frostDate = new Date(year, zone.month - 1, zone.day);
  
  // If frost date has passed this year, use next year
  if (frostDate < referenceDate) {
    frostDate.setFullYear(year + 1);
  }

  return frostDate;
}

/**
 * Validate that all plant codes in beds are valid
 * @param {Array<Array>} beds - Array of bed arrays containing plant codes
 * @param {Set<string>} validCodes - Set of valid plant codes
 * @returns {boolean} True if all codes are valid
 */
export function validateBedPlantCodes(beds, validCodes) {
  if (!Array.isArray(beds)) return false;

  for (const bed of beds) {
    if (!Array.isArray(bed)) continue;
    for (const code of bed) {
      if (code && !validCodes.has(code)) {
        return false;
      }
    }
  }

  return true;
}

/**
 * Log an action in development mode
 * @param {string} action - The action being performed
 * @param {Object} data - Additional data to log
 */
export function devLog(action, data = {}) {
  if (import.meta.env.DEV) {
    console.log(`[GardenPlanner] ${action}`, data);
  }
}

/**
 * Generate a populated garden based on selected plants and square-foot spacing
 * Uses square-foot gardening principles to distribute plants across beds
 * Plants are clustered together orthogonally and never split across beds
 * Each plant type appears in exactly one contiguous group
 * @param {Array<string>} selectedPlantCodes - Array of plant codes to include
 * @param {Array} plantsData - Array of plant objects with sqftSpacing property
 * @param {number} bedCount - Number of beds to generate
 * @param {number} bedRows - Number of rows per bed
 * @param {number} bedCols - Number of columns per bed
 * @param {Array<string>} bedLightLevels - Light level for each bed ('low', 'high')
 * @returns {Array<Array>} Array of bed arrays with populated plant codes
 */
export function generateGarden(selectedPlantCodes, plantsData, bedCount, bedRows, bedCols, bedLightLevels = []) {
  const cellsPerBed = bedRows * bedCols
  const totalCells = bedCount * cellsPerBed
  
  // Create plant lookup
  const plantMap = new Map(plantsData.map(p => [p.code, p]))
  const validPlants = selectedPlantCodes.filter(code => plantMap.has(code))
  
  if (validPlants.length === 0) {
    return Array.from({ length: bedCount }, () => Array(cellsPerBed).fill(null))
  }
  
  // Default to high light if not specified
  const lightLevels = bedLightLevels.length === bedCount 
    ? bedLightLevels 
    : Array.from({ length: bedCount }, () => 'high')
  
  // Calculate how many cells to allocate to each plant type
  // Reduce allocations to ensure each plant fits in one bed
  const plantAllocations = validPlants.map(code => {
    const plant = plantMap.get(code)
    const cellsPerPlant = Math.max(1, Math.round(1 / plant.sqftSpacing))
    return { code, cellsPerPlant, plant }
  })
  
  // Distribute cells proportionally but cap at cellsPerBed
  const totalWeight = plantAllocations.reduce((sum, p) => sum + p.cellsPerPlant, 0)
  let scaledAllocations = plantAllocations.map(({ code, cellsPerPlant, plant }) => ({
    code,
    plant,
    cellCount: Math.max(2, Math.min(cellsPerBed, Math.round((cellsPerPlant / totalWeight) * totalCells)))
  }))
  
  // If total allocation exceeds available space, scale down proportionally
  let totalAllocated = scaledAllocations.reduce((sum, a) => sum + a.cellCount, 0)
  if (totalAllocated > totalCells) {
    const scaleFactor = totalCells / totalAllocated
    scaledAllocations = scaledAllocations.map(a => ({
      ...a,
      cellCount: Math.max(2, Math.floor(a.cellCount * scaleFactor))
    }))
  }
  
  // Sort by cellCount descending (place larger plants first)
  scaledAllocations.sort((a, b) => b.cellCount - a.cellCount)
  
  // Initialize beds
  const beds = Array.from({ length: bedCount }, () => Array(cellsPerBed).fill(null))
  
  // Helper function to find best rectangular cluster for a plant in a specific bed
  // Prefers square shapes over long rectangles
  const findBestCluster = (targetCells, bedIndex) => {
    const shapes = []
    
    // Generate all possible rectangular shapes, prioritizing squares
    for (let rows = 1; rows <= bedRows; rows++) {
      for (let cols = 1; cols <= bedCols; cols++) {
        const size = rows * cols
        if (size >= Math.max(2, Math.ceil(targetCells * 0.8)) && size <= Math.min(cellsPerBed, targetCells * 1.2)) {
          const aspectRatio = Math.max(rows, cols) / Math.min(rows, cols)
          const sizeScore = Math.abs(size - targetCells)
          // Prefer squares (low aspect ratio) and exact size matches
          const score = sizeScore * 10 + aspectRatio
          shapes.push({ rows, cols, size, score })
        }
      }
    }
    
    // Sort by score (lower is better)
    shapes.sort((a, b) => a.score - b.score)
    
    // Try to place the best shapes
    for (const shape of shapes) {
      // Try all possible positions
      for (let startRow = 0; startRow <= bedRows - shape.rows; startRow++) {
        for (let startCol = 0; startCol <= bedCols - shape.cols; startCol++) {
          // Check if this rectangle is empty
          let canPlace = true
          for (let r = 0; r < shape.rows && canPlace; r++) {
            for (let c = 0; c < shape.cols && canPlace; c++) {
              const idx = (startRow + r) * bedCols + (startCol + c)
              if (beds[bedIndex][idx] !== null) {
                canPlace = false
              }
            }
          }
          
          if (canPlace) {
            return { bedIndex, startRow, startCol, rows: shape.rows, cols: shape.cols, size: shape.size }
          }
        }
      }
    }
    
    return null
  }
  
  // Place each plant type in exactly one cluster
  for (const allocation of scaledAllocations) {
    const plantLightLevel = allocation.plant.lightLevel || 'high'
    let placed = false
    
    // Try beds with matching light level first, then any bed
    const bedPriority = []
    for (let b = 0; b < bedCount; b++) {
      if (lightLevels[b] === plantLightLevel) {
        bedPriority.unshift(b) // Add matching beds to front
      } else {
        bedPriority.push(b) // Add non-matching to back
      }
    }
    
    for (const bedIdx of bedPriority) {
      const emptyCount = beds[bedIdx].filter(cell => cell === null).length
      if (emptyCount < allocation.cellCount) continue // Not enough space
      
      const cluster = findBestCluster(allocation.cellCount, bedIdx)
      
      if (cluster) {
        // Place the entire plant group in this one cluster
        for (let r = 0; r < cluster.rows; r++) {
          for (let c = 0; c < cluster.cols; c++) {
            const idx = (cluster.startRow + r) * bedCols + (cluster.startCol + c)
            beds[cluster.bedIndex][idx] = allocation.code
          }
        }
        placed = true
        break
      }
    }
    
    // If we couldn't place this plant, skip it (don't create isolated cells)
    if (!placed) {
      console.warn(`Could not place ${allocation.code} in any bed`)
    }
  }
  
  // Fill remaining empty cells by extending adjacent groups (not creating new isolated plants)
  for (let b = 0; b < bedCount; b++) {
    for (let i = 0; i < beds[b].length; i++) {
      if (beds[b][i] === null) {
        // Look for adjacent plant to extend
        const row = Math.floor(i / bedCols)
        const col = i % bedCols
        const neighbors = []
        
        if (row > 0) neighbors.push(beds[b][(row - 1) * bedCols + col]) // up
        if (row < bedRows - 1) neighbors.push(beds[b][(row + 1) * bedCols + col]) // down
        if (col > 0) neighbors.push(beds[b][row * bedCols + (col - 1)]) // left
        if (col < bedCols - 1) neighbors.push(beds[b][row * bedCols + (col + 1)]) // right
        
        const validNeighbors = neighbors.filter(n => n !== null)
        if (validNeighbors.length > 0) {
          // Extend the most common adjacent plant
          const counts = {}
          validNeighbors.forEach(n => counts[n] = (counts[n] || 0) + 1)
          const mostCommon = Object.entries(counts).sort((a, b) => b[1] - a[1])[0][0]
          beds[b][i] = mostCommon
        }
      }
    }
  }
  
  return beds
}
