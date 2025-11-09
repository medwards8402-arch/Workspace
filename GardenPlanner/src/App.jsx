import React, { useState, useEffect } from 'react'
import { PLANTS } from './data'
import { PlantPalette } from './components/PlantPalette'
import { Beds } from './components/Beds'
import { NewGarden } from './components/NewGarden'
import { PlantInfo } from './components/PlantInfo'
import { Calendar } from './components/Calendar'
import { ZoneSelector } from './components/ZoneSelector'
import { useGardenOperations } from './hooks/useGardenOperations'
import { useHistory } from './hooks/useHistory'
import { useFileOperations } from './hooks/useFileOperations'
import { useSelection } from './hooks/useSelection'

export default function App() {
  const { garden, setZone } = useGardenOperations()
  const { undo, redo, canUndo, canRedo } = useHistory()
  const { exportToFile, importFromFile } = useFileOperations()
  const { clearSelection, setSelectedPlant, setActiveBed } = useSelection()
  
  const [activeTab, setActiveTab] = useState(() => {
    // Read from URL hash on mount
    const hash = window.location.hash.slice(1)
    if (hash === 'calendar') return 'calendar'
    if (hash === 'plan') return 'plan'
    return 'new-garden'
  })

  // Update URL hash when tab changes
  useEffect(() => {
    window.location.hash = activeTab
  }, [activeTab])

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault()
        undo()
      }
      if ((e.ctrlKey || e.metaKey) && (e.key === 'y' || (e.key === 'z' && e.shiftKey))) {
        e.preventDefault()
        redo()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [undo, redo])

  const handleSaveToFile = () => {
    const filename = `garden-plan-${new Date().toISOString().split('T')[0]}.json`
    if (exportToFile(filename)) {
      alert('Garden saved to file!')
    } else {
      alert('Failed to save garden')
    }
  }

  const handleLoadFromFile = async () => {
    try {
      await importFromFile()
      alert('Garden loaded successfully!')
    } catch (error) {
      console.error('Failed to load garden:', error)
      alert(`Failed to load garden: ${error.message}`)
    }
  }

  // Click-away deselection
  const handleContainerClick = () => {
    setSelectedPlant(null)
    clearSelection()
    setActiveBed(null)
  }

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
                onClick={(e) => { e.stopPropagation(); undo(); }}
                disabled={!canUndo}
                title="Undo (Ctrl+Z)"
              >
                ↶ Undo
              </button>
              <button
                className="btn btn-sm btn-outline-secondary"
                onClick={(e) => { e.stopPropagation(); redo(); }}
                disabled={!canRedo}
                title="Redo (Ctrl+Y)"
              >
                ↷ Redo
              </button>
            </div>
            <ZoneSelector zone={garden.zone} onChange={setZone} />
          </div>
        </header>

        <ul className="nav nav-pills mb-3">
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'new-garden' ? 'active' : ''}`} 
              onClick={(e) => { e.stopPropagation(); setActiveTab('new-garden'); }} 
              title="Configure and generate a new garden layout"
            >
              New Garden
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'plan' ? 'active' : ''}`} 
              onClick={(e) => { e.stopPropagation(); setActiveTab('plan'); }} 
              title="Edit and view your garden layout"
            >
              Garden Plan
            </button>
          </li>
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'calendar' ? 'active' : ''}`} 
              onClick={(e) => { e.stopPropagation(); setActiveTab('calendar'); }} 
              title="View planting schedule by month"
            >
              Planting Calendar
            </button>
          </li>
        </ul>

        {activeTab === 'new-garden' && (
          <NewGarden onAfterGenerate={() => setActiveTab('plan')} />
        )}

        {activeTab === 'plan' && (
          <div className="row g-3">
            <div className="col-md-2">
              <PlantPalette plants={PLANTS} />
            </div>
            <div className="col-md-7">
              <Beds beds={garden.beds} />
            </div>
            <div className="col-md-3">
              <div style={{ position: 'sticky', top: '20px' }}>
                <PlantInfo />
              </div>
            </div>
          </div>
        )}

        {activeTab === 'calendar' && (
          <Calendar />
        )}
      </div>
    </div>
  )
}
