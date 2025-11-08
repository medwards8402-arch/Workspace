# Garden Planner React

Migrated the vanilla JS garden planner to React + Bootstrap.

## Features
- 3 beds (4 x 8 cells) with drag-and-drop planting
- Plant palette with emoji icons
- USDA zone selector and auto last-frost date
- Month-organized planting calendar (indoor start, sow/transplant, harvest)
- LocalStorage persistence with invalid code auto-reset
- Dark theme using Bootstrap 5.3

## Getting Started
```bash
npm install
npm run dev
```
Open http://localhost:5173

## File Structure
- `src/data.js` Data constants
- `src/calendar.js` Calendar task logic
- `src/App.jsx` Main application
- `src/styles.css` Theme overrides

## Notes
- Drag-and-drop uses native HTML5 API.
- Adjust plant definitions in `data.js`.
- Storage key: `gardenPlannerState`.

## Future Enhancements
- Group selection / multi-delete
- Better mobile layout
- Export/import garden plan
