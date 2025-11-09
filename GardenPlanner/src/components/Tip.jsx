import React from 'react'
import { useTips } from '../context/TipsContext'

/**
 * Tip component - displays helpful tips with individual dismiss functionality
 * @param {string} id - Unique identifier for the tip
 * @param {React.ReactNode} children - Tip content
 */
export function Tip({ id, children }) {
  const { dismissTip, isTipDismissed } = useTips()

  if (isTipDismissed(id)) {
    return null
  }

  return (
    <div className="alert alert-info py-1 mb-0 d-flex align-items-center justify-content-between">
      <small className="mb-0 flex-grow-1">
        💡 <strong>Tip:</strong> {children}
      </small>
      <button
        type="button"
        className="btn btn-sm btn-outline-secondary ms-3"
        onClick={() => dismissTip(id)}
        title="Dismiss this tip"
      >
        Dismiss
      </button>
    </div>
  )
}
