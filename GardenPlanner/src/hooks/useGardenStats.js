/**
 * Hook for getting derived data
 */
import { useGarden } from '../context/GardenContext'

export function useGardenStats() {
  const { state } = useGarden()
  const { garden } = state

  return {
    totalBeds: garden.beds.length,
    totalCells: garden.beds.reduce((sum, bed) => sum + bed.cells.length, 0),
    plantedCells: garden.allPlantedCells,
    uniquePlants: garden.uniquePlants,
    notesCount: Object.keys(garden.notes).length,
    zone: garden.zone,
  }
}
