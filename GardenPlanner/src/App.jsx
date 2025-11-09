import React, { useState, useEffect } from 'react'
import { PLANTS } from './data'
import { PlantPalette } from './components/PlantPalette'
import { Beds } from './components/Beds'
import { NewGarden } from './components/NewGarden'
import { PlantInfo } from './components/PlantInfo'
import { Calendar } from './components/Calendar'
import { Information } from './components/Information'
import { Settings } from './components/Settings'
import { ZoneSelector } from './components/ZoneSelector'
import { Tip } from './components/Tip'
import { TipsStack } from './components/TipsStack'
import { Icon } from './components/Icon'
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
      <div className="container py-2">
        {/* Main Header (now two levels):
            1) Title + Tabs on the left, Context actions on the right
            2) Global settings: Garden name + Zone/Frost selector */}
  <header className="mb-2 app-header">
          {/* Level 1: Title + Tabs + Actions */}
          <div className="d-flex align-items-center justify-content-between mb-1 flex-wrap gap-2">
            <div className="d-flex align-items-center flex-wrap" style={{gap: '0.5rem 0.75rem'}}>
              <h1 className="h5 m-0">Raised Bed Planner</h1>
              <ul className="nav nav-pills">
                <li className="nav-item">
                  <button 
                    className={`nav-link ${activeTab === 'new-garden' ? 'active' : ''}`} 
                    onClick={(e) => { e.stopPropagation(); setActiveTab('new-garden'); }} 
                    title="Configure and generate a new raised bed layout"
                  >
                    <Icon name="plus-square" className="me-1" /> New
                  </button>
                </li>
                <li className="nav-item">
                  <button 
                    className={`nav-link ${activeTab === 'plan' ? 'active' : ''}`} 
                    onClick={(e) => { e.stopPropagation(); setActiveTab('plan'); }} 
                    title="Edit and view your raised bed layout"
                  >
                    <Icon name="grid" className="me-1" /> Layout
                  </button>
                </li>
                <li className="nav-item">
                  <button 
                    className={`nav-link ${activeTab === 'calendar' ? 'active' : ''}`} 
                    onClick={(e) => { e.stopPropagation(); setActiveTab('calendar'); }} 
                    title="View planting schedule by month"
                  >
                    <Icon name="calendar" className="me-1" /> Calendar
                  </button>
                </li>
                <li className="nav-item ms-auto">
                  <button 
                    className={`nav-link ${activeTab === 'info' ? 'active' : ''}`} 
                    onClick={(e) => { e.stopPropagation(); setActiveTab('info'); }} 
                    title="Usage instructions and information"
                  >
                    <Icon name="info" className="me-1" /> About
                  </button>
                </li>
                <li className="nav-item">
                  <button 
                    className={`nav-link ${activeTab === 'settings' ? 'active' : ''}`} 
                    onClick={(e) => { e.stopPropagation(); setActiveTab('settings'); }} 
                    title="Application settings and preferences"
                  >
                    <Icon name="settings" className="me-1" /> Settings
                  </button>
                </li>
              </ul>
            </div>
            <div className="d-flex align-items-center gap-2 ms-auto">
              {(activeTab === 'plan' || activeTab === 'calendar') && (
                <>
                  {activeTab === 'plan' && (
                    <div className="btn-group btn-group-sm" role="group">
                      <button
                        className="btn btn-outline-secondary d-flex align-items-center"
                        onClick={(e) => { e.stopPropagation(); undo(); }}
                        disabled={!canUndo}
                        title="Undo (Ctrl+Z)"
                      >
                        <Icon name="undo" className="me-1" /> Undo
                      </button>
                      <button
                        className="btn btn-outline-secondary d-flex align-items-center"
                        onClick={(e) => { e.stopPropagation(); redo(); }}
                        disabled={!canRedo}
                        title="Redo (Ctrl+Y)"
                      >
                        <Icon name="redo" className="me-1" /> Redo
                      </button>
                    </div>
                  )}
                  <div className="btn-group btn-group-sm" role="group">
                    <button
                      className="btn btn-outline-primary d-flex align-items-center"
                      onClick={(e) => { e.stopPropagation(); handleSaveToFile(); }}
                      title="Save garden to file"
                    >
                      <Icon name="save" className="me-1" /> Save
                    </button>
                    <button
                      className="btn btn-outline-primary d-flex align-items-center"
                      onClick={(e) => { e.stopPropagation(); handleLoadFromFile(); }}
                      title="Load garden from file"
                    >
                      <Icon name="folder-open" className="me-1" /> Load
                    </button>
                    <button
                      className="btn btn-outline-primary d-flex align-items-center"
                      onClick={(e) => { e.stopPropagation(); handlePrintToPDF(); }}
                      title="Export to PDF"
                    >
                      <Icon name="printer" className="me-1" /> PDF
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Level 2: Global settings for this plan */}
          <div className="d-flex align-items-center justify-content-between flex-wrap gap-2 app-header-secondary">
            <div className="d-flex align-items-center gap-2">
              <button 
                className="btn btn-sm btn-outline-success d-flex align-items-center garden-name-btn"
                onClick={(e) => { e.stopPropagation(); handleNameChange(); }}
                title="Rename garden"
              >
                <Icon name="edit" className="me-1" /> {garden.name}
              </button>
            </div>
            <ZoneSelector zone={garden.zone} onChange={setZone} />
          </div>
        </header>

        {activeTab === 'new-garden' && (
          <NewGarden onAfterGenerate={() => setActiveTab('plan')} />
        )}

        {activeTab === 'plan' && (
          <div className="row g-2 plan-layout d-flex">
            <div className="col-12">
              <TipsStack>
                <Tip id="garden-plan-selection">
                  Click to select a cell or <strong>double-click</strong> a planted cell to select the entire plant group
                </Tip>
                <Tip id="save-often">
                  <strong>Save your work:</strong> Use the Save button in the header to export your garden plan to a .pln file. Your plan is not automatically saved!
                </Tip>
              </TipsStack>
            </div>
            <div className="col-md-2 plan-palette">
              <PlantPalette plants={PLANTS} />
            </div>
            <div className="col-md-7 plan-beds">
              <div className="beds-scroll">
                <Beds beds={garden.beds} />
              </div>
            </div>
            <div className="col-md-3 plan-info">
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

        {activeTab === 'settings' && (
          <Settings />
        )}
      </div>
    </div>
  )
}
