import { PLANTS } from './data'
import { makePlantTasksFromDates } from './schedule'

/**
 * Generate calendar tasks for planting and harvesting based on selected plants
 * @param {Set<string>} usedCodes - Set of plant codes currently used in beds
 * @param {Array} plants - Array of plant objects with timing metadata
 * @param {Date} lastFrostDate - The last frost date for the zone
 * @returns {Array} Sorted array of task objects with date, type, icon, plant, and label
 */
export function makeCalendarTasks(usedCodes, plants, lastFrostDate, firstFallFrostDate) {
  if (!lastFrostDate) return []
  const plantMap = new Map(plants.map(p => [p.code, p]))
  const out = []
  usedCodes.forEach(code => {
    const plant = plantMap.get(code)
    if (!plant) return

    // Use shared schedule logic to generate tasks consistently
    makePlantTasksFromDates(plant, lastFrostDate, firstFallFrostDate).forEach(t => out.push(t))
  })
  return out.sort((a,b)=> a.date-b.date)
}

/**
 * Group tasks by month for display in the calendar view
 * @param {Array} tasks - Array of task objects from makeCalendarTasks
 * @returns {Map} Map of tasks grouped by YYYY-MM key with monthName and tasks array
 */
export function groupTasksByMonth(tasks) {
  const map = new Map()
  tasks.forEach(t => {
    const key = `${t.date.getFullYear()}-${String(t.date.getMonth()+1).padStart(2,'0')}`
    const monthName = t.date.toLocaleDateString(undefined, { month: 'long', year: 'numeric' })
    if (!map.has(key)) map.set(key, { monthName, tasks: [] })
    map.get(key).tasks.push(t)
  })
  return map
}
