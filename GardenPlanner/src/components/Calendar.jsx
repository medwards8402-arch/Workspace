import React, { useMemo } from 'react'
import { useGardenOperations } from '../hooks/useGardenOperations'
import { USDA_ZONES, PLANTS } from '../data'
import { makeCalendarTasks, groupTasksByMonth } from '../calendar'

export function Calendar() {
  const { garden } = useGardenOperations()
  
  const lastFrost = useMemo(() => {
    const today = new Date()
    const z = USDA_ZONES[garden.zone]
    if (!z) return null
    let year = today.getFullYear()
    const d = new Date(year, z.month - 1, z.day)
    if (d < today) d.setFullYear(year + 1)
    return d
  }, [garden.zone])

  const usedCodes = useMemo(() => {
    return new Set(garden.uniquePlants)
  }, [garden])

  const tasks = useMemo(() => {
    return makeCalendarTasks(usedCodes, PLANTS, lastFrost)
  }, [usedCodes, lastFrost])

  const byMonth = useMemo(() => {
    return groupTasksByMonth(tasks)
  }, [tasks])

  if (!lastFrost) {
    return <div className="alert alert-warning">No frost date available.</div>
  }

  if (tasks.length === 0) {
    return <div className="alert alert-secondary">No plants added yet.</div>
  }

  return (
    <div className="row g-3">
      {[...byMonth.entries()].map(([key, { monthName, tasks }]) => (
        <div className="col-md-6 col-lg-4" key={key}>
          <div className="card h-100">
            <div className="card-header fw-bold py-2">{monthName}</div>
            <div className="card-body p-2">
              <div className="vstack gap-1">
                {tasks.map((t, i) => (
                  <div 
                    className={`d-flex align-items-center gap-2 p-1 rounded border-start border-3 ${
                      t.type==='indoor' ? 'border-success' : 
                      t.type==='sow' ? 'border-primary' : 
                      'border-warning'
                    }`} 
                    key={i} 
                    style={{fontSize: '0.875rem'}}
                  >
                    <span style={{fontSize: 16}}>{t.icon}</span>
                    <div 
                      className="rounded-circle flex-shrink-0" 
                      style={{width: 12, height: 12, background: t.plant.color}} 
                    />
                    <div className="flex-grow-1 d-flex justify-content-between align-items-center gap-2">
                      <span className="text-truncate">{t.label}</span>
                      <span className="text-secondary small text-nowrap">
                        {t.date.toLocaleDateString(undefined, {month:'short', day:'numeric'})}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}
