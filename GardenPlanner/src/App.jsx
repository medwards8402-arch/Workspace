import React, { useEffect, useMemo, useState } from 'react'
import { BED_COLS, BED_COUNT, BED_ROWS, PLANTS, USDA_ZONES } from './data'
import { groupTasksByMonth, makeCalendarTasks } from './calendar'
import { PlantPalette } from './components/PlantPalette'
import { GardenBed } from './components/GardenBed'

const STORAGE_KEY = 'gardenPlannerState'

function usePersistentState() {
  const [isLoaded, setIsLoaded] = useState(false)
  const [beds, setBeds] = useState(Array.from({ length: BED_COUNT }, () => Array.from({ length: BED_ROWS * BED_COLS }, () => null)))
  const [zone, setZone] = useState('5a')
  const [activeTab, setActiveTab] = useState(() => {
    // Read from URL hash on mount
    const hash = window.location.hash.slice(1)
    return hash === 'calendar' ? 'calendar' : 'plan'
  })

  // load
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (!raw) {
        setIsLoaded(true)
        return
      }
      const data = JSON.parse(raw)
      // validate codes
      const allCodes = new Set(PLANTS.map(p => p.code))
      let invalid = false
      if (Array.isArray(data?.beds)) {
        for (const bed of data.beds) {
          if (!Array.isArray(bed)) continue
          for (const code of bed) {
            if (code && !allCodes.has(code)) { invalid = true; break }
          }
          if (invalid) break
        }
      }
      if (invalid) {
        console.warn('Invalid plant codes in storage. Clearing...')
        localStorage.removeItem(STORAGE_KEY)
        setIsLoaded(true)
        return
      }
      if (Array.isArray(data?.beds)) setBeds(data.beds)
      if (typeof data?.zone === 'string') setZone(data.zone)
      // Don't load activeTab from storage; use URL hash instead
    } catch (e) {
      console.warn('Failed to load state', e)
      localStorage.removeItem(STORAGE_KEY)
    }
    setIsLoaded(true)
  }, [])

  // save (don't save activeTab anymore, only beds and zone) - only save after initial load
  useEffect(() => {
    if (isLoaded) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ beds, zone }))
    }
  }, [beds, zone, isLoaded])

  // sync URL hash when activeTab changes
  useEffect(() => {
    window.location.hash = activeTab
  }, [activeTab])

  return { beds, setBeds, zone, setZone, activeTab, setActiveTab }
}

function ZoneSelector({ zone, setZone }) {
  const frost = useMemo(() => {
    const today = new Date()
    const z = USDA_ZONES[zone]
    if (!z) return ''
    let year = today.getFullYear()
    const d = new Date(year, z.month - 1, z.day)
    if (d < today) d.setFullYear(year + 1)
    return d.toISOString().slice(0, 10)
  }, [zone])
  return (
    <div className="d-flex align-items-center gap-2 flex-wrap">
      <div className="input-group w-auto">
        <span className="input-group-text">USDA Zone</span>
        <select className="form-select" value={zone} onChange={e => setZone(e.target.value)} onClick={(e) => e.stopPropagation()}>
          {Object.keys(USDA_ZONES).map(z => <option key={z} value={z}>{z}</option>)}
        </select>
      </div>
      <div className="input-group w-auto">
        <span className="input-group-text">Last Frost</span>
        <input className="form-control" readOnly value={frost} />
      </div>
    </div>
  )
}

function Beds({ beds, setBeds, plants, selectedCode, deselectTrigger }) {
  return (
    <div className="row g-3">
      {beds.map((bed, idx) => (
        <div className="col-md-4" key={idx}>
          <GardenBed 
            bedIndex={idx} 
            bed={bed} 
            onChange={(b) => setBeds(prev => prev.map((x,i)=> i===idx? b : x))} 
            plants={plants} 
            selectedCode={selectedCode}
            bedRows={BED_ROWS}
            bedCols={BED_COLS}
            deselectTrigger={deselectTrigger}
          />
        </div>
      ))}
    </div>
  )
}

