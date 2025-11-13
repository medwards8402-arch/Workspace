import { USDA_ZONES } from './data'

// Compute zone anchor dates (next last spring frost and corresponding fall frost)
export function computeZoneKeyDates(zone, today = new Date()) {
  const z = USDA_ZONES[zone]
  if (!z) return { lastFrost: null, firstFallFrost: null }

  let year = today.getFullYear()
  // Next upcoming last frost for spring planning
  const lastFrost = new Date(year, z.month - 1, z.day)
  if (lastFrost < today) lastFrost.setFullYear(year + 1)

  // Fall frost in the same planning cycle year as lastFrost
  let firstFallFrost = null
  if (z.firstMonth && z.firstDay) {
    firstFallFrost = new Date(lastFrost.getFullYear(), z.firstMonth - 1, z.firstDay)
  }

  return { lastFrost, firstFallFrost }
}

// Spring schedule for a plant
export function computeSpringSchedule(plant, zone, today = new Date()) {
  const { lastFrost } = computeZoneKeyDates(zone, today)
  if (!lastFrost) return { indoor: null, sow: null, harvest: null }

  const sow = new Date(lastFrost)
  sow.setDate(sow.getDate() + plant.plantAfterFrostDays)

  const indoor = (plant.startIndoorsWeeks && plant.startIndoorsWeeks > 0)
    ? new Date(sow.getTime() - plant.startIndoorsWeeks * 7 * 24 * 60 * 60 * 1000)
    : null

  const harvest = (plant.harvestWeeks && plant.harvestWeeks > 0)
    ? new Date(sow.getTime() + plant.harvestWeeks * 7 * 24 * 60 * 60 * 1000)
    : null

  return { indoor, sow, harvest }
}

// Fall schedule for a plant
export function computeFallSchedule(plant, zone, today = new Date()) {
  if (!plant.supportsFall) return { indoor: null, sow: null, harvest: null }
  const { firstFallFrost } = computeZoneKeyDates(zone, today)
  if (!firstFallFrost) return { indoor: null, sow: null, harvest: null }

  const sow = new Date(firstFallFrost)
  sow.setDate(sow.getDate() - (plant.fallPlantBeforeFrostDays || 0))

  const indoor = (plant.fallStartIndoorsWeeks && plant.fallStartIndoorsWeeks > 0)
    ? new Date(sow.getTime() - plant.fallStartIndoorsWeeks * 7 * 24 * 60 * 60 * 1000)
    : null

  const harvest = (plant.harvestWeeks && plant.harvestWeeks > 0)
    ? new Date(sow.getTime() + plant.harvestWeeks * 7 * 24 * 60 * 60 * 1000)
    : null

  return { indoor, sow, harvest }
}

// Convenience: make task objects for calendar from a plant code
export function makePlantTasks(plant, zone, usedIndoorsIcon = '🌱') {
  const tasks = []
  const spring = computeSpringSchedule(plant, zone)
  if (spring.indoor) tasks.push({ date: spring.indoor, type: 'indoor', icon: '🌱', plant, label: `Start ${plant.name} indoors` })
  if (spring.sow) tasks.push({ date: spring.sow, type: 'sow', icon: spring.indoor ? '🌿' : '🌱', plant, label: spring.indoor ? `Transplant ${plant.name}` : `Sow ${plant.name}` })
  if (spring.harvest) tasks.push({ date: spring.harvest, type: 'harvest', icon: '🎉', plant, label: `Harvest ${plant.name}` })

  const fall = computeFallSchedule(plant, zone)
  if (fall.indoor) tasks.push({ date: fall.indoor, type: 'indoorFall', icon: '🌱', plant, label: `Start ${plant.name} indoors (fall)` })
  if (fall.sow) tasks.push({ date: fall.sow, type: 'sowFall', icon: fall.indoor ? '🌿' : '🌱', plant, label: fall.indoor ? `Transplant ${plant.name} (fall)` : `Sow ${plant.name} (fall)` })
  if (fall.harvest) tasks.push({ date: fall.harvest, type: 'harvestFall', icon: '🎉', plant, label: `Harvest ${plant.name} (fall)` })

  return tasks
}

// Variant: Build tasks using explicit anchor dates (for calendar)
export function makePlantTasksFromDates(plant, lastFrostDate, firstFallFrostDate) {
  const tasks = []
  if (lastFrostDate) {
    const sow = new Date(lastFrostDate)
    sow.setDate(sow.getDate() + plant.plantAfterFrostDays)
    if (plant.startIndoorsWeeks && plant.startIndoorsWeeks > 0) {
      const indoor = new Date(sow)
      indoor.setDate(indoor.getDate() - plant.startIndoorsWeeks * 7)
      tasks.push({ date: indoor, type: 'indoor', icon: '🌱', plant, label: `Start ${plant.name} indoors` })
    }
    tasks.push({ date: sow, type: 'sow', icon: (plant.startIndoorsWeeks && plant.startIndoorsWeeks > 0) ? '🌿' : '🌱', plant, label: (plant.startIndoorsWeeks && plant.startIndoorsWeeks > 0) ? `Transplant ${plant.name}` : `Sow ${plant.name}` })
    if (plant.harvestWeeks && plant.harvestWeeks > 0) {
      const harvest = new Date(sow)
      harvest.setDate(harvest.getDate() + plant.harvestWeeks * 7)
      tasks.push({ date: harvest, type: 'harvest', icon: '🎉', plant, label: `Harvest ${plant.name}` })
    }
  }

  if (firstFallFrostDate && plant.supportsFall) {
    const sowFall = new Date(firstFallFrostDate)
    sowFall.setDate(sowFall.getDate() - (plant.fallPlantBeforeFrostDays || 0))
    if (plant.fallStartIndoorsWeeks && plant.fallStartIndoorsWeeks > 0) {
      const indoorFall = new Date(sowFall)
      indoorFall.setDate(indoorFall.getDate() - plant.fallStartIndoorsWeeks * 7)
      tasks.push({ date: indoorFall, type: 'indoorFall', icon: '🌱', plant, label: `Start ${plant.name} indoors (fall)` })
    }
    tasks.push({ date: sowFall, type: 'sowFall', icon: (plant.fallStartIndoorsWeeks && plant.fallStartIndoorsWeeks > 0) ? '🌿' : '🌱', plant, label: (plant.fallStartIndoorsWeeks && plant.fallStartIndoorsWeeks > 0) ? `Transplant ${plant.name} (fall)` : `Sow ${plant.name} (fall)` })
    if (plant.harvestWeeks && plant.harvestWeeks > 0) {
      const harvestFall = new Date(sowFall)
      harvestFall.setDate(harvestFall.getDate() + plant.harvestWeeks * 7)
      tasks.push({ date: harvestFall, type: 'harvestFall', icon: '🎉', plant, label: `Harvest ${plant.name} (fall)` })
    }
  }

  return tasks
}
