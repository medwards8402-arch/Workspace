import React, { useMemo } from 'react'
import { USDA_ZONES } from '../data'

export function ZoneSelector({ zone, onChange }) {
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
      <div className="input-group input-group-sm w-auto">
        <span className="input-group-text" title="USDA Hardiness Zone for your location">Zone</span>
        <select 
          className="form-select form-select-sm" 
          value={zone} 
          onChange={e => onChange(e.target.value)} 
          onClick={(e) => e.stopPropagation()} 
          title="Select your USDA hardiness zone to calculate planting dates"
          style={{width: '85px'}}
        >
          {Object.keys(USDA_ZONES).map(z => <option key={z} value={z}>{z}</option>)}
        </select>
      </div>
      <div className="input-group input-group-sm w-auto">
        <span className="input-group-text" title="Average last frost date for your zone">Last Frost</span>
        <input 
          className="form-control form-control-sm" 
          readOnly 
          value={frost} 
          title={`Average last frost date for zone ${zone}`}
          style={{width: '100px'}}
        />
      </div>
    </div>
  )
}
