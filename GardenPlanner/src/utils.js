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
