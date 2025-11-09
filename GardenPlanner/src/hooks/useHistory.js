/**
 * Hook for undo/redo operations
 */
import { useCallback } from 'react'
import { useGarden, GARDEN_ACTIONS } from '../context/GardenContext'

export function useHistory() {
  const { state, dispatch } = useGarden()

  const undo = useCallback(() => {
    dispatch({ type: GARDEN_ACTIONS.UNDO })
  }, [dispatch])

  const redo = useCallback(() => {
    dispatch({ type: GARDEN_ACTIONS.REDO })
  }, [dispatch])

  const canUndo = state.historyIndex >= 0
  const canRedo = state.historyIndex < state.history.length - 1

  return {
    undo,
    redo,
    canUndo,
    canRedo,
    historyIndex: state.historyIndex,
    historyLength: state.history.length,
  }
}
