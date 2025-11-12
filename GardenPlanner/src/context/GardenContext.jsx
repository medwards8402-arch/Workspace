/**
 * Garden State Context
 * Centralized state management using React Context and useReducer
 */

import React, { createContext, useContext, useReducer, useCallback, useEffect } from 'react'
import { Garden } from '../models/Garden'
import { Bed } from '../models/Bed'
import { StorageService } from '../services/StorageService'
import { PLANTS, BED_COUNT, BED_ROWS, BED_COLS } from '../data'

// Action Types
export const GARDEN_ACTIONS = {
  // Garden-level actions
  LOAD_GARDEN: 'LOAD_GARDEN',
  RESET_GARDEN: 'RESET_GARDEN',
  SET_ZONE: 'SET_ZONE',
  SET_NAME: 'SET_NAME',
  
  // Bed actions
  UPDATE_BED: 'UPDATE_BED',
  ADD_BED: 'ADD_BED',
  REMOVE_BED: 'REMOVE_BED',
  REORDER_BED: 'REORDER_BED',
  UPDATE_CELL: 'UPDATE_CELL',
  UPDATE_CELLS: 'UPDATE_CELLS',
  CLEAR_CELLS: 'CLEAR_CELLS',
  
  // Notes actions
  SET_NOTE: 'SET_NOTE',
  DELETE_NOTES: 'DELETE_NOTES',
  UPDATE_NOTES: 'UPDATE_NOTES',
  
  // Selection actions
  SET_SELECTION: 'SET_SELECTION',
  CLEAR_SELECTION: 'CLEAR_SELECTION',
  SET_SELECTED_PLANT: 'SET_SELECTED_PLANT',
  SET_ACTIVE_BED: 'SET_ACTIVE_BED',
  
  // History actions
  UNDO: 'UNDO',
  REDO: 'REDO',
  PUSH_HISTORY: 'PUSH_HISTORY',
}

// Initial State
const createInitialGarden = () => {
  const beds = Array.from({ length: BED_COUNT }, (_, i) => {
    const lightLevel = i === 2 ? 'low' : 'high'
    return new Bed(BED_ROWS, BED_COLS, lightLevel)
  })
  
  return new Garden({
    beds,
    zone: '5a',
    notes: {},
    bedRows: BED_ROWS,
    bedCols: BED_COLS
  })
}

const initialState = {
  // Garden data
  garden: createInitialGarden(),
  
  // UI state
  selection: {
    bedIndex: null,
    cellIndices: new Set(),
  },
  selectedPlant: null, // Selected from palette
  activeBed: null,
  
  // History for undo/redo
  history: [],
  historyIndex: -1,
  maxHistorySize: 10,
  
  // Loading state
  isLoaded: false,
}

