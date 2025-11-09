import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.jsx'
import { ErrorBoundary } from './components/ErrorBoundary.jsx'
import { GardenProvider } from './context/GardenContext.jsx'
import { TipsProvider } from './context/TipsContext.jsx'
import 'bootstrap/dist/css/bootstrap.min.css'
import './styles.css'

createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ErrorBoundary>
      <GardenProvider>
        <TipsProvider>
          <App />
        </TipsProvider>
      </GardenProvider>
    </ErrorBoundary>
  </React.StrictMode>
)
