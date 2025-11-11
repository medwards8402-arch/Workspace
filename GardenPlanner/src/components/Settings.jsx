import React from 'react'
import { useTips } from '../context/TipsContext'
import { useSettings } from '../context/SettingsContext'

/**
 * Settings component - application preferences and configuration
 */
export function Settings() {
  const { resetAllTips, dismissedTips, dismissTip } = useTips()
  const { settings, updateSetting } = useSettings()

  // Get all possible tip IDs
  const allTipIds = [
    'garden-plan-selection',
    'calendar-zone-based',
    'save-often',
    'pdf-print-guide'
  ]

  const handleDisableAllTips = () => {
    allTipIds.forEach(tipId => {
      if (!dismissedTips.includes(tipId)) {
        dismissTip(tipId)
      }
    })
  }

  return (
    <div className="row g-4">
      <div className="col-12">
        <div className="card">
          <div className="card-header">
            <h5 className="card-title m-0">Display Preferences</h5>
          </div>
          <div className="card-body">
            <h6>Tips</h6>
            <p className="text-muted small mb-3">
              Tips appear throughout the application to help you learn features. You can dismiss tips individually, 
              and use the buttons below to manage them all at once.
            </p>
            <div className="d-flex align-items-center gap-3 mb-3">
              <button
                className="btn btn-primary"
                onClick={resetAllTips}
              >
                Re-enable All Tips
              </button>
              <button
                className="btn btn-outline-danger"
                onClick={handleDisableAllTips}
              >
                Disable All Tips
              </button>
              <span className="text-muted small">
                {dismissedTips.length === 0 ? (
                  'All tips are currently visible'
                ) : (
                  `${dismissedTips.length} tip${dismissedTips.length > 1 ? 's' : ''} dismissed`
                )}
              </span>
            </div>
            <div className="alert alert-info mt-3 mb-0">
              <small>
                <strong>Note:</strong> Tip preferences are saved locally in your browser and persist across sessions, 
                but are not included in exported garden plan files.
              </small>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
