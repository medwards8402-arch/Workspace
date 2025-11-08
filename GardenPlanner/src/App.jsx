import React, { useEffect, useMemo, useRef, useState } from 'react'
import { BED_COLS, BED_COUNT, BED_ROWS, PLANTS, USDA_ZONES } from './data'
import { groupTasksByMonth, makeCalendarTasks } from './calendar'

const STORAGE_KEY = 'gardenPlannerState'

function usePersistentState() {
  const [beds, setBeds] = useState(Array.from({ length: BED_COUNT }, () => Array.from({ length: BED_ROWS * BED_COLS }, () => null)))
  const [zone, setZone] = useState('5a')
  const [activeTab, setActiveTab] = useState('plan')

  // load
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (!raw) return
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
        return
      }
      if (Array.isArray(data?.beds)) setBeds(data.beds)
      if (typeof data?.zone === 'string') setZone(data.zone)
      if (typeof data?.activeTab === 'string') setActiveTab(data.activeTab)
    } catch (e) {
      console.warn('Failed to load state', e)
      localStorage.removeItem(STORAGE_KEY)
    }
  }, [])

  // save
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ beds, zone, activeTab }))
  }, [beds, zone, activeTab])

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
        <select className="form-select" value={zone} onChange={e => setZone(e.target.value)}>
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

function PlantPalette({ plants, selectedCode, onSelect }) {
  const groups = useMemo(() => {
    return plants.slice().sort((a,b) => a.name.localeCompare(b.name))
  }, [plants])
  return (
    <div className="card h-100">
      <div className="card-header">Plant Palette</div>
      <div className="list-group list-group-flush overflow-auto" style={{maxHeight: '70vh'}}>
        {groups.map(p => (
          <button key={p.code} className={`list-group-item list-group-item-action d-flex align-items-center gap-2 ${selectedCode===p.code?'active':''}`}
            onClick={() => onSelect(p.code)} draggable
            onDragStart={e => { e.dataTransfer.setData('text/plain', p.code) }}>
            <span style={{fontSize: 22}}>{p.icon}</span>
            <span className="fw-semibold">{p.name}</span>
            <span className="ms-auto text-secondary">{p.code}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

function Cell({ plant, onDrop, onClick, selected }) {
  return (
    <div className={`border rounded-3 d-flex flex-column align-items-center justify-content-center position-relative`} 
         style={{width: 68, height: 68, background: '#0b0f1a', borderStyle: 'dashed'}}
         onDragOver={e => { e.preventDefault(); e.dataTransfer.dropEffect='copy' }}
         onDrop={onDrop}
         onClick={onClick}>
      {plant && <>
        <div style={{fontSize: 26, lineHeight: 1}}>{plant.icon}</div>
        <div className="small text-light text-center" style={{lineHeight: 1.1}}>{plant.name}</div>
      </>}
      {selected && <div className="position-absolute w-100 h-100 rounded-3" style={{outline: '2px solid var(--bs-primary)', outlineOffset: 2}} />}
    </div>
  )
}

function Bed({ index, bed, setBed, plants }) {
  const [selectedIndices, setSelectedIndices] = useState(new Set())
  const gridRef = useRef(null)

  useEffect(() => { setSelectedIndices(new Set()) }, [bed])

  const handleDropAt = (i, code) => {
    const next = bed.slice()
    next[i] = code
    setBed(next)
  }

  return (
    <div className="card">
      <div className="card-header">Bed {index+1}</div>
      <div className="card-body">
        <div ref={gridRef} className="d-grid gap-2 mx-auto" style={{gridTemplateColumns: `repeat(${BED_COLS}, 68px)`, width: 'fit-content'}}>
          {bed.map((code, i) => {
            const plant = plants.find(p => p.code === code)
            return (
              <Cell key={i} plant={plant} selected={selectedIndices.has(i)}
                onDrop={(e) => { e.preventDefault(); const c = e.dataTransfer.getData('text/plain'); if (c) handleDropAt(i,c) }}
                onClick={() => { setSelectedIndices(new Set([i])) }} />
            )
          })}
        </div>
      </div>
    </div>
  )
}

function Beds({ beds, setBeds, plants }) {
  return (
    <div className="row g-3">
      {beds.map((bed, idx) => (
        <div className="col-md-4" key={idx}>
          <Bed index={idx} bed={bed} setBed={(b) => setBeds(prev => prev.map((x,i)=> i===idx? b : x))} plants={plants} />
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

  const plants = PLANTS

  return (
    <div className="container py-3">
      <header className="d-flex align-items-center justify-content-between mb-3">
        <h1 className="h4 m-0">Garden Planner</h1>
        <ZoneSelector zone={zone} setZone={setZone} />
      </header>

      <ul className="nav nav-pills mb-3">
        <li className="nav-item"><button className={`nav-link ${activeTab==='plan'?'active':''}`} onClick={()=>setActiveTab('plan')}>Garden Plan</button></li>
        <li className="nav-item"><button className={`nav-link ${activeTab==='calendar'?'active':''}`} onClick={()=>setActiveTab('calendar')}>Planting Calendar</button></li>
      </ul>

      {activeTab==='plan' && (
        <div className="row g-3">
          <div className="col-md-3">
            <PlantPalette plants={plants} selectedCode={selectedCode} onSelect={setSelectedCode} />
          </div>
          <div className="col-md-9">
            <Beds beds={beds} plants={plants} setBeds={setBeds} />
          </div>
        </div>
      )}

      {activeTab==='calendar' && (
        <Calendar beds={beds} plants={plants} zone={zone} />
      )}
    </div>
  )
}
