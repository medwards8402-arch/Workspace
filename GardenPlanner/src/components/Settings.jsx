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
    'auto-planting-guide',
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

  const handleToggleAutoPlanner = () => {
    updateSetting('experimental.autoPlanner', !settings.experimental?.autoPlanner)
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

      {/* Experimental Settings */}
      <div className="col-12">
        <div className="card border-warning">
          <div className="card-header bg-warning bg-opacity-10">
            <h5 className="card-title m-0">
              <span className="me-2">🧪</span>
              Experimental Features
            </h5>
          </div>
          <div className="card-body">
            <div className="alert alert-warning mb-3">
              <strong>⚠️ Warning:</strong> Experimental features may be unstable or incomplete. 
              Use at your own risk and report any issues you encounter.
            </div>

            <div className="form-check form-switch mb-3">
              <input
                className="form-check-input"
                type="checkbox"
                role="switch"
                id="autoPlanner Toggle"
                checked={settings.experimental?.autoPlanner || false}
                onChange={handleToggleAutoPlanner}
              />
              <label className="form-check-label" htmlFor="autoPlannerToggle">
                <strong>Auto Garden Planner</strong>
                <div className="text-muted small mt-1">
                  Enable automatic garden layout generation with plant selection and bed optimization. 
                  This feature is currently buggy and may produce unexpected results.
                </div>
              </label>
            </div>

            {settings.experimental?.autoPlanner && (
              <div className="alert alert-info mb-0">
                <small>
                  <strong>Auto-planner enabled:</strong> The "New" tab will now show plant selection 
                  and bed configuration options for automated layout generation.
                </small>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
