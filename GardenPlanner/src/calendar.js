import { PLANTS } from './data'

export function makeCalendarTasks(usedCodes, plants, lastFrostDate) {
  if (!lastFrostDate) return []
  const plantMap = new Map(plants.map(p => [p.code, p]))
  const out = []
  usedCodes.forEach(code => {
    const plant = plantMap.get(code)
    if (!plant) return
    if (plant.startIndoorsWeeks > 0) {
      const d = new Date(lastFrostDate)
      d.setDate(d.getDate() - plant.startIndoorsWeeks * 7)
      out.push({ date: d, type: 'indoor', icon: '🌱', plant, label: `Start ${plant.name} indoors (${plant.startIndoorsWeeks}w before frost)` })
    }
    const sow = new Date(lastFrostDate)
    sow.setDate(sow.getDate() + plant.plantAfterFrostDays)
    const desc = plant.plantAfterFrostDays < 0 ? `${Math.abs(plant.plantAfterFrostDays)}d before frost` : plant.plantAfterFrostDays === 0 ? 'at last frost' : `${plant.plantAfterFrostDays}d after frost`
    out.push({ date: sow, type: 'sow', icon: plant.startIndoorsWeeks>0 ? '🌿' : '🌱', plant, label: plant.startIndoorsWeeks>0 ? `Transplant ${plant.name} (${desc})` : `Sow ${plant.name} (${desc})` })
    const harvest = new Date(sow)
    harvest.setDate(harvest.getDate() + plant.harvestWeeks * 7)
    out.push({ date: harvest, type: 'harvest', icon: '🎉', plant, label: `Harvest ${plant.name} (~${plant.harvestWeeks}w after planting)` })
  })
  return out.sort((a,b)=> a.date-b.date)
}

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
