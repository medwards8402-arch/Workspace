import React from 'react';

/**
 * Error boundary component to catch and display React errors gracefully
 */
export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    this.state = { ...this.state, error, errorInfo };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="container py-5">
          <div className="alert alert-danger">
            <h4 className="alert-heading">Something went wrong</h4>
            <p>The Garden Planner encountered an error. Please try refreshing the page.</p>
            {import.meta.env.DEV && this.state.error && (
              <details className="mt-3">
                <summary>Error Details (Development Mode)</summary>
                <pre className="mt-2 p-3 bg-light rounded">
                  <code>{this.state.error.toString()}</code>
                  {this.state.errorInfo && (
                    <code className="d-block mt-2">{this.state.errorInfo.componentStack}</code>
                  )}
                </pre>
              </details>
            )}
            <hr />
            <div className="d-flex gap-2">
              <button 
                className="btn btn-primary" 
                onClick={() => window.location.reload()}
              >
                Refresh Page
              </button>
              <button 
                className="btn btn-outline-secondary" 
                onClick={() => {
                  localStorage.removeItem('gardenPlannerState');
                  window.location.reload();
                }}
              >
                Clear Data & Refresh
              </button>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
