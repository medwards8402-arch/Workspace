import React, { useState, useEffect } from 'react'
import { PLANTS } from './data'
import { PlantPalette } from './components/PlantPalette'
import { Beds } from './components/Beds'
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
  const { garden, setZone, setName, addBed, removeBed, updateBed, deleteNotes, reorderBed } = useGardenOperations()
  const { undo, redo, canUndo, canRedo } = useHistory()
  const { exportToFile, importFromFile } = useFileOperations()
  const { clearSelection, setSelectedPlant, setActiveBed, activeBed, selectedPlant } = useSelection()
  
  const [lastClickTime, setLastClickTime] = useState(0)
  
  const [activeTab, setActiveTab] = useState(() => {
    // Read from URL hash on mount
    const hash = window.location.hash.slice(1)
    if (hash === 'calendar') return 'calendar'
    if (hash === 'info') return 'info'
    if (hash === 'settings') return 'settings'
    return 'plan'
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

  const handleDeleteAllBeds = () => {
    const totalBeds = garden.beds.length
    const totalPlanted = garden.beds.reduce((sum, bed) => sum + (bed.plantedCellCount || 0), 0)
    
    let message = `Delete all ${totalBeds} bed${totalBeds === 1 ? '' : 's'}?`
    if (totalPlanted > 0) {
      message = `Delete all ${totalBeds} bed${totalBeds === 1 ? '' : 's'} and ${totalPlanted} planted cell${totalPlanted === 1 ? '' : 's'}? This cannot be undone.`
    }
    
    if (!window.confirm(message)) return
    
    // Remove all beds (from last to first to avoid index issues)
    for (let i = garden.beds.length - 1; i >= 0; i--) {
      removeBed(i)
    }
    setSelectedBedIndex(null)
    setActiveBed(null)
  }

  // Click-away deselection - triggered by clicks outside beds/palette
  const handleContainerClick = (e) => {
    // Debounce rapid clicks to avoid interfering with drag operations
    // If a click happens within 50ms of the previous one, ignore it
    const now = Date.now()
    if (now - lastClickTime < 50) {
      return
    }
    setLastClickTime(now)
    
    // Don't interfere with planting operations - only clear when truly clicking whitespace
    // Let event bubble naturally; beds and palette stop propagation when appropriate
    clearSelection()
    setActiveBed(null)
    // Don't clear selectedPlant here - let PlantPalette manage it
  }

  const handleNameChange = () => {
    const newName = prompt('Enter a name for your garden:', garden.name)
    if (newName !== null && newName.trim()) {
      setName(newName.trim())
    }
  }

  // Compact Bed Config (used for both Add and Update)
  const [newBedName, setNewBedName] = useState('')
  const [newBedRows, setNewBedRows] = useState(4)
  const [newBedCols, setNewBedCols] = useState(8)
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
      // Clear name when adding a new bed so user can type a fresh one
      setNewBedName('')
    }
  }, [selectedBedIndex, garden])
  
  // Sync selectedBedIndex with activeBed from reducer (one-way sync)
  useEffect(() => {
    if (activeBed !== null && activeBed !== undefined) {
      // When a bed becomes active, sync the dropdown to show it
      if (activeBed !== selectedBedIndex) {
        setSelectedBedIndex(activeBed)
      }
    } else if (activeBed === null) {
      // When activeBed is cleared, reset dropdown to "(New Bed)"
      if (selectedBedIndex !== null) {
        setSelectedBedIndex(null)
      }
    }
  }, [activeBed])
  
  const handleSelectBed = (index) => {
    // Always select the specified bed (no toggling)
    setSelectedBedIndex(index)
    setActiveBed(index)
  }

  const handleRemoveSelectedBed = () => {
    if (selectedBedIndex === null) return
    removeBed(selectedBedIndex)
    setSelectedBedIndex(null)
  }

  const handleMoveBedUp = () => {
    if (selectedBedIndex === null || selectedBedIndex === 0) return
    reorderBed(selectedBedIndex, selectedBedIndex - 1)
    setSelectedBedIndex(selectedBedIndex - 1)
    setActiveBed(selectedBedIndex - 1)
  }

  const handleMoveBedDown = () => {
    if (selectedBedIndex === null || selectedBedIndex >= garden.beds.length - 1) return
    reorderBed(selectedBedIndex, selectedBedIndex + 1)
    setSelectedBedIndex(selectedBedIndex + 1)
    setActiveBed(selectedBedIndex + 1)
  }

  const submitConfig = () => {
    const rows = Math.max(1, Math.min(12, parseInt(newBedRows) || 1))
    const cols = Math.max(1, Math.min(12, parseInt(newBedCols) || 1))
    const name = (newBedName || '').trim()
    const lightLevel = newBedLight === 'low' ? 'low' : 'high'

    if (selectedBedIndex === null) {
      // Add new bed with current settings
      const effectiveName = name || `Bed ${garden.beds.length + 1}`
      const newBedIndex = garden.beds.length
      addBed({ rows, cols, lightLevel, name: effectiveName })
      // After adding, clear the name field and select the new bed
      setNewBedName('')
      // Select the newly added bed (it will be at the end of the array)
      setSelectedBedIndex(newBedIndex)
      setActiveBed(newBedIndex)
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
              <button
                className="btn btn-link p-0 m-0 text-body h5 text-decoration-none d-inline-flex align-items-center garden-name-btn"
                onClick={(e) => { e.stopPropagation(); handleNameChange(); }}
                title="Rename garden"
                style={{fontSize: '1.5rem', fontWeight: '600'}}
              >
                <Icon name="edit" className="me-2" /> {garden.name || 'Raised Bed Planner'}
              </button>
              <ul className="nav nav-pills">
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
                    <button
                      className="btn btn-outline-danger d-flex align-items-center"
                      onClick={(e) => { e.stopPropagation(); handleDeleteAllBeds(); }}
                      title="Delete all beds"
                      disabled={garden.beds.length === 0}
                    >
                      <Icon name="trash" className="me-1" /> Clear All
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Level 2: Global settings for this plan */}
          <div className="d-flex align-items-center justify-content-between flex-wrap gap-2 app-header-secondary">
            <div className="d-flex align-items-center gap-2 flex-wrap">
              {activeTab === 'plan' && (
                <>
                  <select
                    className="form-select form-select-sm"
                    value={selectedBedIndex ?? ''}
                    onChange={(e) => {
                      const val = e.target.value
                        if (val === '') { setSelectedBedIndex(null); setActiveBed(null); setNewBedName(''); return }
                      handleSelectBed(parseInt(val, 10))
                    }}
                    onClick={(e) => e.stopPropagation()}
                    title="Select a bed to edit"
                    style={{width: 140}}
                  >
                    <option value="">(New Bed)</option>
                    {garden.beds.map((b, i) => (
                      <option key={i} value={i}>{(b.name && b.name.trim()) ? b.name : `Bed ${i + 1}`}</option>
                    ))}
                  </select>
                  <form
                    id="bed-config-form"
                    className="d-flex align-items-center gap-2 flex-wrap bg-body-secondary rounded p-2"
                    onSubmit={(e) => { e.preventDefault(); submitConfig() }}
                    onClick={(e) => e.stopPropagation()}
                    title={selectedBedIndex === null ? 'Add a new bed' : 'Update selected bed'}
                  >
                    <div className="d-flex align-items-center gap-1">
                      <Icon name="edit" style={{fontSize: '0.9rem', opacity: 0.6}} />
                      <input
                        type="text"
                        className="form-control form-control-sm"
                        placeholder={selectedBedIndex === null ? '(Name)' : 'Rename bed'}
                        value={newBedName}
                        onChange={(e) => setNewBedName(e.target.value)}
                        style={{width: 140}}
                      />
                    </div>
                    <div className="d-flex align-items-center gap-1">
                      <input
                        type="number"
                        className="form-control form-control-sm"
                        value={newBedRows}
                        min={1}
                        max={12}
                        onChange={(e) => setNewBedRows(e.target.value)}
                        title="Rows"
                        style={{width: '6ch'}}
                      />
                      <span className="text-muted">×</span>
                      <input
                        type="number"
                        className="form-control form-control-sm"
                        value={newBedCols}
                        min={1}
                        max={12}
                        onChange={(e) => setNewBedCols(e.target.value)}
                        title="Columns"
                        style={{width: '6ch'}}
                      />
                    </div>
                    <button
                      type="button"
                      className={`btn btn-sm ${newBedLight === 'high' ? 'btn-outline-warning' : 'btn-outline-info'}`}
                      onClick={() => setNewBedLight(newBedLight === 'high' ? 'low' : 'high')}
                      title="Light level"
                    >
                      {newBedLight === 'high' ? '☀️' : '☁️'}
                    </button>
                  </form>
                  <div className="btn-group btn-group-sm" role="group">
                    <button
                      className="btn btn-outline-secondary d-flex align-items-center"
                      disabled={selectedBedIndex === null || selectedBedIndex === 0}
                      onClick={(e) => { e.stopPropagation(); handleMoveBedUp() }}
                      title="Move bed up"
                    >
                      <Icon name="arrow-up" />
                    </button>
                    <button
                      className="btn btn-outline-secondary d-flex align-items-center"
                      disabled={selectedBedIndex === null || selectedBedIndex >= garden.beds.length - 1}
                      onClick={(e) => { e.stopPropagation(); handleMoveBedDown() }}
                      title="Move bed down"
                    >
                      <Icon name="arrow-down" />
                    </button>
                  </div>
                  <div className="btn-group btn-group-sm" role="group">
                    <button
                      type="submit"
                      form="bed-config-form"
                      className="btn btn-outline-primary d-flex align-items-center"
                      onClick={(e) => e.stopPropagation()}
                      title={selectedBedIndex === null ? 'Add a new bed' : 'Update selected bed'}
                    >
                      <Icon name={selectedBedIndex === null ? 'plus-square' : 'check-square'} className="me-1" />
                      {selectedBedIndex === null ? 'Add Bed' : 'Update Bed'}
                    </button>
                    <button
                      className="btn btn-outline-danger d-flex align-items-center"
                      disabled={selectedBedIndex === null}
                      onClick={(e) => { e.stopPropagation(); handleRemoveSelectedBed() }}
                      title={selectedBedIndex === null ? 'Select a bed first' : 'Remove selected bed'}
                    >
                      <Icon name="trash" className="me-1" /> Remove
                    </button>
                  </div>
                </>
              )}
              
            </div>
            <ZoneSelector zone={garden.zone} onChange={setZone} />
          </div>
        </header>

        {activeTab === 'plan' && (
          <div className="row g-2 plan-layout d-flex">
            <div className="col-12">
              <TipsStack>
                {garden.beds.length === 0 && (
                  <Tip id="create-bed">
                    <strong>Create a Bed:</strong> Use the "Add Bed" button to create your first raised bed. You can customize its size, name, and light level.
                  </Tip>
                )}
                {garden.beds.length > 0 && garden.beds.every(bed => bed.plantedCellCount === 0) && (
                  <Tip id="planting-crops">
                    <strong>Planting Crops:</strong> Select a crop from the left palette, then click or drag on cells to plant. Some crops need multiple cells to grow properly.
                  </Tip>
                )}
                {garden.beds.some(bed => bed.plantedCellCount > 0) && (
                  <Tip id="selection-tips">
                    <strong>Selection:</strong> Click to select a cell, drag to select multiple, or double-click a planted cell to select the entire crop. Delete with the Delete key.
                  </Tip>
                )}
                {selectedBedIndex !== null && (
                  <Tip id="editing-beds">
                    <strong>Editing Beds:</strong> With a bed selected, use the form to rename it, change dimensions, or adjust light level. Click "Update Bed" to save changes, "Remove" to delete it, or use the arrows to reorder beds.
                  </Tip>
                )}
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
