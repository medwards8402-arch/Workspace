/**
 * PDF Service - generates printable garden plans
 * Uses jsPDF for PDF generation
 */
import { jsPDF } from 'jspdf'
import { PLANTS, USDA_ZONES } from '../data'
import { makeCalendarTasks, groupTasksByMonth } from '../calendar'

export class PDFService {
  /**
   * Generate a PDF of the garden plan
   */
  static generatePDF(garden) {
    const doc = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'letter'
    })

    const pageWidth = doc.internal.pageSize.getWidth()
    const pageHeight = doc.internal.pageSize.getHeight()
    const margin = 15
    const contentWidth = pageWidth - (margin * 2)
    let yPos = margin

    // Helper to add new page if needed
    const checkPageBreak = (neededSpace) => {
      if (yPos + neededSpace > pageHeight - margin) {
        doc.addPage()
        yPos = margin
        return true
      }
      return false
    }

    // Title
    doc.setFontSize(24)
    doc.setFont('helvetica', 'bold')
  doc.text(garden.name || 'My Raised Bed Plan', margin, yPos)
    yPos += 12

    doc.setFontSize(10)
    doc.setFont('helvetica', 'normal')
    doc.text(`USDA Zone: ${garden.zone}`, margin, yPos)
    yPos += 10

    // Section 1: Garden Plan
    checkPageBreak(40)
    doc.setFontSize(16)
    doc.setFont('helvetica', 'bold')
  doc.text('Layout', margin, yPos)
    yPos += 8

    // Calculate bed layouts and arrange in columns
    const bedsWithDimensions = garden.beds.map((bed, bedIndex) => {
      const maxGridWidth = contentWidth / 2 - 5 // Allow for 2 columns with spacing
      const cellSize = Math.min(10, maxGridWidth / bed.cols)
      const gridWidth = bed.cols * cellSize
      const gridHeight = bed.rows * cellSize
      const totalHeight = 8 + gridHeight
      
      return {
        bed,
        bedIndex,
        cellSize,
        gridWidth,
        gridHeight,
        totalHeight
      }
    })

    // Arrange beds in a 2-column layout
    let currentColumn = 0
    let columnHeights = [yPos, yPos]
    const columnX = [margin, margin + contentWidth / 2 + 5]
    
    bedsWithDimensions.forEach((bedData) => {
      const { bed, bedIndex, cellSize, gridWidth, gridHeight, totalHeight } = bedData
      
      // Choose column with lower height
      currentColumn = columnHeights[0] <= columnHeights[1] ? 0 : 1
      
      // Check if we need a new page
      if (columnHeights[currentColumn] + totalHeight > pageHeight - margin) {
        doc.addPage()
        columnHeights = [margin, margin]
        currentColumn = 0
      }
      
      const xStart = columnX[currentColumn]
      let yStart = columnHeights[currentColumn]
      
      // Draw bed title
      doc.setFontSize(11)
      doc.setFont('helvetica', 'bold')
      doc.text(`${bed.name || `Bed ${bedIndex + 1}`}`, xStart, yStart)
      yStart += 5

      // Track which plants we've already labeled in this bed
      const labeledPlants = new Set()
      
      for (let r = 0; r < bed.rows; r++) {
        for (let c = 0; c < bed.cols; c++) {
          const x = xStart + (c * cellSize)
          const y = yStart + (r * cellSize)
          const cellIndex = r * bed.cols + c
          const plantCode = bed.cells[cellIndex]

          // Draw cell border
          doc.setDrawColor(220, 220, 220)
          doc.setLineWidth(0.1)
          doc.rect(x, y, cellSize, cellSize)

          // Draw plant if present
          if (plantCode) {
            const plant = PLANTS.find(p => p.code === plantCode)
            if (plant) {
              // Color background
              const [red, green, blue] = this.hexToRgb(plant.color)
              doc.setFillColor(red, green, blue)
              doc.rect(x, y, cellSize, cellSize, 'F')
              doc.setDrawColor(220, 220, 220)
              doc.rect(x, y, cellSize, cellSize)
              
              // Add plant name and quantity info (only once per contiguous group)
              const cellKey = `${plantCode}-${r}-${c}`
              if (!labeledPlants.has(cellKey)) {
                // Find the size of this plant group
                let groupSize = 0
                for (let cell of bed.cells) {
                  if (cell === plantCode) groupSize++
                }
                
                // Calculate quantity display based on cellsRequired or spacing
                let quantityText
                if (plant.cellsRequired) {
                  // Show as fraction: "1 plant per X cells"
                  quantityText = `1/${plant.cellsRequired}`
                } else {
                  // Show total plants based on sqftSpacing
                  const totalPlants = Math.ceil(groupSize / plant.sqftSpacing)
                  if (plant.sqftSpacing > 1) {
                    // Multiple plants per cell (e.g., 4 per cell, 16 per cell)
                    quantityText = `${plant.sqftSpacing} per cell`
                  } else {
                    // One plant per cell
                    quantityText = `${totalPlants} plant${totalPlants > 1 ? 's' : ''}`
                  }
                }
                
                // Add text label with plant name and quantity
                // Scale font size based on cell size for better fill
                const nameFontSize = Math.max(5, cellSize * 0.5)
                doc.setFontSize(nameFontSize)
                doc.setFont('helvetica', 'bold')
                doc.setTextColor(255, 255, 255)
                
                // Plant name
                const textLines = this.wrapText(doc, plant.name, cellSize - 1)
                const lineHeight = nameFontSize * 0.85
                const totalTextHeight = textLines.length * lineHeight
                let textY = y + cellSize / 2 - totalTextHeight / 2 + lineHeight * 0.35
                
                textLines.forEach(line => {
                  doc.text(line, x + cellSize / 2, textY, { align: 'center', baseline: 'middle' })
                  textY += lineHeight
                })
                
                // Quantity info below name
                const qtyFontSize = Math.max(4, cellSize * 0.35)
                doc.setFontSize(qtyFontSize)
                doc.setFont('helvetica', 'normal')
                doc.text(`(${quantityText})`, 
                  x + cellSize / 2, y + cellSize - 1.5, 
                  { align: 'center', baseline: 'bottom' })
                
                doc.setTextColor(0, 0, 0)
                labeledPlants.add(cellKey)
              }
            }
          }
        }
      }

      // Update column height
      columnHeights[currentColumn] = yStart + gridHeight + 5
    })

    // Section 2: Planting Calendar
    doc.addPage()
    yPos = margin

    doc.setFontSize(16)
    doc.setFont('helvetica', 'bold')
  doc.text('Planting Schedule', margin, yPos)
    yPos += 8

  // Get calendar data (includes spring + fall where applicable)
  const calendarData = this.generateCalendarData(garden)
    
    doc.setFontSize(9)
    doc.setFont('helvetica', 'normal')

    Object.keys(calendarData).forEach((monthKey) => {
      const data = calendarData[monthKey]
      if (data.activities.length === 0) return

      checkPageBreak(30)

      doc.setFontSize(11)
      doc.setFont('helvetica', 'bold')
      doc.text(data.monthName, margin, yPos)
      yPos += 6

      doc.setFontSize(8)
      doc.setFont('helvetica', 'normal')

      data.activities.forEach((activity) => {
        checkPageBreak(5)
  doc.text(`• ${activity.type}: ${activity.plantName}`, margin + 3, yPos)
        yPos += 4
      })

      yPos += 4
    })

    // Section 3: Notes
    doc.addPage()
    yPos = margin

    doc.setFontSize(16)
    doc.setFont('helvetica', 'bold')
    doc.text('Notes', margin, yPos)
    yPos += 8

    const hasNotes = Object.keys(garden.notes).length > 0
    
    if (hasNotes) {
      doc.setFontSize(9)
      doc.setFont('helvetica', 'normal')

      // Group notes by plant code and note text
      const noteGroups = new Map()
      
      Object.entries(garden.notes).forEach(([key, note]) => {
        if (!note || !note.trim()) return
        
        const [bedIndex, cellIndex] = key.split('.').map(Number)
        const bed = garden.beds[bedIndex]
        if (!bed) return

        const plantCode = bed.cells[cellIndex]
        const plant = plantCode ? PLANTS.find(p => p.code === plantCode) : null
        
        // Create grouping key: plantCode + note text
        const groupKey = `${plantCode || 'none'}|||${note.trim()}`
        
        if (!noteGroups.has(groupKey)) {
          noteGroups.set(groupKey, {
            plant,
            plantCode,
            note: note.trim(),
            locations: []
          })
        }
        
        const location = `${bed.name || `Bed ${bedIndex + 1}`}, Cell ${cellIndex + 1}`
        noteGroups.get(groupKey).locations.push(location)
      })

      // Output grouped notes
      noteGroups.forEach((group) => {
        checkPageBreak(15)

        doc.setFont('helvetica', 'bold')
        
        // If multiple locations with same plant and note, group them
        if (group.locations.length > 1 && group.plant) {
          doc.text(`${group.plant.name} (${group.locations.length} locations):`, margin, yPos)
        } else if (group.plant) {
          doc.text(`${group.locations[0]} (${group.plant.name}):`, margin, yPos)
        } else {
          doc.text(`${group.locations[0]}:`, margin, yPos)
        }
        yPos += 5

        doc.setFont('helvetica', 'normal')
        const lines = doc.splitTextToSize(group.note, contentWidth - 5)
        lines.forEach((line) => {
          checkPageBreak(5)
          doc.text(line, margin + 3, yPos)
          yPos += 4
        })
        
        // Show locations for grouped notes
        if (group.locations.length > 1) {
          doc.setFont('helvetica', 'italic')
          doc.setFontSize(8)
          const locationText = `Locations: ${group.locations.join(', ')}`
          const locationLines = doc.splitTextToSize(locationText, contentWidth - 5)
          locationLines.forEach((line) => {
            checkPageBreak(4)
            doc.text(line, margin + 3, yPos)
            yPos += 3
          })
          doc.setFontSize(9)
        }
        
        yPos += 3
      })
    } else {
      doc.setFontSize(9)
      doc.setFont('helvetica', 'italic')
      doc.text('No notes added yet.', margin, yPos)
    }

    return doc
  }

  /**
   * Generate calendar data from garden
   */
  static generateCalendarData(garden) {
    // Get last frost date for the zone
    const z = USDA_ZONES[garden.zone]
    if (!z) return {}
    
    const today = new Date()
    let year = today.getFullYear()
    const lastFrost = new Date(year, z.month - 1, z.day)
    if (lastFrost < today) lastFrost.setFullYear(year + 1)
    
    // Compute first fall frost if available
    let firstFallFrost = null
    if (z.firstMonth && z.firstDay) {
      firstFallFrost = new Date(lastFrost.getFullYear(), z.firstMonth - 1, z.firstDay)
      if (firstFallFrost < lastFrost) firstFallFrost.setFullYear(lastFrost.getFullYear() + 1)
    }

    // Generate tasks using the calendar module (spring + fall cycles)
    const usedCodes = new Set(garden.uniquePlants)
    const tasks = makeCalendarTasks(usedCodes, PLANTS, lastFrost, firstFallFrost)
    const byMonth = groupTasksByMonth(tasks)
    
    // Convert to the format we need for PDF
    const monthData = {}
    
    byMonth.forEach((data, key) => {
      monthData[key] = {
        monthName: data.monthName,
        activities: data.tasks.map(task => ({
          type: formatTaskType(task.type),
          plantName: task.plant.name,
          plantCode: task.plant.code
        }))
      }
    })

    return monthData
  }

  /**
   * Wrap text to fit within a max width
   */
  static wrapText(doc, text, maxWidth) {
    const words = text.split(' ')
    const lines = []
    let currentLine = words[0]

    for (let i = 1; i < words.length; i++) {
      const testLine = currentLine + ' ' + words[i]
      const testWidth = doc.getTextWidth(testLine)
      
      if (testWidth <= maxWidth) {
        currentLine = testLine
      } else {
        lines.push(currentLine)
        currentLine = words[i]
      }
    }
    lines.push(currentLine)
    
    return lines
  }

  /**
   * Convert hex color to RGB
   */
  static hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    return result ? [
      parseInt(result[1], 16),
      parseInt(result[2], 16),
      parseInt(result[3], 16)
    ] : [0, 0, 0]
  }

  /**
   * Save PDF to file
   */
  static savePDF(garden, filename) {
    try {
      const doc = this.generatePDF(garden)
      doc.save(filename)
      return true
    } catch (error) {
      console.error('Failed to generate PDF:', error)
      return false
    }
  }

  /**
   * Format task type labels for PDF readability
   */
  static formatTaskTypeLabel(raw) {
    switch(raw) {
      case 'indoor': return 'Start Indoors'
      case 'sow': return 'Plant Outdoors'
      case 'harvest': return 'Harvest'
      case 'indoorFall': return 'Start Indoors (Fall)'
      case 'sowFall': return 'Plant Outdoors (Fall)'
      case 'harvestFall': return 'Harvest (Fall)'
      default: return raw
    }
  }
}

// Helper outside class for mapping task types during PDF data conversion
function formatTaskType(type) {
  switch(type) {
    case 'indoor': return 'Start Indoors'
    case 'sow': return 'Plant Outdoors'
    case 'harvest': return 'Harvest'
    case 'indoorFall': return 'Start Indoors (Fall)'
    case 'sowFall': return 'Plant Outdoors (Fall)'
    case 'harvestFall': return 'Harvest (Fall)'
    default: return type
  }
}
