import React from 'react'
import { GardenBed } from './GardenBed'

export function Beds({ beds }) {
  return (
    <div className="d-flex flex-wrap gap-3">
      {beds.map((bed, idx) => (
        <GardenBed key={idx} bedIndex={idx} />
      ))}
    </div>
  )
}
