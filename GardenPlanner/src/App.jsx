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
  const { garden, setZone, setName, addBed, removeBed, updateBed, deleteNotes } = useGardenOperations()
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

  // On mount, if default URL and any bed has plants, go to layout page
  useEffect(() => {
    const hash = window.location.hash.slice(1)
    if (!hash || hash === 'new-garden') {
      if (garden && garden.beds && garden.beds.some(bed => bed.cells && bed.cells.some(cell => !!cell))) {
        setActiveTab('plan');
      }
    }
  }, [garden])

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
    // Keep activeBed (bed selection) unless user clicks blank area outside main app sections
  }

  const handleNameChange = () => {
    const newName = prompt('Enter a name for your garden:', garden.name)
    if (newName !== null && newName.trim()) {
      setName(newName.trim())
    }
  }

  // Compact Bed Config (used for both Add and Update)
  const [newBedName, setNewBedName] = useState('')
  const [newBedRows, setNewBedRows] = useState(8)
  const [newBedCols, setNewBedCols] = useState(4)
  const [newBedLight, setNewBedLight] = useState('high')
  const [selectedBedIndex, setSelectedBedIndex] = useState(null)

  // When selecting a bed, preload the config fields with that bed's values for editing
  useEffect(() => {
    if (selectedBedIndex !== null && selectedBedIndex !== undefined) {
      const b = garden.getBed(selectedBedIndex)
      if (b) {
        setNewBedRows(String(b.rows))
        setNewBedCols(String(b.cols))
        setNewBedName(b.name || '')
        setNewBedLight(b.lightLevel || 'high')
      }
    } else {
      // Keep last-used config values for adding when no selection
    }
  }, [selectedBedIndex, garden])
  const handleSelectBed = (index) => {
    setSelectedBedIndex(prev => prev === index ? null : index)
    setActiveBed(index)
  }

  const handleRemoveSelectedBed = () => {
    if (selectedBedIndex === null) return
    const bed = garden.getBed(selectedBedIndex)
    const planted = bed?.plantedCellCount || 0
    if (planted > 0) {
      if (!window.confirm(`Bed has ${planted} planted cell${planted === 1 ? '' : 's'}. Remove bed anyway?`)) return
    } else {
      if (!window.confirm('Remove this empty bed?')) return
    }
    removeBed(selectedBedIndex)
    setSelectedBedIndex(null)
  }

  const applyResize = () => {
    if (selectedBedIndex === null) return
    const bed = garden.getBed(selectedBedIndex)
    if (!bed) return
    const targetRows = Math.max(1, Math.min(24, parseInt(resizeRows || bed.rows, 10)))
    const targetCols = Math.max(1, Math.min(24, parseInt(resizeCols || bed.cols, 10)))
    if (targetRows === bed.rows && targetCols === bed.cols) return

    // Determine lost planted cells & notes if shrinking
    let lostPlanted = 0
    let lostNoteCount = 0
    const trimmedIndices = []
    if (targetRows < bed.rows || targetCols < bed.cols) {
      for (let r = 0; r < bed.rows; r++) {
        for (let c = 0; c < bed.cols; c++) {
          const oldIdx = r * bed.cols + c
          const outOfBounds = (r >= targetRows) || (c >= targetCols)
          if (outOfBounds) {
            const cellVal = bed.cells[oldIdx]
            if (cellVal) lostPlanted++
            const noteKey = `${selectedBedIndex}.${oldIdx}`
            if (garden.notes[noteKey]) lostNoteCount++
            trimmedIndices.push(oldIdx)
          }
        }
      }
    }
    if (lostPlanted > 0 || lostNoteCount > 0) {
      const parts = []
      if (lostPlanted > 0) parts.push(`${lostPlanted} planted cell${lostPlanted === 1 ? '' : 's'}`)
      if (lostNoteCount > 0) parts.push(`${lostNoteCount} note${lostNoteCount === 1 ? '' : 's'}`)
      if (!window.confirm(`Resizing will remove ${parts.join(' and ')}. Continue?`)) return
    }

    const newCellCount = targetRows * targetCols
    const newCells = new Array(newCellCount).fill(null)
    const minRows = Math.min(bed.rows, targetRows)
    const minCols = Math.min(bed.cols, targetCols)
    for (let r = 0; r < minRows; r++) {
      for (let c = 0; c < minCols; c++) {
        const oldIdx = r * bed.cols + c
        const newIdx = r * targetCols + c
        newCells[newIdx] = bed.cells[oldIdx]
      }
    }
    const BedCtor = bed.constructor
    const resizedBed = new BedCtor(targetRows, targetCols, bed.lightLevel, newCells, bed.name, bed.allowedTypes)

    // Remove notes for trimmed cells first (creates its own history entry)
    if (trimmedIndices.length > 0) {
      deleteNotes(selectedBedIndex, trimmedIndices)
    }
    updateBed(selectedBedIndex, resizedBed)
  }

  const submitConfig = () => {
    const rows = Math.max(1, Math.min(24, parseInt(newBedRows) || 1))
    const cols = Math.max(1, Math.min(24, parseInt(newBedCols) || 1))
    const name = (newBedName || '').trim()
    const lightLevel = newBedLight === 'low' ? 'low' : 'high'

    if (selectedBedIndex === null) {
      // Add new bed with current settings
      addBed({ rows, cols, lightLevel, name })
      return
    }

    // Update existing bed (resize + rename + light) with safety
    const bed = garden.getBed(selectedBedIndex)
    if (!bed) return
    const targetRows = rows
    const targetCols = cols

    // Determine lost planted cells & notes if shrinking
    let lostPlanted = 0
    let lostNoteCount = 0
    const trimmedIndices = []
    if (targetRows < bed.rows || targetCols < bed.cols) {
      for (let r = 0; r < bed.rows; r++) {
        for (let c = 0; c < bed.cols; c++) {
          const oldIdx = r * bed.cols + c
          const outOfBounds = (r >= targetRows) || (c >= targetCols)
          if (outOfBounds) {
            const cellVal = bed.cells[oldIdx]
            if (cellVal) lostPlanted++
            const noteKey = `${selectedBedIndex}.${oldIdx}`
            if (garden.notes[noteKey]) lostNoteCount++
            trimmedIndices.push(oldIdx)
          }
        }
      }
    }
    if (lostPlanted > 0 || lostNoteCount > 0) {
      const parts = []
      if (lostPlanted > 0) parts.push(`${lostPlanted} planted cell${lostPlanted === 1 ? '' : 's'}`)
      if (lostNoteCount > 0) parts.push(`${lostNoteCount} note${lostNoteCount === 1 ? '' : 's'}`)
      if (!window.confirm(`Updating size will remove ${parts.join(' and ')}. Continue?`)) return
    }

    // Build new cells array preserving overlap
    const newCellCount = targetRows * targetCols
    const newCells = new Array(newCellCount).fill(null)
    const minRows = Math.min(bed.rows, targetRows)
    const minCols = Math.min(bed.cols, targetCols)
    for (let r = 0; r < minRows; r++) {
      for (let c = 0; c < minCols; c++) {
        const oldIdx = r * bed.cols + c
        const newIdx = r * targetCols + c
        newCells[newIdx] = bed.cells[oldIdx]
      }
    }

    const BedCtor = bed.constructor
    const updatedBed = new BedCtor(targetRows, targetCols, lightLevel, newCells, name, bed.allowedTypes)

    if (trimmedIndices.length > 0) {
      deleteNotes(selectedBedIndex, trimmedIndices)
    }
    updateBed(selectedBedIndex, updatedBed)
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
            <div className="d-flex align-items-center gap-2 flex-wrap">
              <button
                className="btn btn-sm btn-outline-success d-flex align-items-center garden-name-btn"
                onClick={(e) => { e.stopPropagation(); handleNameChange(); }}
                title="Rename garden"
              >
                <Icon name="edit" className="me-1" /> {garden.name}
              </button>
              {activeTab === 'plan' && (
                <>
                  <form
                    className="d-flex align-items-center gap-2 flex-wrap bg-body-secondary rounded p-2"
                    onSubmit={(e) => { e.preventDefault(); submitConfig() }}
                    onClick={(e) => e.stopPropagation()}
                    title={selectedBedIndex === null ? 'Add a new bed' : 'Update selected bed'}
                  >
                    <input
                      type="text"
                      className="form-control form-control-sm"
                      placeholder={selectedBedIndex === null ? 'Name (optional)' : 'Rename bed'}
                      value={newBedName}
                      onChange={(e) => setNewBedName(e.target.value)}
                      style={{width: 140}}
                    />
                    <div className="d-flex align-items-center gap-1">
                      <input
                        type="number"
                        className="form-control form-control-sm"
                        value={newBedRows}
                        min={1}
                        max={24}
                        onChange={(e) => setNewBedRows(e.target.value)}
                        title="Rows"
                        style={{width: 70}}
                      />
                      <span className="text-muted" style={{fontSize: '0.8rem'}}>rows</span>
                    </div>
                    <div className="d-flex align-items-center gap-1">
                      <input
                        type="number"
                        className="form-control form-control-sm"
                        value={newBedCols}
                        min={1}
                        max={24}
                        onChange={(e) => setNewBedCols(e.target.value)}
                        title="Columns"
                        style={{width: 70}}
                      />
                      <span className="text-muted" style={{fontSize: '0.8rem'}}>cols</span>
                    </div>
                    <button
                      type="button"
                      className={`btn btn-sm ${newBedLight === 'high' ? 'btn-outline-warning' : 'btn-outline-info'}`}
                      onClick={() => setNewBedLight(newBedLight === 'high' ? 'low' : 'high')}
                      title="Light level"
                    >
                      {newBedLight === 'high' ? '☀️' : '☁️'}
                    </button>
                    <button type="submit" className="btn btn-sm btn-success">{selectedBedIndex === null ? 'Add Bed' : 'Update Bed'}</button>
                  </form>
                  <div className="d-flex align-items-center gap-2 ms-1 flex-wrap">
                    <select
                      className="form-select form-select-sm"
                      value={selectedBedIndex ?? ''}
                      onChange={(e) => {
                        const val = e.target.value
                        if (val === '') { setSelectedBedIndex(null); setActiveBed(null); return }
                        handleSelectBed(parseInt(val, 10))
                      }}
                      title="Select a bed to edit"
                      style={{width: 140}}
                    >
                      <option value="">(Select Bed)</option>
                      {garden.beds.map((b, i) => (
                        <option key={i} value={i}>{(b.name && b.name.trim()) ? b.name : `Bed ${i + 1}`}</option>
                      ))}
                    </select>
                    <button
                      className="btn btn-sm btn-outline-danger d-flex align-items-center"
                      disabled={selectedBedIndex === null}
                      onClick={(e) => { e.stopPropagation(); handleRemoveSelectedBed() }}
                      title={selectedBedIndex === null ? 'Select a bed first' : 'Remove selected bed'}
                      style={{padding: '0.25rem 0.5rem'}}
                    >
                      🗑️ <span className="visually-hidden">Remove</span>
                    </button>
                  </div>
                </>
              )}
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
