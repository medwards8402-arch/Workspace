import React from 'react'

/**
 * TipsStack - standard vertical stack for Tip components with tight spacing
 * Usage: <TipsStack> <Tip .../> <Tip .../> </TipsStack>
 */
export function TipsStack({ children }) {
  return (
    <div className="tips-stack">
      {children}
    </div>
  )
}
