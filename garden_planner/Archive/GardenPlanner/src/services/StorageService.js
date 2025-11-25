/**
 * Storage Service - handles persistence
 */
import { STORAGE } from '../constants'
import { Garden } from '../models/Garden'
import { devLog } from '../utils'

export class StorageService {
  static KEY = STORAGE.KEY

  /**
   * Save garden to localStorage
   */
  static save(garden) {
    try {
      const data = garden.toJSON()
      localStorage.setItem(this.KEY, JSON.stringify(data))
      devLog('Garden saved to localStorage', { 
        beds: data.beds.length, 
        plants: garden.uniquePlants.length,
        notes: Object.keys(data.notes).length 
      })
      return true
    } catch (error) {
      console.error('Failed to save garden:', error)
      return false
    }
  }

  /**
   * Load garden from localStorage
   */
  static load(validPlantCodes) {
    try {
      const raw = localStorage.getItem(this.KEY)
      if (!raw) {
        devLog('No saved state found')
        return null
      }

      const json = JSON.parse(raw)
      const garden = Garden.fromJSON(json)

      // Validate
      const errors = garden.validate(validPlantCodes)
      if (errors.length > 0) {
        console.warn('Invalid garden data:', errors)
        this.clear()
        return null
      }

      devLog('Garden loaded from localStorage', { 
        beds: garden.beds.length,
        plants: garden.uniquePlants.length 
      })
      return garden
    } catch (error) {
      console.error('Failed to load garden:', error)
      this.clear()
      return null
    }
  }

  /**
   * Clear localStorage
   */
  static clear() {
    localStorage.removeItem(this.KEY)
    devLog('Storage cleared')
  }

  /**
   * Export garden to JSON file
   */
  static exportToFile(garden, filename = 'garden-plan.pln') {
    try {
      const data = garden.toJSON()
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      a.click()
      URL.revokeObjectURL(url)
      devLog('Garden exported to file', { filename })
      return true
    } catch (error) {
      console.error('Failed to export garden:', error)
      return false
    }
  }

  /**
   * Import garden from JSON file
   */
  static async importFromFile(file, validPlantCodes) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      
      reader.onerror = () => reject(new Error('Failed to read file'))
      
      reader.onload = (e) => {
        try {
          const json = JSON.parse(e.target.result)
          const garden = Garden.fromJSON(json)
          
          // Validate
          const errors = garden.validate(validPlantCodes)
          if (errors.length > 0) {
            reject(new Error(`Invalid garden data: ${errors.join(', ')}`))
            return
          }

          devLog('Garden imported from file', { 
            beds: garden.beds.length,
            plants: garden.uniquePlants.length 
          })
          resolve(garden)
        } catch (error) {
          reject(new Error(`Failed to parse file: ${error.message}`))
        }
      }
      
      reader.readAsText(file)
    })
  }
}
