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

export const PLANTS = [
  { name: 'Arugula', code: 'ARU', icon: '🥬', color: '#84cc16', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 5, sqftSpacing: 4, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Asparagus', code: 'ASP', icon: '🌿', color: '#059669', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 104, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Basil', code: 'BAS', icon: '🌿', color: '#22c55e', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Beans', code: 'BNB', icon: '🫘', color: '#047857', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 9, lightLevel: 'high' },
  { name: 'Beet', code: 'BET', icon: '🟣', color: '#be123c', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 9, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0 },
  { name: 'Broccoli', code: 'BRC', icon: '🥦', color: '#166534', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6 },
  { name: 'Brussels Sprouts', code: 'BRS', icon: '🥦', color: '#14532d', plantAfterFrostDays: -14, startIndoorsWeeks: 6, harvestWeeks: 16, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Cabbage', code: 'CAB', icon: '🥬', color: '#94a3b8', plantAfterFrostDays: -28, startIndoorsWeeks: 6, harvestWeeks: 11, sqftSpacing: 1, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6 },
  { name: 'Carrot', code: 'CAR', icon: '🥕', color: '#fb923c', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 16, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 0 },
  { name: 'Cauliflower', code: 'CAF', icon: '🥦', color: '#6b7280', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 75, fallStartIndoorsWeeks: 6 },
  { name: 'Chives', code: 'CHV', icon: '🌿', color: '#4ade80', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 16, lightLevel: 'medium' },
  { name: 'Cilantro', code: 'CIL', icon: '🌿', color: '#10b981', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 9, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Corn', code: 'CRN', icon: '🌽', color: '#f59e0b', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 11, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Cucumber', code: 'CUC', icon: '🥒', color: '#15803d', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 2, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Dill', code: 'DIL', icon: '🌿', color: '#86efac', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 9, lightLevel: 'high' },
  { name: 'Eggplant', code: 'EGG', icon: '🍆', color: '#9333ea', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Garlic', code: 'GAR', icon: '🧄', color: '#78350f', plantAfterFrostDays: -180, startIndoorsWeeks: 0, harvestWeeks: 30, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Kale', code: 'KAL', icon: '🥬', color: '#1e3a8a', plantAfterFrostDays: -28, startIndoorsWeeks: 5, harvestWeeks: 8, sqftSpacing: 1, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 5 },
  { name: 'Lettuce', code: 'LET', icon: '🥬', color: '#65a30d', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0 },
  { name: 'Melon', code: 'MLN', icon: '🍈', color: '#10b981', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Mint', code: 'MNT', icon: '🌿', color: '#34d399', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'medium' },
  { name: 'Onion', code: 'ONI', icon: '🧅', color: '#92400e', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 16, lightLevel: 'high' },
  { name: 'Oregano', code: 'ORE', icon: '🌿', color: '#059669', plantAfterFrostDays: -7, startIndoorsWeeks: 6, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Parsley', code: 'PAR', icon: '🌿', color: '#16a34a', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 4, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0 },
  { name: 'Pea', code: 'PEA', icon: '🫛', color: '#22c55e', plantAfterFrostDays: -35, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 8, lightLevel: 'medium', supportsFall: false },
  { name: 'Pepper', code: 'PEP', icon: '🌶️', color: '#ea580c', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Potato', code: 'POT', icon: '🥔', color: '#a16207', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Pumpkin', code: 'PUM', icon: '🎃', color: '#ea580c', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4 },
  { name: 'Radish', code: 'RAD', icon: '🔴', color: '#ef4444', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 4, sqftSpacing: 16, lightLevel: 'medium', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0 },
  { name: 'Rosemary', code: 'ROS', icon: '🌿', color: '#14532d', plantAfterFrostDays: 0, startIndoorsWeeks: 10, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Sage', code: 'SAG', icon: '🌿', color: '#15803d', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Spinach', code: 'SPI', icon: '🥬', color: '#0f766e', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0 },
  { name: 'Squash', code: 'SQW', icon: '🎃', color: '#b45309', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 13, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
  { name: 'Strawberries', code: 'STR', icon: '🍓', color: '#f43f5e', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Swiss Chard', code: 'CHD', icon: '🥬', color: '#14b8a6', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0 },
  { name: 'Thyme', code: 'THY', icon: '🌿', color: '#166534', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 4, lightLevel: 'high' },
  { name: 'Tomato', code: 'TOM', icon: '🍅', color: '#dc2626', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 1, lightLevel: 'high' },
  { name: 'Zucchini', code: 'ZUC', icon: '🥒', color: '#4d7c0f', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2 },
];

export const BED_ROWS = 8;
export const BED_COLS = 4;
export const BED_COUNT = 3;
