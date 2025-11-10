// Data definitions ported from vanilla version
export const USDA_ZONES = {
  // Each zone includes:
  // - month/day: average last spring frost (used for spring scheduling)
  // - firstMonth/firstDay: average first fall frost (used for fall scheduling)
  '3a': { month: 5, day: 25, firstMonth: 9, firstDay: 8 },
  '3b': { month: 5, day: 20, firstMonth: 9, firstDay: 15 },
  '4a': { month: 5, day: 15, firstMonth: 9, firstDay: 21 },
  '4b': { month: 5, day: 10, firstMonth: 9, firstDay: 28 },
  '5a': { month: 5, day: 5,  firstMonth: 10, firstDay: 10 },
  '5b': { month: 4, day: 30, firstMonth: 10, firstDay: 15 },
  '6a': { month: 4, day: 20, firstMonth: 10, firstDay: 25 },
  '6b': { month: 4, day: 15, firstMonth: 10, firstDay: 30 },
  '7a': { month: 4, day: 5,  firstMonth: 11, firstDay: 10 },
  '7b': { month: 3, day: 30, firstMonth: 11, firstDay: 20 },
  '8a': { month: 3, day: 20, firstMonth: 11, firstDay: 30 },
  '8b': { month: 3, day: 10, firstMonth: 12, firstDay: 10 },
  '9a': { month: 2, day: 25, firstMonth: 12, firstDay: 20 },
  '9b': { month: 2, day: 15, firstMonth: 12, firstDay: 31 },
  // Zones 10+ typically have no frost; omit fall date
  '10a': { month: 1, day: 31, firstMonth: null, firstDay: null },
  '10b': { month: 1, day: 20, firstMonth: null, firstDay: null },
};

