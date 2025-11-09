/**
 * Hook for garden operations
 */
import { useCallback } from 'react'
import { useGarden, GARDEN_ACTIONS } from '../context/GardenContext'
import { GardenGenerationService } from '../services/GardenGenerationService'
import { PLANTS } from '../data'
import { Bed } from '../models/Bed'

export function useGardenOperations() {
  const { state, dispatch } = useGarden()

  const setZone = useCallback((zone) => {
    dispatch({ type: GARDEN_ACTIONS.SET_ZONE, payload: zone })
  }, [dispatch])

  const setName = useCallback((name) => {
    dispatch({ type: GARDEN_ACTIONS.SET_NAME, payload: name })
  }, [dispatch])

  const updateCell = useCallback((bedIndex, cellIndex, plantCode) => {
    dispatch({ 
      type: GARDEN_ACTIONS.UPDATE_CELL, 
      payload: { bedIndex, cellIndex, plantCode } 
    })
  }, [dispatch])

  const updateCells = useCallback((bedIndex, updates) => {
    dispatch({ 
      type: GARDEN_ACTIONS.UPDATE_CELLS, 
      payload: { bedIndex, updates } 
    })
  }, [dispatch])

  const clearCells = useCallback((bedIndex, cellIndices) => {
    dispatch({ 
      type: GARDEN_ACTIONS.CLEAR_CELLS, 
      payload: { bedIndex, cellIndices } 
    })
  }, [dispatch])

  const updateBed = useCallback((bedIndex, bed) => {
    dispatch({ 
      type: GARDEN_ACTIONS.UPDATE_BED, 
      payload: { bedIndex, bed } 
    })
  }, [dispatch])

  const setNote = useCallback((bedIndex, cellIndex, note) => {
    dispatch({ 
      type: GARDEN_ACTIONS.SET_NOTE, 
      payload: { bedIndex, cellIndex, note } 
    })
  }, [dispatch])

  const updateNotes = useCallback((updates) => {
    dispatch({ 
      type: GARDEN_ACTIONS.UPDATE_NOTES, 
      payload: updates 
    })
  }, [dispatch])

  const deleteNotes = useCallback((bedIndex, cellIndices) => {
    dispatch({ 
      type: GARDEN_ACTIONS.DELETE_NOTES, 
      payload: { bedIndex, cellIndices } 
    })
  }, [dispatch])

  const generateGarden = useCallback((config) => {
    // New flexible bed config: config.beds is array of { name, rows, cols, lightLevel, allowedTypes }
    const { beds: bedConfigs, plantCodes } = config
    const beds = bedConfigs.map(bed => new Bed(bed.rows, bed.cols, bed.lightLevel, null, bed.name, bed.allowedTypes))

    let filledBeds = beds
    if (plantCodes && plantCodes.length > 0) {
      const plants = PLANTS.filter(p => plantCodes.includes(p.code))
      filledBeds = GardenGenerationService.generate(plants, beds, true)
    }

    dispatch({
      type: GARDEN_ACTIONS.RESET_GARDEN,
      payload: {
        beds: filledBeds
      }
    })
  }, [dispatch])

  return {
    garden: state.garden,
    setZone,
    setName,
    updateCell,
    updateCells,
    clearCells,
    updateBed,
    setNote,
    updateNotes,
    deleteNotes,
    generateGarden,
  }
}
