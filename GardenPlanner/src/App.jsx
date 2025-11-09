import React, { useEffect, useMemo, useState, useCallback } from 'react'
import { BED_COLS, BED_COUNT, BED_ROWS, PLANTS, USDA_ZONES } from './data'
import { groupTasksByMonth, makeCalendarTasks } from './calendar'
import { PlantPalette } from './components/PlantPalette'
import { GardenBed } from './components/GardenBed'
import { NewGarden } from './components/NewGarden'
import { PlantInfo } from './components/PlantInfo'
import { devLog, generateGarden } from './utils'
import { STORAGE } from './constants'

function usePersistentState() {
  const [isLoaded, setIsLoaded] = useState(false)
  const [bedCount, setBedCount] = useState(BED_COUNT)
  const [bedRows, setBedRows] = useState(BED_ROWS)
  const [bedCols, setBedCols] = useState(BED_COLS)
  const [beds, setBeds] = useState(Array.from({ length: BED_COUNT }, () => Array.from({ length: BED_ROWS * BED_COLS }, () => null)))
  const [bedLightLevels, setBedLightLevels] = useState(Array.from({ length: BED_COUNT }, (_, i) => {
    // Bed 1: high, Bed 2: medium, Bed 3: low, rest: high
    if (i === 1) return 'medium'
    if (i === 2) return 'low'
    return 'high'
  }))
  const [zone, setZone] = useState('5a')
  const [notes, setNotes] = useState({}) // keyed by 'bedIndex.cellIndex'
  const [activeTab, setActiveTab] = useState(() => {
    // Read from URL hash on mount
    const hash = window.location.hash.slice(1)
    if (hash === 'calendar') return 'calendar'
    if (hash === 'plan') return 'plan'
    return 'new-garden' // Default to new-garden tab
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
      devLog('Loading state from localStorage', { beds: data.beds?.length, zone: data.zone, bedConfig: `${data.bedCount}×${data.bedRows}×${data.bedCols}` })
      
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
      
      // Load garden configuration
      if (typeof data?.bedCount === 'number' && data.bedCount > 0) setBedCount(data.bedCount)
      if (typeof data?.bedRows === 'number' && data.bedRows > 0) setBedRows(data.bedRows)
      if (typeof data?.bedCols === 'number' && data.bedCols > 0) setBedCols(data.bedCols)
      
      // Load bed light levels (or generate defaults if missing)
      if (Array.isArray(data?.bedLightLevels) && data.bedLightLevels.length > 0) {
        setBedLightLevels(data.bedLightLevels)
      } else {
        // Generate default varied light levels if not in saved data
        const defaultLightLevels = Array.from({ length: data?.bedCount || BED_COUNT }, (_, i) => {
          if (i === 1) return 'medium'
          if (i === 2) return 'low'
          return 'high'
        })
        setBedLightLevels(defaultLightLevels)
      }
      
      // Load beds array (migrate if needed)
      if (Array.isArray(data?.beds)) {
        setBeds(data.beds)
      }
      
      // Load notes
      if (data?.notes && typeof data.notes === 'object') {
        setNotes(data.notes)
      }
      
      if (typeof data?.zone === 'string') setZone(data.zone)
      devLog('State loaded successfully')
      // Don't load activeTab from storage; use URL hash instead
    } catch (e) {
      console.warn('[GardenPlanner] Failed to load state', e)
      localStorage.removeItem(STORAGE.KEY)
    }
    setIsLoaded(true)
  }, [])

  // save (don't save activeTab anymore, save beds, zone, notes, and garden config) - only save after initial load
  useEffect(() => {
    if (isLoaded) {
      const plantCount = beds.flat().filter(Boolean).length
      const noteCount = Object.keys(notes).length
      devLog('Saving state to localStorage', { beds: beds.length, zone, plantCount, noteCount, bedConfig: `${bedCount}×${bedRows}×${bedCols}` })
      localStorage.setItem(STORAGE.KEY, JSON.stringify({ beds, zone, notes, bedCount, bedRows, bedCols, bedLightLevels }))
    }
  }, [beds, zone, notes, bedCount, bedRows, bedCols, bedLightLevels, isLoaded])

  // sync URL hash when activeTab changes
  useEffect(() => {
    window.location.hash = activeTab
  }, [activeTab])

  return { beds, setBeds, zone, setZone, activeTab, setActiveTab, bedCount, setBedCount, bedRows, setBedRows, bedCols, setBedCols, notes, setNotes, bedLightLevels, setBedLightLevels }
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
        <span className="input-group-text" title="USDA Hardiness Zone for your location">USDA Zone</span>
        <select className="form-select" value={zone} onChange={e => setZone(e.target.value)} onClick={(e) => e.stopPropagation()} title="Select your USDA hardiness zone to calculate planting dates">
          {Object.keys(USDA_ZONES).map(z => <option key={z} value={z}>{z}</option>)}
        </select>
      </div>
      <div className="input-group w-auto">
        <span className="input-group-text" title="Average last frost date for your zone">Last Frost</span>
        <input className="form-control" readOnly value={frost} title={`Average last frost date for zone ${zone}`} />
      </div>
    </div>
  )
}

