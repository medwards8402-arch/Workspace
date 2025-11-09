/**
 * Garden Model - represents the entire garden state
 */
import { Bed } from './Bed'

export class Garden {
  constructor(config = {}) {
    this.beds = config.beds || []
    this.zone = config.zone || '5a'
    this.notes = config.notes || {}
    this.name = config.name || 'My Garden'
    // Remove global bedRows/bedCols; rely on per-bed config
  }

  /**
   * Update garden name
   */
  setName(name) {
    return new Garden({ ...this, name })
  }

  /**
   * Get a specific bed
   */
  getBed(index) {
    return this.beds[index]
  }

  /**
   * Update a specific bed
   */
  updateBed(index, bed) {
    if (index < 0 || index >= this.beds.length) {
      throw new Error(`Invalid bed index: ${index}`)
    }
    const newBeds = [...this.beds]
    newBeds[index] = bed
    return new Garden({ ...this, beds: newBeds })
  }

  /**
   * Add a note for a specific cell
   */
  setNote(bedIndex, cellIndex, note) {
    const key = `${bedIndex}.${cellIndex}`
    const newNotes = { ...this.notes }
    if (note && note.trim()) {
      newNotes[key] = note
    } else {
      delete newNotes[key]
    }
    return new Garden({ ...this, notes: newNotes })
  }

  /**
   * Get note for a specific cell
   */
  getNote(bedIndex, cellIndex) {
    const key = `${bedIndex}.${cellIndex}`
    return this.notes[key] || ''
  }

  /**
   * Delete notes for specific cells
   */
  deleteNotes(bedIndex, cellIndices) {
    const newNotes = { ...this.notes }
    cellIndices.forEach(cellIndex => {
      const key = `${bedIndex}.${cellIndex}`
      delete newNotes[key]
    })
    return new Garden({ ...this, notes: newNotes })
  }

  /**
   * Get all planted cells across all beds
   */
  get allPlantedCells() {
    return this.beds.reduce((total, bed) => total + bed.plantedCellCount, 0)
  }

  /**
   * Get all unique plants in the garden
   */
  get uniquePlants() {
    const plants = new Set()
    this.beds.forEach(bed => {
      bed.uniquePlants.forEach(plant => plants.add(plant))
    })
    return [...plants]
  }

  /**
   * Validate garden data
   */
  validate(validPlantCodes) {
    const errors = []
    
    // Validate beds
    if (!Array.isArray(this.beds)) {
      errors.push('Beds must be an array')
    } else {
      this.beds.forEach((bed, i) => {
        if (!(bed instanceof Bed)) {
          errors.push(`Bed ${i} is not a valid Bed instance`)
        } else {
          // Validate plant codes
          bed.cells.forEach((code, j) => {
            if (code && !validPlantCodes.has(code)) {
              errors.push(`Invalid plant code '${code}' at bed ${i}, cell ${j}`)
            }
          })
        }
      })
    }

    // Validate zone
    const validZones = ['3a', '3b', '4a', '4b', '5a', '5b', '6a', '6b', '7a', '7b', '8a', '8b', '9a', '9b', '10a', '10b']
    if (!validZones.includes(this.zone)) {
      errors.push(`Invalid zone: ${this.zone}`)
    }

    return errors
  }

  /**
   * Serialize to plain object for storage
   */
  toJSON() {
    return {
      name: this.name,
      beds: this.beds.map(bed => bed.toJSON()),
      zone: this.zone,
      notes: this.notes,
      bedRows: this.bedRows,
      bedCols: this.bedCols,
      // For backwards compatibility
      bedCount: this.beds.length,
      bedLightLevels: this.beds.map(bed => bed.lightLevel)
    }
  }

  /**
   * Deserialize from plain object
   */
  static fromJSON(json) {
    // Handle both old and new formats
    let beds = []
    
    if (json.beds && json.beds.length > 0) {
      // Check if beds are already Bed instances or need conversion
      if (json.beds[0]?.cells) {
        // New format with Bed objects
        beds = json.beds.map(b => Bed.fromJSON(b))
      } else {
        // Old format with plain arrays
        const rows = json.bedRows || 8
        const cols = json.bedCols || 4
        const lightLevels = json.bedLightLevels || []
        beds = json.beds.map((cells, i) => {
          const lightLevel = lightLevels[i] || 'high'
          return new Bed(rows, cols, lightLevel, cells)
        })
      }
    }

    return new Garden({
      beds,
      zone: json.zone || '5a',
      notes: json.notes || {},
      name: json.name || 'My Garden',
      bedRows: json.bedRows || 8,
      bedCols: json.bedCols || 4
    })
  }
}