// Reducer
function gardenReducer(state, action) {
  switch (action.type) {
    case GARDEN_ACTIONS.LOAD_GARDEN: {
      return {
        ...state,
        garden: action.payload,
        isLoaded: true,
        history: [],
        historyIndex: -1,
      }
    }

    case GARDEN_ACTIONS.RESET_GARDEN: {
      const { beds: providedBeds } = action.payload
      let beds = providedBeds
      if (!beds || beds.length === 0) {
        beds = []
      }
      const newGarden = new Garden({
        beds,
        zone: state.garden.zone,
        notes: {}
      })
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.SET_ZONE: {
      const newGarden = new Garden({ ...state.garden, zone: action.payload })
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.SET_NAME: {
      const newGarden = state.garden.setName(action.payload)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.UPDATE_BED: {
      const { bedIndex, bed } = action.payload
      const newGarden = state.garden.updateBed(bedIndex, bed)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.ADD_BED: {
      const { bed } = action.payload || {}
      const newBed = bed || new Bed(BED_ROWS, BED_COLS, 'high')
      const newGarden = new Garden({ ...state.garden, beds: [...state.garden.beds, newBed] })
      const newState = pushToHistory(state, newGarden)
      // Focus the newly added bed and clear selection
      return {
        ...newState,
        selection: { bedIndex: null, cellIndices: new Set() },
        activeBed: newGarden.beds.length - 1,
      }
    }

    case GARDEN_ACTIONS.REMOVE_BED: {
      const { bedIndex } = action.payload
      if (bedIndex < 0 || bedIndex >= state.garden.beds.length) return state
      const newBeds = state.garden.beds.filter((_, i) => i !== bedIndex)

      // Re-map notes: drop notes for removed bed; shift indices for beds after it
      const oldNotes = state.garden.notes || {}
      const newNotes = {}
      Object.entries(oldNotes).forEach(([key, note]) => {
        const [bStr, cStr] = key.split('.')
        const b = parseInt(bStr, 10)
        const c = parseInt(cStr, 10)
        if (Number.isNaN(b) || Number.isNaN(c)) return
        if (b === bedIndex) return // drop
        if (b > bedIndex) {
          newNotes[`${b - 1}.${c}`] = note
        } else {
          newNotes[key] = note
        }
      })

      const newGarden = new Garden({ ...state.garden, beds: newBeds, notes: newNotes })
      const newState = pushToHistory(state, newGarden)

      // Adjust selection and activeBed
      const sel = state.selection
      let newSelection = sel
      if (sel?.bedIndex !== null && sel?.bedIndex !== undefined) {
        if (sel.bedIndex === bedIndex) {
          newSelection = { bedIndex: null, cellIndices: new Set() }
        } else if (sel.bedIndex > bedIndex) {
          newSelection = { bedIndex: sel.bedIndex - 1, cellIndices: sel.cellIndices }
        }
      }
      let newActiveBed = state.activeBed
      if (newActiveBed !== null && newActiveBed !== undefined) {
        if (newActiveBed === bedIndex) newActiveBed = null
        else if (newActiveBed > bedIndex) newActiveBed = newActiveBed - 1
      }

      return {
        ...newState,
        selection: newSelection,
        activeBed: newActiveBed,
      }
    }

    case GARDEN_ACTIONS.REORDER_BED: {
      const { fromIndex, toIndex } = action.payload
      if (fromIndex < 0 || fromIndex >= state.garden.beds.length) return state
      if (toIndex < 0 || toIndex >= state.garden.beds.length) return state
      if (fromIndex === toIndex) return state

      // Reorder beds array
      const newBeds = [...state.garden.beds]
      const [movedBed] = newBeds.splice(fromIndex, 1)
      newBeds.splice(toIndex, 0, movedBed)

      // Re-map notes: adjust all bed indices
      const oldNotes = state.garden.notes || {}
      const newNotes = {}
      Object.entries(oldNotes).forEach(([key, note]) => {
        const [bStr, cStr] = key.split('.')
        const oldBedIdx = parseInt(bStr, 10)
        const c = parseInt(cStr, 10)
        if (Number.isNaN(oldBedIdx) || Number.isNaN(c)) return
        
        // Calculate new bed index after reordering
        let newBedIdx = oldBedIdx
        if (oldBedIdx === fromIndex) {
          newBedIdx = toIndex
        } else if (fromIndex < toIndex) {
          // Moving down: beds between fromIndex+1 and toIndex shift up
          if (oldBedIdx > fromIndex && oldBedIdx <= toIndex) {
            newBedIdx = oldBedIdx - 1
          }
        } else {
          // Moving up: beds between toIndex and fromIndex-1 shift down
          if (oldBedIdx >= toIndex && oldBedIdx < fromIndex) {
            newBedIdx = oldBedIdx + 1
          }
        }
        newNotes[`${newBedIdx}.${c}`] = note
      })

      const newGarden = new Garden({ ...state.garden, beds: newBeds, notes: newNotes })
      const newState = pushToHistory(state, newGarden)

      // Adjust selection and activeBed
      const sel = state.selection
      let newSelection = sel
      if (sel?.bedIndex !== null && sel?.bedIndex !== undefined) {
        const oldBedIdx = sel.bedIndex
        let newBedIdx = oldBedIdx
        if (oldBedIdx === fromIndex) {
          newBedIdx = toIndex
        } else if (fromIndex < toIndex) {
          if (oldBedIdx > fromIndex && oldBedIdx <= toIndex) {
            newBedIdx = oldBedIdx - 1
          }
        } else {
          if (oldBedIdx >= toIndex && oldBedIdx < fromIndex) {
            newBedIdx = oldBedIdx + 1
          }
        }
        newSelection = { bedIndex: newBedIdx, cellIndices: sel.cellIndices }
      }

      let newActiveBed = state.activeBed
      if (newActiveBed !== null && newActiveBed !== undefined) {
        const oldBedIdx = newActiveBed
        if (oldBedIdx === fromIndex) {
          newActiveBed = toIndex
        } else if (fromIndex < toIndex) {
          if (oldBedIdx > fromIndex && oldBedIdx <= toIndex) {
            newActiveBed = oldBedIdx - 1
          }
        } else {
          if (oldBedIdx >= toIndex && oldBedIdx < fromIndex) {
            newActiveBed = oldBedIdx + 1
          }
        }
      }

      return {
        ...newState,
        selection: newSelection,
        activeBed: newActiveBed,
      }
    }

    case GARDEN_ACTIONS.UPDATE_CELL: {
      const { bedIndex, cellIndex, plantCode } = action.payload
      const bed = state.garden.getBed(bedIndex)
      const newBed = bed.setCell(cellIndex, plantCode)
      const newGarden = state.garden.updateBed(bedIndex, newBed)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.UPDATE_CELLS: {
      const { bedIndex, updates } = action.payload
      const bed = state.garden.getBed(bedIndex)
      const newBed = bed.setCells(updates)
      const newGarden = state.garden.updateBed(bedIndex, newBed)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.CLEAR_CELLS: {
      const { bedIndex, cellIndices } = action.payload
      const bed = state.garden.getBed(bedIndex)
      const newBed = bed.clearCells(cellIndices)
      let newGarden = state.garden.updateBed(bedIndex, newBed)
      
      // Also delete notes for cleared cells
      newGarden = newGarden.deleteNotes(bedIndex, cellIndices)
      
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.SET_NOTE: {
      const { bedIndex, cellIndex, note } = action.payload
      const newGarden = state.garden.setNote(bedIndex, cellIndex, note)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.DELETE_NOTES: {
      const { bedIndex, cellIndices } = action.payload
      const newGarden = state.garden.deleteNotes(bedIndex, cellIndices)
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.UPDATE_NOTES: {
      const updates = action.payload
      let newGarden = state.garden
      Object.entries(updates).forEach(([key, note]) => {
        const [bedIndex, cellIndex] = key.split('.').map(Number)
        newGarden = newGarden.setNote(bedIndex, cellIndex, note)
      })
      return pushToHistory(state, newGarden)
    }

    case GARDEN_ACTIONS.SET_SELECTION: {
      // Selecting bed cells should clear any palette selection and active bed (table) selection
      return {
        ...state,
        selection: action.payload,
        selectedPlant: null,
        activeBed: null,
      }
    }

    case GARDEN_ACTIONS.CLEAR_SELECTION: {
      return {
        ...state,
        selection: { bedIndex: null, cellIndices: new Set() }
      }
    }

    case GARDEN_ACTIONS.SET_SELECTED_PLANT: {
      // Selecting a palette crop clears any bed cell selection and table selection
      return {
        ...state,
        selectedPlant: action.payload,
        selection: { bedIndex: null, cellIndices: new Set() },
        activeBed: null,
      }
    }

    case GARDEN_ACTIONS.SET_ACTIVE_BED: {
      // Selecting a table clears palette crop selection and any cell selections
      return {
        ...state,
        activeBed: action.payload,
        selectedPlant: null,
        selection: { bedIndex: null, cellIndices: new Set() },
      }
    }

    case GARDEN_ACTIONS.UNDO: {
      if (state.historyIndex < 0) return state
      
      const newIndex = state.historyIndex - 1
      const garden = newIndex >= 0 ? state.history[newIndex] : createInitialGarden()
      
      return {
        ...state,
        garden,
        historyIndex: newIndex
      }
    }

    case GARDEN_ACTIONS.REDO: {
      if (state.historyIndex >= state.history.length - 1) return state
      
      const newIndex = state.historyIndex + 1
      const garden = state.history[newIndex]
      
      return {
        ...state,
        garden,
        historyIndex: newIndex
      }
    }

    default:
      return state
  }
}

// Helper: Add to history with limits
function pushToHistory(state, newGarden) {
  // Don't add if garden hasn't changed
  const currentJSON = JSON.stringify(state.garden.toJSON())
  const newJSON = JSON.stringify(newGarden.toJSON())
  if (currentJSON === newJSON) {
    return { ...state, garden: newGarden }
  }

  // Remove any redo history
  const newHistory = state.history.slice(0, state.historyIndex + 1)
  
  // Add new state
  newHistory.push(newGarden)
  
  // Limit history size
  if (newHistory.length > state.maxHistorySize) {
    newHistory.shift()
    return {
      ...state,
      garden: newGarden,
      history: newHistory,
      historyIndex: newHistory.length - 1
    }
  }
  
  return {
    ...state,
    garden: newGarden,
    history: newHistory,
    historyIndex: newHistory.length - 1
  }
}

// Context
const GardenStateContext = createContext(null)
const GardenDispatchContext = createContext(null)

// Provider Component
export function GardenProvider({ children }) {
  const [state, dispatch] = useReducer(gardenReducer, initialState)

  // Load from localStorage on mount
  useEffect(() => {
    const validPlantCodes = new Set(PLANTS.map(p => p.code))
    const savedGarden = StorageService.load(validPlantCodes)
    
    if (savedGarden) {
      dispatch({ type: GARDEN_ACTIONS.LOAD_GARDEN, payload: savedGarden })
    } else {
      dispatch({ type: GARDEN_ACTIONS.LOAD_GARDEN, payload: createInitialGarden() })
    }
  }, [])

  // Save to localStorage whenever garden changes
  useEffect(() => {
    if (state.isLoaded) {
      StorageService.save(state.garden)
    }
  }, [state.garden, state.isLoaded])

  return (
    <GardenStateContext.Provider value={state}>
      <GardenDispatchContext.Provider value={dispatch}>
        {children}
      </GardenDispatchContext.Provider>
    </GardenStateContext.Provider>
  )
}

// Hooks to use context
export function useGardenState() {
  const context = useContext(GardenStateContext)
  if (!context) {
    throw new Error('useGardenState must be used within GardenProvider')
  }
  return context
}

export function useGardenDispatch() {
  const context = useContext(GardenDispatchContext)
  if (!context) {
    throw new Error('useGardenDispatch must be used within GardenProvider')
  }
  return context
}

// Convenience hook for both
export function useGarden() {
  return {
    state: useGardenState(),
    dispatch: useGardenDispatch()
  }
}