function Calendar({ beds, plants, zone }) {
  const lastFrost = useMemo(() => {
    const today = new Date()
    const z = USDA_ZONES[zone]
    if (!z) return null
    let year = today.getFullYear()
    const d = new Date(year, z.month - 1, z.day)
    if (d < today) d.setFullYear(year + 1)
    return d
  }, [zone])

  const usedCodes = useMemo(() => new Set(beds.flat().filter(Boolean)), [beds])
  const tasks = useMemo(() => makeCalendarTasks(usedCodes, plants, lastFrost), [usedCodes, plants, lastFrost])
  const byMonth = useMemo(() => groupTasksByMonth(tasks), [tasks])

  if (!lastFrost) return <div className="alert alert-warning">No frost date available.</div>
  if (tasks.length === 0) return <div className="alert alert-secondary">No plants added yet.</div>

  return (
    <div className="vstack gap-3">
      {[...byMonth.entries()].map(([key, { monthName, tasks }]) => (
        <div className="card" key={key}>
          <div className="card-header fw-bold">{monthName}</div>
          <div className="list-group list-group-flush">
            {tasks.map((t, i) => (
              <div className={`list-group-item d-flex align-items-center gap-2 border-start border-3 ${t.type==='indoor'?'border-success':t.type==='sow'?'border-primary':'border-warning'}`} key={i}>
                <div style={{fontSize: 20, width: 28, textAlign: 'center'}}>{t.icon}</div>
                <div className="rounded-circle" style={{width: 18, height: 18, background: t.plant.color}} />
                <div className="ms-2">
                  <div className="fw-bold small text-uppercase text-secondary">{t.date.toLocaleDateString(undefined,{month:'short', day:'numeric'})}</div>
                  <div>{t.label}</div>
                </div>
                <div className="ms-auto text-secondary">{t.plant.name}</div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}

export default function App() {
  const { beds, setBeds, zone, setZone, activeTab, setActiveTab } = usePersistentState()
  const [selectedCode, setSelectedCode] = useState(null)
  const [deselectTrigger, setDeselectTrigger] = useState(0)

  const plants = PLANTS

  // Click-away deselection - clear palette selection and bed selections
  const handleContainerClick = (e) => {
    setSelectedCode(null)
    setDeselectTrigger(prev => prev + 1) // Increment to trigger deselection in beds
  }

  return (
    <div style={{minHeight: '100vh'}} onClick={handleContainerClick}>
      <div className="container py-3">
        <header className="d-flex align-items-center justify-content-between mb-3">
          <h1 className="h4 m-0">Garden Planner</h1>
          <ZoneSelector zone={zone} setZone={setZone} />
        </header>

        <ul className="nav nav-pills mb-3">
          <li className="nav-item"><button className={`nav-link ${activeTab==='plan'?'active':''}`} onClick={(e)=>{e.stopPropagation(); setActiveTab('plan')}}>Garden Plan</button></li>
          <li className="nav-item"><button className={`nav-link ${activeTab==='calendar'?'active':''}`} onClick={(e)=>{e.stopPropagation(); setActiveTab('calendar')}}>Planting Calendar</button></li>
        </ul>

        {activeTab==='plan' && (
          <div className="row g-3">
            <div className="col-md-2">
              <PlantPalette plants={plants} selectedCode={selectedCode} onSelect={setSelectedCode} />
            </div>
            <div className="col-md-10">
              <Beds beds={beds} plants={plants} setBeds={setBeds} selectedCode={selectedCode} deselectTrigger={deselectTrigger} />
            </div>
          </div>
        )}

        {activeTab==='calendar' && (
          <Calendar beds={beds} plants={plants} zone={zone} />
        )}
      </div>
    </div>
  )
}
