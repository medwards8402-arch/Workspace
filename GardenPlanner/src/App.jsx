import React, { useEffect, useMemo, useState } from 'react'
import { BED_COLS, BED_COUNT, BED_ROWS, PLANTS, USDA_ZONES } from './data'
import { groupTasksByMonth, makeCalendarTasks } from './calendar'
import { PlantPalette } from './components/PlantPalette'
import { GardenBed } from './components/GardenBed'
import { devLog } from './utils'
import { STORAGE } from './constants'

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
      const raw = localStorage.getItem(STORAGE.KEY)
      if (!raw) {
        devLog('No saved state found, starting fresh')
        setIsLoaded(true)
        return
      }
      const data = JSON.parse(raw)
      devLog('Loading state from localStorage', { beds: data.beds?.length, zone: data.zone })
      
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
        console.warn('[GardenPlanner] Invalid plant codes in storage. Clearing...')
        localStorage.removeItem(STORAGE.KEY)
        setIsLoaded(true)
        return
      }
      if (Array.isArray(data?.beds)) setBeds(data.beds)
      if (typeof data?.zone === 'string') setZone(data.zone)
      devLog('State loaded successfully')
      // Don't load activeTab from storage; use URL hash instead
    } catch (e) {
      console.warn('[GardenPlanner] Failed to load state', e)
      localStorage.removeItem(STORAGE.KEY)
    }
    setIsLoaded(true)
  }, [])

  // save (don't save activeTab anymore, only beds and zone) - only save after initial load
  useEffect(() => {
    if (isLoaded) {
      const plantCount = beds.flat().filter(Boolean).length
      devLog('Saving state to localStorage', { beds: beds.length, zone, plantCount })
      localStorage.setItem(STORAGE.KEY, JSON.stringify({ beds, zone }))
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

function Beds({ beds, setBeds, plants, selectedCode, deselectTrigger, activeBed, setActiveBed }) {
  return (
    <div className="d-flex flex-wrap gap-3 justify-content-center">
      {beds.map((bed, idx) => (
        <div key={idx}>
          <GardenBed
            bedIndex={idx}
            bed={bed}
            onChange={(b) => setBeds(prev => prev.map((x, i) => (i === idx ? b : x)))}
            plants={plants}
            selectedCode={selectedCode}
            bedRows={BED_ROWS}
            bedCols={BED_COLS}
            deselectTrigger={deselectTrigger}
            activeBed={activeBed}
            setActiveBed={setActiveBed}
          />
        </div>
      ))}
    </div>
  );
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
    <div className="row g-3">
      {[...byMonth.entries()].map(([key, { monthName, tasks }]) => (
        <div className="col-md-6 col-lg-4" key={key}>
          <div className="card h-100">
            <div className="card-header fw-bold py-2">{monthName}</div>
            <div className="card-body p-2">
              <div className="vstack gap-1">
                {tasks.map((t, i) => (
                  <div className={`d-flex align-items-center gap-2 p-1 rounded border-start border-3 ${t.type==='indoor'?'border-success':t.type==='sow'?'border-primary':'border-warning'}`} key={i} style={{fontSize: '0.875rem'}}>
                    <span style={{fontSize: 16}}>{t.icon}</span>
                    <div className="rounded-circle flex-shrink-0" style={{width: 12, height: 12, background: t.plant.color}} />
                    <div className="flex-grow-1 d-flex justify-content-between align-items-center gap-2">
                      <span className="text-truncate">{t.label}</span>
                      <span className="text-secondary small text-nowrap">{t.date.toLocaleDateString(undefined,{month:'short', day:'numeric'})}</span>
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

export default function App() {
  const { beds, setBeds, zone, setZone, activeTab, setActiveTab } = usePersistentState();
  const [selectedCode, setSelectedCode] = useState(null);
  const [deselectTrigger, setDeselectTrigger] = useState(0);
  const [activeBed, setActiveBed] = useState(null);

  const plants = PLANTS;

  // Click-away deselection - clear palette selection and bed selections
  const handleContainerClick = (e) => {
    setSelectedCode(null);
    setDeselectTrigger(prev => prev + 1); // Increment to trigger deselection in beds
    setActiveBed(null);
  };

  return (
    <div style={{ minHeight: '100vh' }} onClick={handleContainerClick}>
      <div className="container py-3">
        <header className="d-flex align-items-center justify-content-between mb-3">
          <h1 className="h4 m-0">Garden Planner</h1>
          <ZoneSelector zone={zone} setZone={setZone} />
        </header>

        <ul className="nav nav-pills mb-3">
          <li className="nav-item"><button className={`nav-link ${activeTab === 'plan' ? 'active' : ''}`} onClick={(e) => { e.stopPropagation(); setActiveTab('plan'); }}>Garden Plan</button></li>
          <li className="nav-item"><button className={`nav-link ${activeTab === 'calendar' ? 'active' : ''}`} onClick={(e) => { e.stopPropagation(); setActiveTab('calendar'); }}>Planting Calendar</button></li>
        </ul>

        {activeTab === 'plan' && (
          <div className="row g-3">
            <div className="col-md-2">
              <PlantPalette plants={plants} selectedCode={selectedCode} onSelect={setSelectedCode} />
            </div>
            <div className="col-md-10">
              <Beds
                beds={beds}
                plants={plants}
                setBeds={setBeds}
                selectedCode={selectedCode}
                deselectTrigger={deselectTrigger}
                activeBed={activeBed}
                setActiveBed={setActiveBed}
              />
            </div>
          </div>
        )}

        {activeTab === 'calendar' && (
          <Calendar beds={beds} plants={plants} zone={zone} />
        )}
      </div>
    </div>
  );
}