// Tips policy for PLANTS entries:
// - Include tips ONLY when they are significantly unique to that plant's care
//   (e.g., special planting timing, required structures, notable cold/heat behavior,
//   transplant caveats, allelopathy/companions). Avoid generic advice like
//   "keep watered", flavor notes, or renaming trivia.
// - Keep tips concise and actionable; prefer at most 1–2 items per plant.
// - When in doubt, omit the tip.
export const PLANTS = [
  { name: 'Arugula', code: 'ARU', icon: '🥬', color: '#84cc16', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 5, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Artichoke', code: 'ART', icon: '🌿', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high', tips: ['Perennial in zones 7+; treat as annual in colder zones', 'Harvest before flowers fully open'] },
  { name: 'Asparagus', code: 'ASP', icon: '🌿', color: '#059669', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 104, sqftSpacing: 1, lightLevel: 'high', tips: ['Perennial; do not harvest for 2–3 years after planting crowns', 'Dedicated bed recommended; deep roots and long-lived'] },
  { name: 'Basil', code: 'BAS', icon: '🌿', color: '#22c55e', type: 'herb', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Beans', code: 'BNB', icon: '🫘', color: '#047857', type: 'vegetable', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 9, lightLevel: 'high' },
  { name: 'Beet', code: 'BET', icon: '🟣', color: '#be123c', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0 },
  { name: 'Bok Choy', code: 'BOK', icon: '🥬', color: '#86efac', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 42, fallStartIndoorsWeeks: 0, tips: ['Fast-growing Asian green; harvest before bolting'] },
  { name: 'Broccoli', code: 'BRC', icon: '🥦', color: '#166534', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6 },
  { name: 'Brussels Sprouts', code: 'BRS', icon: '🥦', color: '#14532d', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 6, harvestWeeks: 16, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Cabbage', code: 'CAB', icon: '🥬', color: '#94a3b8', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 6, harvestWeeks: 11, sqftSpacing: 1, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6 },
  { name: 'Carrot', code: 'CAR', icon: '🥕', color: '#fb923c', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 16, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 0 },
  { name: 'Cauliflower', code: 'CAF', icon: '🥦', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 75, fallStartIndoorsWeeks: 6 },
  { name: 'Celery', code: 'CEL', icon: '🥬', color: '#84cc16', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 10, harvestWeeks: 16, sqftSpacing: 4, lightLevel: 'high', tips: ['Long growing season; keep consistently moist', 'Start indoors well before last frost'] },
  { name: 'Chives', code: 'CHV', icon: '🌿', color: '#4ade80', type: 'herb', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 16, lightLevel: 'high' },
  { name: 'Cilantro', code: 'CIL', icon: '🌿', color: '#10b981', type: 'herb', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 9, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Collard Greens', code: 'COL', icon: '🥬', color: '#166534', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 4, harvestWeeks: 11, sqftSpacing: 1, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 0, tips: ['Very cold-hardy; flavor improves after frost'] },
  { name: 'Corn', code: 'CRN', icon: '🌽', color: '#f59e0b', type: 'vegetable', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 11, sqftSpacing: 4, lightLevel: 'high', tips: ['Plant in blocks (not single rows) for better pollination'] },
  { name: 'Cucumber', code: 'CUC', icon: '🥒', color: '#15803d', type: 'vegetable', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 2, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Dill', code: 'DIL', icon: '🌿', color: '#86efac', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 9, lightLevel: 'high' },
  { name: 'Eggplant', code: 'EGG', icon: '🍆', color: '#9333ea', type: 'vegetable', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Fennel', code: 'FEN', icon: '🌿', color: '#a3e635', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 4, harvestWeeks: 12, sqftSpacing: 4, lightLevel: 'high', tips: ['Avoid planting near dill or coriander'] },
  { name: 'Garlic', code: 'GAR', icon: '🧄', color: '#78350f', type: 'vegetable', plantAfterFrostDays: -180, startIndoorsWeeks: 0, harvestWeeks: 30, sqftSpacing: 4, lightLevel: 'high', tips: ['Best planted in fall for summer harvest', 'Mulch well over winter in cold climates'] },
  { name: 'Green Onions', code: 'GON', icon: '🧅', color: '#65a30d', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 16, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Can regrow from roots if base is left in soil'] },
  { name: 'Kale', code: 'KAL', icon: '🥬', color: '#1e3a8a', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 5, harvestWeeks: 8, sqftSpacing: 1, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 5 },
  { name: 'Kohlrabi', code: 'KOH', icon: '🥬', color: '#a78bfa', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 4, harvestWeeks: 8, sqftSpacing: 4, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Harvest when bulb is 2-3 inches in diameter'] },
  { name: 'Leeks', code: 'LEK', icon: '🧅', color: '#6d7c26', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 8, harvestWeeks: 16, sqftSpacing: 4, lightLevel: 'high', tips: ['Hill soil around stems to blanch white portion', 'Very cold-hardy; can overwinter in mild climates'] },
  { name: 'Lettuce', code: 'LET', icon: '🥬', color: '#65a30d', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0, tips: ['Bolts in heat; provide shade or succession plant in warm weather'] },
  { name: 'Melon', code: 'MLN', icon: '🍈', color: '#10b981', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Mint', code: 'MNT', icon: '🌿', color: '#34d399', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high', tips: ['Spreads aggressively; consider a container or root barrier'] },
  { name: 'Onion', code: 'ONI', icon: '🧅', color: '#92400e', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 16, lightLevel: 'high' },
  { name: 'Oregano', code: 'ORE', icon: '🌿', color: '#059669', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 6, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Parsley', code: 'PAR', icon: '🌿', color: '#16a34a', type: 'herb', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 4, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0 },
  { name: 'Parsnips', code: 'PRS', icon: '🥕', color: '#fef3c7', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 16, sqftSpacing: 16, lightLevel: 'low', tips: ['Long growing season; best flavor after frost', 'Direct sow; does not transplant well'] },
  { name: 'Pea', code: 'PEA', icon: '🫛', color: '#22c55e', type: 'vegetable', plantAfterFrostDays: -35, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 8, lightLevel: 'low', supportsFall: false },
  { name: 'Pepper', code: 'PEP', icon: '🌶️', color: '#ea580c', type: 'vegetable', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Potato', code: 'POT', icon: '🥔', color: '#a16207', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high', tips: ['Hill soil or mulch around stems to improve yield and prevent greening'] },
  { name: 'Pumpkin', code: 'PUM', icon: '🎃', color: '#ea580c', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4, tips: ['Very sprawling; give ample space or trellis small varieties'] },
  { name: 'Radish', code: 'RAD', icon: '🔴', color: '#ef4444', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 4, sqftSpacing: 16, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Rhubarb', code: 'RHU', icon: '🍃', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high', tips: ['Do not harvest in the first season to establish'] },
  { name: 'Rosemary', code: 'ROS', icon: '🌿', color: '#14532d', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 10, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Rutabaga', code: 'RUT', icon: '🟡', color: '#eab308', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 90, fallStartIndoorsWeeks: 0, tips: ['Flavor improves after frost'] },
  { name: 'Sage', code: 'SAG', icon: '🌿', color: '#15803d', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Shallots', code: 'SHA', icon: '🧅', color: '#92400e', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 9, lightLevel: 'high', tips: ['Plant in fall or early spring', 'Each bulb multiplies into a cluster'] },
  { name: 'Spinach', code: 'SPI', icon: '🥬', color: '#0f766e', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0, tips: ['Prefers cool weather; bolts quickly in heat'] },
  { name: 'Squash', code: 'SQW', icon: '🎃', color: '#b45309', type: 'vegetable', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 13, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Strawberries', code: 'STR', icon: '🍓', color: '#f43f5e', type: 'fruit', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 4, lightLevel: 'high', tips: ['Perennial; renovate beds annually and manage runners'] },
  { name: 'Sweet Potato', code: 'SWE', icon: '🍠', color: '#b45309', type: 'vegetable', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 16, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2, tips: ['Plant slips (not seeds); warm soil required'] },
  { name: 'Swiss Chard', code: 'CHD', icon: '🥬', color: '#14b8a6', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0 },
  { name: 'Thyme', code: 'THY', icon: '🌿', color: '#166534', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Tomato', code: 'TOM', icon: '🍅', color: '#dc2626', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 1, lightLevel: 'high', tips: ['Provide support (stakes/cages); prune indeterminates for airflow'] },
  { name: 'Tomatillo', code: 'TML', icon: '🟢', color: '#22c55e', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 1, lightLevel: 'high', tips: ['Grow at least two plants for better fruit set'] },
  { name: 'Turnips', code: 'TUR', icon: '🟣', color: '#c084fc', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Harvest greens and roots; both are edible'] },
  { name: 'Watermelon', code: 'WAT', icon: '🍉', color: '#10b981', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4 },
  { name: 'Zucchini', code: 'ZUC', icon: '🥒', color: '#4d7c0f', type: 'vegetable', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Blueberry', code: 'BLU', icon: '🫐', color: '#3b82f6', type: 'fruit', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 156, sqftSpacing: 1, lightLevel: 'high', tips: ['Requires acidic soil (pH 4.5–5.5)', 'Perennial; mulch and water regularly'], supportsFall: false },
  { name: 'Raspberry', code: 'RSP', icon: '🍇', color: '#a21caf', type: 'fruit', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 104, sqftSpacing: 1, lightLevel: 'high', tips: ['Provide trellis/support for canes', 'Perennial; prune old canes after fruiting'], supportsFall: false },
  { name: 'Grape', code: 'GRP', icon: '🍇', color: '#6d28d9', type: 'fruit', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 156, sqftSpacing: 1, lightLevel: 'high', tips: ['Provide sturdy trellis or arbor', 'Prune annually for best yield'], supportsFall: false },
];

export const BED_ROWS = 8;
export const BED_COLS = 4;
export const BED_COUNT = 3;
