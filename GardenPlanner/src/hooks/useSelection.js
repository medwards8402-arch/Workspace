/**
 * Hook for selection management
 */
import { useCallback } from 'react'
import { useGarden, GARDEN_ACTIONS } from '../context/GardenContext'

export function useSelection() {
  const { state, dispatch } = useGarden()

  const setSelection = useCallback((bedIndex, cellIndices) => {
    dispatch({ 
      type: GARDEN_ACTIONS.SET_SELECTION, 
      payload: { bedIndex, cellIndices } 
    })
  }, [dispatch])

  const clearSelection = useCallback(() => {
    dispatch({ type: GARDEN_ACTIONS.CLEAR_SELECTION })
  }, [dispatch])

  const setSelectedPlant = useCallback((plantCode) => {
    dispatch({ 
      type: GARDEN_ACTIONS.SET_SELECTED_PLANT, 
      payload: plantCode 
    })
  }, [dispatch])

  const setActiveBed = useCallback((bedIndex) => {
    dispatch({ 
      type: GARDEN_ACTIONS.SET_ACTIVE_BED, 
      payload: bedIndex 
    })
  }, [dispatch])

  return {
    selection: state.selection,
    selectedPlant: state.selectedPlant,
    activeBed: state.activeBed,
    setSelection,
    clearSelection,
    setSelectedPlant,
    setActiveBed,
  }
}
