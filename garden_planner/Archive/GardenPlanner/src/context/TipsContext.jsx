import React, { createContext, useContext, useState, useEffect } from 'react'

const TipsContext = createContext()

export function TipsProvider({ children }) {
  // Load dismissed tips from localStorage
  const [dismissedTips, setDismissedTips] = useState(() => {
    const saved = localStorage.getItem('dismissedTips')
    return saved !== null ? JSON.parse(saved) : []
  })

  // Save dismissed tips to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('dismissedTips', JSON.stringify(dismissedTips))
  }, [dismissedTips])

  const dismissTip = (tipId) => {
    setDismissedTips(prev => [...prev, tipId])
  }

  const isTipDismissed = (tipId) => {
    return dismissedTips.includes(tipId)
  }

  const resetAllTips = () => {
    setDismissedTips([])
  }

  return (
    <TipsContext.Provider value={{ dismissTip, isTipDismissed, resetAllTips, dismissedTips }}>
      {children}
    </TipsContext.Provider>
  )
}

export function useTips() {
  const context = useContext(TipsContext)
  if (!context) {
    throw new Error('useTips must be used within a TipsProvider')
  }
  return context
}