function Beds({ beds, setBeds, plants, selectedCode, deselectTrigger, activeBed, setActiveBed, bedRows, bedCols, notes, setNotes, onSelectionChange, bedLightLevels }) {
  // Handle note changes from PlantInfo panels
  const handleNotesChange = (updates) => {
    setNotes(prev => ({ ...prev, ...updates }))
  }

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
            bedRows={bedRows}
            bedCols={bedCols}
            deselectTrigger={deselectTrigger}
            activeBed={activeBed}
            setActiveBed={setActiveBed}
            notes={notes}
            onNotesChange={handleNotesChange}
            onSelectionChange={onSelectionChange}
            lightLevel={bedLightLevels?.[idx] || 'high'}
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
  const { beds, setBeds, zone, setZone, activeTab, setActiveTab, bedCount, setBedCount, bedRows, setBedRows, bedCols, setBedCols, notes, setNotes, bedLightLevels, setBedLightLevels } = usePersistentState();
  const [selectedCode, setSelectedCode] = useState(null);
  const [deselectTrigger, setDeselectTrigger] = useState(0);
  const [activeBed, setActiveBed] = useState(null);
  
  // Track current selection for PlantInfo panel
  const [currentSelection, setCurrentSelection] = useState({ bedIndex: null, selectedIndices: new Set() })
  
  // Undo/Redo state - circular buffer with max 10 items
  const [history, setHistory] = useState([])
  const [historyIndex, setHistoryIndex] = useState(-1)

  const plants = PLANTS;
  
  // Handle selection changes from beds (memoized to prevent unnecessary re-renders)
  const handleSelectionChange = useCallback((bedIndex, selectedIndices) => {
    setCurrentSelection({ bedIndex, selectedIndices })
  }, [])
  
  // Handle note changes from PlantInfo panel
  const handleNotesChange = (updates) => {
    setNotesWithHistory(prev => ({ ...prev, ...updates }))
  }
  
  // Push a new state snapshot to history (for undo/redo)
  const pushHistory = (type, oldState, newState) => {
    const entry = {
      type, // 'beds' or 'notes'
      oldState,
      newState,
      timestamp: Date.now()
    }
    
    // Remove any redo history if we're not at the end
    const newHistory = history.slice(0, historyIndex + 1)
    
    // Add new entry
    newHistory.push(entry)
    
    // Keep only last 10 entries
    if (newHistory.length > 10) {
      newHistory.shift()
    } else {
      setHistoryIndex(prev => prev + 1)
    }
    
    setHistory(newHistory)
    if (newHistory.length === 10) {
      setHistoryIndex(9) // Stay at max index
    }
  }
  
  // Wrapped setBeds that tracks history
  const setBedsWithHistory = (newBedsOrFunc) => {
    setBeds(prev => {
      const newBeds = typeof newBedsOrFunc === 'function' ? newBedsOrFunc(prev) : newBedsOrFunc
      if (JSON.stringify(prev) !== JSON.stringify(newBeds)) {
        pushHistory('beds', prev, newBeds)
      }
      return newBeds
    })
  }
  
  // Wrapped setNotes that tracks history
  const setNotesWithHistory = (newNotesOrFunc) => {
    setNotes(prev => {
      const newNotes = typeof newNotesOrFunc === 'function' ? newNotesOrFunc(prev) : newNotesOrFunc
      if (JSON.stringify(prev) !== JSON.stringify(newNotes)) {
        pushHistory('notes', prev, newNotes)
      }
      return newNotes
    })
  }
  
  // Undo function
  const handleUndo = () => {
    if (historyIndex < 0) return
    
    const entry = history[historyIndex]
    if (entry.type === 'beds') {
      setBeds(entry.oldState)
    } else if (entry.type === 'notes') {
      setNotes(entry.oldState)
    }
    
    setHistoryIndex(prev => prev - 1)
    devLog('Undo', { type: entry.type, historyIndex: historyIndex - 1 })
  }
  
  // Redo function
  const handleRedo = () => {
    if (historyIndex >= history.length - 1) return
    
    const entry = history[historyIndex + 1]
    if (entry.type === 'beds') {
      setBeds(entry.newState)
    } else if (entry.type === 'notes') {
      setNotes(entry.newState)
    }
    
    setHistoryIndex(prev => prev + 1)
    devLog('Redo', { type: entry.type, historyIndex: historyIndex + 1 })
  }
  
  // Keyboard shortcuts for undo/redo
  useEffect(() => {
    const handleKeyDown = (e) => {
      // Ctrl+Z for undo (Cmd+Z on Mac)
      if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault()
        handleUndo()
      }
      // Ctrl+Y or Ctrl+Shift+Z for redo
      if ((e.ctrlKey || e.metaKey) && (e.key === 'y' || (e.key === 'z' && e.shiftKey))) {
        e.preventDefault()
        handleRedo()
      }
    }
    
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [historyIndex, history]) // Re-bind when history changes

  // Handle garden generation from NewGarden tab
  const handleGenerateGarden = (selectedPlantCodes) => {
    const newBeds = generateGarden(selectedPlantCodes, plants, bedCount, bedRows, bedCols, bedLightLevels)
    setBedsWithHistory(newBeds)
    devLog('Generated garden', { plantCount: selectedPlantCodes.length, bedCount, bedRows, bedCols })
    // Switch to plan tab to view the generated garden
    setActiveTab('plan')
  }
  
  // Save garden to file
  const handleSaveToFile = () => {
    const gardenData = {
      version: '1.0',
      beds,
      notes,
      bedCount,
      bedRows,
      bedCols,
      bedLightLevels,
      zone,
      timestamp: new Date().toISOString()
    }
    
    const dataStr = JSON.stringify(gardenData, null, 2)
    const dataBlob = new Blob([dataStr], { type: 'application/json' })
    const url = URL.createObjectURL(dataBlob)
    const link = document.createElement('a')
    link.href = url
    link.download = `garden-${new Date().toISOString().split('T')[0]}.gardplan`
    link.click()
    URL.revokeObjectURL(url)
    devLog('Garden saved to file', { bedCount, noteCount: Object.keys(notes).length })
  }
  
  // Load garden from file
  const handleLoadFromFile = () => {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = '.gardplan'
    input.onchange = (e) => {
      const file = e.target.files[0]
      if (!file) return
      
      const reader = new FileReader()
      reader.onload = (event) => {
        try {
          const gardenData = JSON.parse(event.target.result)
          
          // Validate data structure
          if (!gardenData.beds || !Array.isArray(gardenData.beds)) {
            alert('Invalid garden file format')
            return
          }
          
          // Load garden data
          setBeds(gardenData.beds)
          setNotes(gardenData.notes || {})
          setBedCount(gardenData.bedCount || BED_COUNT)
          setBedRows(gardenData.bedRows || BED_ROWS)
          setBedCols(gardenData.bedCols || BED_COLS)
          setBedLightLevels(gardenData.bedLightLevels || Array.from({ length: gardenData.bedCount || BED_COUNT }, (_, i) => {
            // Bed 1: high, Bed 2: medium, Bed 3: low, rest: high
            if (i === 1) return 'medium'
            if (i === 2) return 'low'
            return 'high'
          }))
          setZone(gardenData.zone || '5a')
          
          devLog('Garden loaded from file', { bedCount: gardenData.bedCount, noteCount: Object.keys(gardenData.notes || {}).length })
          alert('Garden loaded successfully!')
        } catch (error) {
          console.error('Failed to load garden file:', error)
          alert('Failed to load garden file. Please check the file format.')
        }
      }
      reader.readAsText(file)
    }
    input.click()
  }

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
          <div className="d-flex align-items-center gap-3">
            <div className="btn-group" role="group">
              <button
                className="btn btn-sm btn-outline-primary"
                onClick={(e) => { e.stopPropagation(); handleSaveToFile(); }}
                title="Save garden to file"
              >
                💾 Save
              </button>
              <button
                className="btn btn-sm btn-outline-primary"
                onClick={(e) => { e.stopPropagation(); handleLoadFromFile(); }}
                title="Load garden from file"
              >
                📂 Load
              </button>
            </div>
            <div className="btn-group" role="group">
              <button
                className="btn btn-sm btn-outline-secondary"
                onClick={(e) => { e.stopPropagation(); handleUndo(); }}
                disabled={historyIndex < 0}
                title="Undo (Ctrl+Z)"
              >
                ↶ Undo
              </button>
              <button
                className="btn btn-sm btn-outline-secondary"
                onClick={(e) => { e.stopPropagation(); handleRedo(); }}
                disabled={historyIndex >= history.length - 1}
                title="Redo (Ctrl+Y)"
              >
                ↷ Redo
              </button>
            </div>
            <ZoneSelector zone={zone} setZone={setZone} />
          </div>
        </header>

        <ul className="nav nav-pills mb-3">
          <li className="nav-item"><button className={`nav-link ${activeTab === 'new-garden' ? 'active' : ''}`} onClick={(e) => { e.stopPropagation(); setActiveTab('new-garden'); }} title="Configure and generate a new garden layout">New Garden</button></li>
          <li className="nav-item"><button className={`nav-link ${activeTab === 'plan' ? 'active' : ''}`} onClick={(e) => { e.stopPropagation(); setActiveTab('plan'); }} title="Edit and view your garden layout">Garden Plan</button></li>
          <li className="nav-item"><button className={`nav-link ${activeTab === 'calendar' ? 'active' : ''}`} onClick={(e) => { e.stopPropagation(); setActiveTab('calendar'); }} title="View planting schedule by month">Planting Calendar</button></li>
        </ul>

        {activeTab === 'new-garden' && (
          <NewGarden
            bedCount={bedCount}
            setBedCount={setBedCount}
            bedRows={bedRows}
            setBedRows={setBedRows}
            bedCols={bedCols}
            setBedCols={setBedCols}
            bedLightLevels={bedLightLevels}
            setBedLightLevels={setBedLightLevels}
            onGenerate={handleGenerateGarden}
          />
        )}

        {activeTab === 'plan' && (
          <div className="row g-3">
            <div className="col-md-2">
              <PlantPalette plants={plants} selectedCode={selectedCode} onSelect={setSelectedCode} />
            </div>
            <div className="col-md-7">
              <Beds
                beds={beds}
                plants={plants}
                setBeds={setBedsWithHistory}
                selectedCode={selectedCode}
                deselectTrigger={deselectTrigger}
                activeBed={activeBed}
                setActiveBed={setActiveBed}
                bedRows={bedRows}
                bedCols={bedCols}
                notes={notes}
                setNotes={setNotesWithHistory}
                onSelectionChange={handleSelectionChange}
                bedLightLevels={bedLightLevels}
              />
            </div>
            <div className="col-md-3">
              <div style={{ position: 'sticky', top: '20px' }}>
                <PlantInfo
                  selectedIndices={currentSelection.selectedIndices}
                  bed={currentSelection.bedIndex !== null ? beds[currentSelection.bedIndex] : []}
                  bedIndex={currentSelection.bedIndex}
                  plants={plants}
                  notes={notes}
                  onNotesChange={handleNotesChange}
                />
              </div>
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
