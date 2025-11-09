/**
 * Bed Model - represents a single garden bed
 */
export class Bed {
  constructor(rows, cols, lightLevel = 'high', cells = null) {
    this.rows = rows
    this.cols = cols
    this.lightLevel = lightLevel
    this.cells = cells || Array.from({ length: rows * cols }, () => null)
    this.name = name
  }

  get size() {
    return this.rows * this.cols
  }

  /**
   * Get plant code at specific cell index
   */
  getCell(index) {
    return this.cells[index]
  }

  /**
   * Set plant code at specific cell index
   */
  setCell(index, plantCode) {
    if (index < 0 || index >= this.cells.length) {
      throw new Error(`Invalid cell index: ${index}`)
    }
    const newCells = [...this.cells]
    newCells[index] = plantCode
  return new Bed(this.rows, this.cols, this.lightLevel, newCells, this.name)
  }

  /**
   * Set multiple cells at once
   */
  setCells(updates) {
    const newCells = [...this.cells]
    Object.entries(updates).forEach(([index, plantCode]) => {
      newCells[parseInt(index)] = plantCode
    })
    return new Bed(this.rows, this.cols, this.lightLevel, newCells, this.name)
  }

  /**
   * Clear specific cells
   */
  clearCells(indices) {
    const newCells = [...this.cells]
    indices.forEach(i => {
      newCells[i] = null
    })
    return new Bed(this.rows, this.cols, this.lightLevel, newCells, this.name)
  }

  /**
   * Get all cells with a specific plant code
   */
  getCellsWithPlant(plantCode) {
    return this.cells
      .map((code, index) => code === plantCode ? index : -1)
      .filter(index => index !== -1)
  }

  /**
   * Get connected cells using BFS (for double-click selection)
   */
  getConnectedCells(startIndex) {
    const plantCode = this.cells[startIndex]
    if (!plantCode) return new Set()

    const visited = new Set()
    const queue = [startIndex]
    visited.add(startIndex)

    while (queue.length > 0) {
      const curr = queue.shift()
      const row = Math.floor(curr / this.cols)
      const col = curr % this.cols

      // Check 4 orthogonal neighbors
      const neighbors = [
        [row - 1, col],
        [row + 1, col],
        [row, col - 1],
        [row, col + 1]
      ]

      for (const [r, c] of neighbors) {
        if (r < 0 || r >= this.rows || c < 0 || c >= this.cols) continue
        const idx = r * this.cols + c
        if (visited.has(idx)) continue
        if (this.cells[idx] === plantCode) {
          visited.add(idx)
          queue.push(idx)
        }
      }
    }

    return visited
  }

  /**
   * Count non-empty cells
   */
  get plantedCellCount() {
    return this.cells.filter(cell => cell !== null).length
  }

  /**
   * Get unique plant codes in this bed
   */
  get uniquePlants() {
    return [...new Set(this.cells.filter(cell => cell !== null))]
  }

  /**
   * Serialize to plain object for storage
   */
  toJSON() {
    return {
      rows: this.rows,
      cols: this.cols,
      lightLevel: this.lightLevel,
      cells: this.cells
    }
  }

  /**
   * Deserialize from plain object
   */
  static fromJSON(json) {
    return new Bed(json.rows, json.cols, json.lightLevel, json.cells)
  }
}
