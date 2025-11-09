import React, { useState, useEffect } from 'react'
import { PLANTS } from './data'
import { PlantPalette } from './components/PlantPalette'
import { Beds } from './components/Beds'
import { NewGarden } from './components/NewGarden'
import { PlantInfo } from './components/PlantInfo'
import { Calendar } from './components/Calendar'
import { Information } from './components/Information'
import { ZoneSelector } from './components/ZoneSelector'
import { useGardenOperations } from './hooks/useGardenOperations'
import { useHistory } from './hooks/useHistory'
import { useFileOperations } from './hooks/useFileOperations'
import { useSelection } from './hooks/useSelection'

export default function App() {
  const { garden, setZone, setName } = useGardenOperations()
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
    if (!exportToFile()) {
      alert('Failed to save garden')
    }
  }

  const handleLoadFromFile = async () => {
    try {
      await importFromFile()
    } catch (error) {
      console.error('Failed to load garden:', error)
      alert(`Failed to load garden: ${error.message}`)
    }
  }

  const handlePrintToPDF = async () => {
    try {
      // Dynamic import to avoid loading jsPDF until needed
      const { PDFService } = await import('./services/PDFService')
      const safeName = (garden.name || 'garden-plan')
        .replace(/[^a-z0-9_-]/gi, '-')
        .toLowerCase()
      const filename = `${safeName}.pdf`
      
      if (!PDFService.savePDF(garden, filename)) {
        alert('Failed to generate PDF')
      }
    } catch (error) {
      console.error('Failed to generate PDF:', error)
      alert(`Failed to generate PDF: ${error.message}`)
    }
  }

  // Click-away deselection
  const handleContainerClick = () => {
    setSelectedPlant(null)
    clearSelection()
    setActiveBed(null)
  }

  const handleNameChange = () => {
    const newName = prompt('Enter a name for your garden:', garden.name)
    if (newName !== null && newName.trim()) {
      setName(newName.trim())
    }
  }

  return (
    <div style={{ minHeight: '100vh' }} onClick={handleContainerClick}>
      <div className="container py-3">
        <header className="d-flex align-items-center justify-content-between mb-3">
          <div className="d-flex align-items-center gap-2">
            <h1 className="h4 m-0">Garden Planner</h1>
            <button 
              className="btn btn-sm btn-link text-decoration-none"
              onClick={(e) => { e.stopPropagation(); handleNameChange(); }}
              title="Click to rename your garden"
              style={{ fontSize: '1rem', padding: '0.25rem 0.5rem' }}
            >
              📝 {garden.name}
            </button>
          </div>
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
              <button
                className="btn btn-sm btn-outline-primary"
                onClick={(e) => { e.stopPropagation(); handlePrintToPDF(); }}
                title="Export to PDF"
              >
                🖨️ PDF
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
          <li className="nav-item">
            <button 
              className={`nav-link ${activeTab === 'info' ? 'active' : ''}`} 
              onClick={(e) => { e.stopPropagation(); setActiveTab('info'); }} 
              title="Usage instructions and information"
            >
              Information
            </button>
          </li>
        </ul>

        {activeTab === 'new-garden' && (
          <NewGarden onAfterGenerate={() => setActiveTab('plan')} />
        )}

        {activeTab === 'plan' && (
          <div className="row g-3">
            <div className="col-12">
              <div className="alert alert-info py-2 mb-0">
                <small>
                  💡 <strong>Tip:</strong> Click to select a cell or <strong>double-click</strong> a planted cell to select the entire plant group
                </small>
              </div>
            </div>
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

        {activeTab === 'info' && (
          <Information />
        )}
      </div>
    </div>
  )
}
