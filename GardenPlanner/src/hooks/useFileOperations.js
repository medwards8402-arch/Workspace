/**
 * Hook for file import/export
 */
import { useCallback } from 'react'
import { useGarden, GARDEN_ACTIONS } from '../context/GardenContext'
import { StorageService } from '../services/StorageService'
import { PLANTS } from '../data'

export function useFileOperations() {
  const { state, dispatch } = useGarden()

  const exportToFile = useCallback((filename) => {
    return StorageService.exportToFile(state.garden, filename)
  }, [state.garden])

  const importFromFile = useCallback(async () => {
    return new Promise((resolve, reject) => {
      const input = document.createElement('input')
      input.type = 'file'
      input.accept = '.json'
      
      input.onchange = async (e) => {
        const file = e.target.files?.[0]
        if (!file) {
          reject(new Error('No file selected'))
          return
        }

        try {
          const validPlantCodes = new Set(PLANTS.map(p => p.code))
          const garden = await StorageService.importFromFile(file, validPlantCodes)
          dispatch({ type: GARDEN_ACTIONS.LOAD_GARDEN, payload: garden })
          resolve(garden)
        } catch (error) {
          reject(error)
        }
      }

      input.click()
    })
  }, [dispatch])

  return {
    exportToFile,
    importFromFile,
  }
}
