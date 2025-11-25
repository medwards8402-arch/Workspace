/**
 * Calendar Service - handles planting schedule calculations
 */
export class CalendarService {
  /**
   * Calculate planting date for a plant
   */
  static calculatePlantingDate(plant, lastFrostDate) {
    const frostDate = new Date(lastFrostDate)
    const plantDate = new Date(frostDate)
    plantDate.setDate(plantDate.getDate() + (plant.plantAfterFrostDays || 0))
    return plantDate
  }

  /**
   * Calculate indoor start date
   */
  static calculateIndoorStartDate(plant, lastFrostDate) {
    if (!plant.startIndoorsWeeks || plant.startIndoorsWeeks === 0) {
      return null
    }
    const plantDate = this.calculatePlantingDate(plant, lastFrostDate)
    const startDate = new Date(plantDate)
    startDate.setDate(startDate.getDate() - (plant.startIndoorsWeeks * 7))
    return startDate
  }

  /**
   * Calculate harvest date
   */
  static calculateHarvestDate(plant, lastFrostDate) {
    const plantDate = this.calculatePlantingDate(plant, lastFrostDate)
    const harvestDate = new Date(plantDate)
    harvestDate.setDate(harvestDate.getDate() + (plant.harvestWeeks || 0) * 7)
    return harvestDate
  }

  /**
   * Generate all calendar tasks for a garden
   */
  static generateTasks(garden, plantsData, lastFrostDate) {
    const tasks = []
    const plantCodes = garden.uniquePlants

    plantCodes.forEach(code => {
      const plant = plantsData.find(p => p.code === code)
      if (!plant) return

      // Indoor start task
      const indoorDate = this.calculateIndoorStartDate(plant, lastFrostDate)
      if (indoorDate) {
        tasks.push({
          type: 'indoor',
          plant,
          date: indoorDate,
          label: `Start ${plant.name} indoors`,
          icon: plant.icon
        })
      }

      // Planting task
      const plantDate = this.calculatePlantingDate(plant, lastFrostDate)
      tasks.push({
        type: 'sow',
        plant,
        date: plantDate,
        label: indoorDate ? `Transplant ${plant.name}` : `Sow ${plant.name}`,
        icon: plant.icon
      })

      // Harvest task
      const harvestDate = this.calculateHarvestDate(plant, lastFrostDate)
      tasks.push({
        type: 'harvest',
        plant,
        date: harvestDate,
        label: `Harvest ${plant.name}`,
        icon: plant.icon
      })
    })

    return tasks.sort((a, b) => a.date - b.date)
  }

  /**
   * Group tasks by month
   */
  static groupByMonth(tasks) {
    const groups = {}
    
    tasks.forEach(task => {
      const monthKey = `${task.date.getFullYear()}-${task.date.getMonth()}`
      if (!groups[monthKey]) {
        groups[monthKey] = {
          year: task.date.getFullYear(),
          month: task.date.getMonth(),
          tasks: []
        }
      }
      groups[monthKey].tasks.push(task)
    })

    return Object.values(groups).sort((a, b) => {
      if (a.year !== b.year) return a.year - b.year
      return a.month - b.month
    })
  }
}
