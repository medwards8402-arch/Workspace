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
      
      // Detect sprawling plant groups (same logic as GardenBed.jsx)
      const sprawlingGroups = this.detectSprawlingGroups(bed, cellSize)
      const dimmedCells = new Set()
      sprawlingGroups.forEach(group => {
        group.cellIndices.forEach(idx => dimmedCells.add(idx))
      })
      
      for (let r = 0; r < bed.rows; r++) {
        for (let c = 0; c < bed.cols; c++) {
          const x = xStart + (c * cellSize)
          const y = yStart + (r * cellSize)
          const cellIndex = r * bed.cols + c
          const plantCode = bed.cells[cellIndex]
          const isDimmed = dimmedCells.has(cellIndex)

          // Draw plant if present
          if (plantCode) {
            const plant = PLANTS.find(p => p.code === plantCode)
            if (plant) {
              // Color background (dimmed for sprawling cells)
              const [red, green, blue] = this.hexToRgb(plant.color)
              if (isDimmed) {
                // Dim the color by blending with white
                doc.setFillColor(
                  red + (255 - red) * 0.3,
                  green + (255 - green) * 0.3,
                  blue + (255 - blue) * 0.3
                )
              } else {
                doc.setFillColor(red, green, blue)
              }
              doc.rect(x, y, cellSize, cellSize, 'F')
              
              // Draw selective borders - only where adjacent cells differ
              doc.setDrawColor(220, 220, 220)
              doc.setLineWidth(0.1)
              
              // Top border (if different plant above or edge)
              if (r === 0 || bed.cells[(r - 1) * bed.cols + c] !== plantCode) {
                doc.line(x, y, x + cellSize, y)
              }
              // Bottom border (if different plant below or edge)
              if (r === bed.rows - 1 || bed.cells[(r + 1) * bed.cols + c] !== plantCode) {
                doc.line(x, y + cellSize, x + cellSize, y + cellSize)
              }
              // Left border (if different plant left or edge)
              if (c === 0 || bed.cells[r * bed.cols + (c - 1)] !== plantCode) {
                doc.line(x, y, x, y + cellSize)
              }
              // Right border (if different plant right or edge)
              if (c === bed.cols - 1 || bed.cells[r * bed.cols + (c + 1)] !== plantCode) {
                doc.line(x + cellSize, y, x + cellSize, y + cellSize)
              }
              
              // Add plant name and quantity info (only once per contiguous group)
              // Skip labels for dimmed cells (they'll get overlays)
              const cellKey = `${plantCode}-${r}-${c}`
              if (!isDimmed && !labeledPlants.has(cellKey)) {
                // Find the size of this plant group
                let groupSize = 0
                for (let cell of bed.cells) {
                  if (cell === plantCode) groupSize++
                }
                
                // Calculate quantity display
                let quantityText
                if (plant.cellsRequired && plant.cellsRequired > 1) {
                  // Sprawling plants: show as "1 plant" per cellsRequired cells
                  const plantCount = Math.floor(groupSize / plant.cellsRequired)
                  quantityText = `${plantCount} plant${plantCount !== 1 ? 's' : ''}`
                } else {
                  // Regular plants: show based on sqftSpacing
                  const totalPlants = Math.ceil(groupSize / (plant.sqftSpacing || 1))
                  if (plant.sqftSpacing > 1) {
                    // Multiple plants per square foot
                    quantityText = `${plant.sqftSpacing} per sq ft`
                  } else {
                    // One plant per square foot
                    quantityText = `${totalPlants} plant${totalPlants > 1 ? 's' : ''}`
                  }
                }
                
                // Add text label with plant name and quantity
                // Scale font size based on cell size for better fill
                const nameFontSize = Math.max(5, cellSize * 0.5)
                doc.setFontSize(nameFontSize)
                doc.setFont('helvetica', 'bold')
                
                // Use high contrast text color (white or black based on background)
                const [red, green, blue] = this.hexToRgb(plant.color)
                const textColor = this.getContrastColor(red, green, blue)
                doc.setTextColor(textColor[0], textColor[1], textColor[2])
                
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
      
      // Draw sprawling plant overlays (text-only, matching single cell style)
      sprawlingGroups.forEach(group => {
        group.plantInstances.forEach((instance) => {
          const { minR, maxR, minC, maxC, centerR, centerC } = instance
          
          // Draw subtle grouping border (lighter and thinner)
          const borderX = xStart + minC * cellSize
          const borderY = yStart + minR * cellSize
          const borderW = (maxC - minC + 1) * cellSize
          const borderH = (maxR - minR + 1) * cellSize
          
          const [red, green, blue] = this.hexToRgb(group.plant.color)
          // Make border more subtle (blend with dimmed cells)
          doc.setDrawColor(
            red + (255 - red) * 0.5,
            green + (255 - green) * 0.5,
            blue + (255 - blue) * 0.5
          )
          doc.setLineWidth(0.15)
          doc.roundedRect(borderX, borderY, borderW, borderH, 0.5, 0.5, 'S')
          
          // Calculate text positioning
          const centerX = xStart + centerC * cellSize
          const centerY = yStart + centerR * cellSize
          const instanceWidth = (maxC - minC + 1) * cellSize
          const instanceHeight = (maxR - minR + 1) * cellSize
          const instanceRows = maxR - minR + 1
          const instanceCols = maxC - minC + 1
          
          // Calculate quantity: count how many complete plants in this instance
          const plantCount = Math.floor(instance.cells.length / group.plant.cellsRequired)
          const quantityText = `${plantCount} plant${plantCount !== 1 ? 's' : ''}`
          
          // Adapt font sizing based on instance size (match single cell proportions)
          let nameFontSize, qtyFontSize
          if (instanceRows === 1 && instanceCols === 2) {
            // 1x2 horizontal - similar to single cell
            nameFontSize = Math.max(5, cellSize * 0.45)
            qtyFontSize = Math.max(4, cellSize * 0.32)
          } else if (instanceRows === 2 && instanceCols === 1) {
            // 2x1 vertical - similar to single cell but taller
            nameFontSize = Math.max(5, cellSize * 0.45)
            qtyFontSize = Math.max(4, cellSize * 0.32)
          } else if (instanceRows === 2 && instanceCols === 2) {
            // 2x2 square - more space available
            nameFontSize = Math.max(5, cellSize * 0.5)
            qtyFontSize = Math.max(4, cellSize * 0.35)
          } else {
            // Default for larger instances
            nameFontSize = Math.max(5, cellSize * 0.5)
            qtyFontSize = Math.max(4, cellSize * 0.35)
          }
          
          doc.setFontSize(nameFontSize)
          doc.setFont('helvetica', 'bold')
          
          // Use high contrast text color
          const textColor = this.getContrastColor(red, green, blue)
          doc.setTextColor(textColor[0], textColor[1], textColor[2])
          
          // Plant name - center it properly considering the quantity text below
          const textLines = this.wrapText(doc, group.plant.name, instanceWidth - 1)
          const lineHeight = nameFontSize * 0.85
          const totalTextHeight = textLines.length * lineHeight
          
          // Calculate starting Y position to center name + quantity together
          const qtyHeight = qtyFontSize * 1.2
          const totalContentHeight = totalTextHeight + qtyHeight
          let textY = centerY - totalContentHeight / 2 + lineHeight * 0.35
          
          textLines.forEach(line => {
            doc.text(line, centerX, textY, { align: 'center', baseline: 'middle' })
            textY += lineHeight
          })
          
          // Quantity info below name (positioned at bottom like single cells)
          doc.setFontSize(qtyFontSize)
          doc.setFont('helvetica', 'normal')
          // Calculate absolute bottom position of the instance
          const instanceBottomY = yStart + (maxR + 1) * cellSize
          doc.text(`(${quantityText})`, 
            centerX, instanceBottomY - 1.5, 
            { align: 'center', baseline: 'bottom' })
          
          doc.setTextColor(0, 0, 0)
        })
      })

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
    
    // Convert to array for two-column layout
    const calendarEntries = Object.keys(calendarData)
      .map(monthKey => ({ monthKey, data: calendarData[monthKey] }))
      .filter(entry => entry.data.activities.length > 0)
    
    // Set up two-column layout - fill left column, then right column, then new page
    const columnWidthCal = contentWidth / 2 - 5
    const columnXCal = [margin, margin + contentWidth / 2 + 5]
    let currentColumnCal = 0
    let columnYPositions = [yPos, yPos]
    
    doc.setFontSize(9)
    doc.setFont('helvetica', 'normal')

    calendarEntries.forEach((entry) => {
      const { data } = entry
      
      let calYPos = columnYPositions[currentColumnCal]
      let calXPos = columnXCal[currentColumnCal]
      
      // Calculate space needed for this month
      const spaceNeeded = 6 + (data.activities.length * 4) + 4
      
      // Check if current month fits in current column
      if (calYPos + spaceNeeded > pageHeight - margin) {
        // Current column is full, try next column
        if (currentColumnCal === 0) {
          // Move to right column on same page
          currentColumnCal = 1
          calYPos = columnYPositions[currentColumnCal]
          calXPos = columnXCal[currentColumnCal]
          
          // Check if it fits in right column
          if (calYPos + spaceNeeded > pageHeight - margin) {
            // Right column is also full, start new page
            doc.addPage()
            columnYPositions = [margin, margin]
            currentColumnCal = 0
            calYPos = margin
            calXPos = columnXCal[0]
          }
        } else {
          // Right column is full, start new page
          doc.addPage()
          columnYPositions = [margin, margin]
          currentColumnCal = 0
          calYPos = margin
          calXPos = columnXCal[0]
        }
      }

      doc.setFontSize(11)
      doc.setFont('helvetica', 'bold')
      doc.text(data.monthName, calXPos, calYPos)
      calYPos += 6

      doc.setFontSize(8)
      doc.setFont('helvetica', 'normal')

      data.activities.forEach((activity) => {
        doc.text(`• ${activity.type}: ${activity.plantName}`, calXPos + 3, calYPos)
        calYPos += 4
      })

      calYPos += 4
      columnYPositions[currentColumnCal] = calYPos
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
   * Detect sprawling plant groups (plants with cellsRequired > 1)
   * Returns array of groups with plant instances using two-pass strategy
   */
  static detectSprawlingGroups(bed, cellSize) {
    const groups = []
    const cells = bed.cells
    const visited = new Set()
    const bedRows = bed.rows
    const bedCols = bed.cols
    
    const idxToRowCol = (idx) => ({ row: Math.floor(idx / bedCols), col: idx % bedCols })
    const inBounds = (r, c) => r >= 0 && r < bedRows && c >= 0 && c < bedCols
    const idxAt = (r, c) => r * bedCols + c
    
    for (let i = 0; i < cells.length; i++) {
      const code = cells[i]
      if (!code || visited.has(i)) continue
      const plant = PLANTS.find(p => p.code === code)
      if (!plant || !(plant.cellsRequired && plant.cellsRequired > 1)) continue
      
      // BFS to collect contiguous group
      const queue = [i]
      const group = []
      visited.add(i)
      while (queue.length) {
        const idx = queue.shift()
        group.push(idx)
        const { row, col } = idxToRowCol(idx)
        const neighbors = [
          [row-1, col], [row+1, col], [row, col-1], [row, col+1]
        ]
        for (const [nr, nc] of neighbors) {
          if (!inBounds(nr, nc)) continue
          const nIdx = idxAt(nr, nc)
          if (!visited.has(nIdx) && cells[nIdx] === code) {
            visited.add(nIdx)
            queue.push(nIdx)
          }
        }
      }
      
      // Compute bounding box
      let minR = bedRows, maxR = -1, minC = bedCols, maxC = -1
      group.forEach(idx => {
        const { row, col } = idxToRowCol(idx)
        minR = Math.min(minR, row)
        maxR = Math.max(maxR, row)
        minC = Math.min(minC, col)
        maxC = Math.max(maxC, col)
      })
      
      const requiredPerPlant = plant.cellsRequired
      const isSquareShape = requiredPerPlant === 4 || requiredPerPlant === 9
      const groupSet = new Set(group)
      const instanceVisited = new Set()
      const plantInstances = []
      
      // Helper: Try to claim a shape
      const tryClaimShape = (startIdx, preferHorizontal) => {
        if (instanceVisited.has(startIdx)) return null
        
        const { row: startRow, col: startCol } = idxToRowCol(startIdx)
        const instanceCells = []
        
        let shapeRows, shapeCols
        if (isSquareShape) {
          const side = Math.sqrt(requiredPerPlant)
          shapeRows = shapeCols = side
        } else if (requiredPerPlant === 2) {
          if (preferHorizontal) {
            shapeRows = 1; shapeCols = 2
          } else {
            shapeRows = 2; shapeCols = 1
          }
        } else if (requiredPerPlant === 8) {
          if (preferHorizontal) {
            shapeRows = 2; shapeCols = 4
          } else {
            shapeRows = 4; shapeCols = 2
          }
        } else {
          const side = Math.sqrt(requiredPerPlant)
          if (preferHorizontal) {
            shapeRows = Math.floor(side)
            shapeCols = Math.ceil(requiredPerPlant / shapeRows)
          } else {
            shapeCols = Math.floor(side)
            shapeRows = Math.ceil(requiredPerPlant / shapeCols)
          }
        }
        
        let canClaim = true
        for (let rOffset = 0; rOffset < shapeRows && canClaim; rOffset++) {
          for (let cOffset = 0; cOffset < shapeCols && canClaim; cOffset++) {
            const r = startRow + rOffset
            const c = startCol + cOffset
            if (!inBounds(r, c)) {
              canClaim = false
              break
            }
            const idx = idxAt(r, c)
            if (!groupSet.has(idx) || instanceVisited.has(idx)) {
              canClaim = false
              break
            }
          }
        }
        
        if (!canClaim) return null
        
        for (let rOffset = 0; rOffset < shapeRows; rOffset++) {
          for (let cOffset = 0; cOffset < shapeCols; cOffset++) {
            const idx = idxAt(startRow + rOffset, startCol + cOffset)
            instanceCells.push(idx)
            instanceVisited.add(idx)
          }
        }
        
        return instanceCells
      }
      
      // PASS 1: Horizontal placements
      if (!isSquareShape) {
        for (let r = minR; r <= maxR; r++) {
          for (let c = minC; c <= maxC; c++) {
            const idx = idxAt(r, c)
            if (!groupSet.has(idx) || instanceVisited.has(idx)) continue
            
            const instanceCells = tryClaimShape(idx, true)
            if (instanceCells) {
              let iMinR = bedRows, iMaxR = -1, iMinC = bedCols, iMaxC = -1
              instanceCells.forEach(idx => {
                const { row, col } = idxToRowCol(idx)
                iMinR = Math.min(iMinR, row)
                iMaxR = Math.max(iMaxR, row)
                iMinC = Math.min(iMinC, col)
                iMaxC = Math.max(iMaxC, col)
              })
              
              plantInstances.push({
                cells: instanceCells,
                minR: iMinR, maxR: iMaxR, minC: iMinC, maxC: iMaxC,
                centerR: (iMinR + iMaxR) / 2 + 0.5,
                centerC: (iMinC + iMaxC) / 2 + 0.5
              })
            }
          }
        }
      }
      
      // PASS 2: Fill gaps
      for (let r = minR; r <= maxR; r++) {
        for (let c = minC; c <= maxC; c++) {
          const idx = idxAt(r, c)
          if (!groupSet.has(idx) || instanceVisited.has(idx)) continue
          
          const instanceCells = tryClaimShape(idx, isSquareShape)
          if (instanceCells) {
            let iMinR = bedRows, iMaxR = -1, iMinC = bedCols, iMaxC = -1
            instanceCells.forEach(idx => {
              const { row, col } = idxToRowCol(idx)
              iMinR = Math.min(iMinR, row)
              iMaxR = Math.max(iMaxR, row)
              iMinC = Math.min(iMinC, col)
              iMaxC = Math.max(iMaxC, col)
            })
            
            plantInstances.push({
              cells: instanceCells,
              minR: iMinR, maxR: iMaxR, minC: iMinC, maxC: iMaxC,
              centerR: (iMinR + iMaxR) / 2 + 0.5,
              centerC: (iMinC + iMaxC) / 2 + 0.5
            })
          }
        }
      }
      
      groups.push({
        code,
        plant,
        cellIndices: group,
        plantInstances
      })
    }
    
    return groups
  }

  /**
   * Get high contrast text color (white or black) based on background color
   */
  static getContrastColor(red, green, blue) {
    // Calculate relative luminance using WCAG formula
    const luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? [0, 0, 0] : [255, 255, 255]
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
