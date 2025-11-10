# Garden Planner React

Migrated the vanilla JS garden planner to React + Bootstrap.

**Live Demo:** https://medwards8402-arch.github.io/Workspace/

## Features
- 3 beds (4 x 8 cells) with drag-and-drop planting
- Plant palette with emoji icons
- USDA zone selector and auto last-frost date
- Month-organized planting calendar (indoor start, sow/transplant, harvest)
- LocalStorage persistence with invalid code auto-reset
- Dark theme using Bootstrap 5.3

## Getting Started

### Development
```bash
npm install
npm run dev
```
Open http://localhost:5173

### Deploy to GitHub Pages
```bash
npm run deploy
```
This builds the project and deploys to the `gh-pages` branch. The site will be available at:
`https://<username>.github.io/Workspace/`

## File Structure
- `src/data.js` Data constants
- `src/calendar.js` Calendar task logic
- `src/App.jsx` Main application
- `src/styles.css` Theme overrides

## Notes
- Drag-and-drop uses native HTML5 API.
- Adjust plant definitions in `data.js`.
- Storage key: `gardenPlannerState`.
- GitHub Pages deployment uses query-parameter SPA redirect for deep linking (see `public/404.html` and `index.html`).
- Base path is configured in `vite.config.js` as `/Workspace/` to match the repository name.

## Future Enhancements
- Group selection / multi-delete
- Better mobile layout
- Export/import garden plan
