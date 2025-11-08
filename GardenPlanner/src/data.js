// Data definitions ported from vanilla version
export const USDA_ZONES = {
  '3a': { month: 5, day: 25 }, '3b': { month: 5, day: 20 },
  '4a': { month: 5, day: 15 }, '4b': { month: 5, day: 10 },
  '5a': { month: 5, day: 5 },  '5b': { month: 4, day: 30 },
  '6a': { month: 4, day: 20 }, '6b': { month: 4, day: 15 },
  '7a': { month: 4, day: 5 },  '7b': { month: 3, day: 30 },
  '8a': { month: 3, day: 20 }, '8b': { month: 3, day: 10 },
  '9a': { month: 2, day: 25 }, '9b': { month: 2, day: 15 },
  '10a': { month: 1, day: 31 }, '10b': { month: 1, day: 20 },
};

export const PLANTS = [
  { name: 'Arugula', code: 'ARU', icon: '🥬', color: '#84cc16', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 5 },
  { name: 'Asparagus', code: 'ASP', icon: '🌿', color: '#059669', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 104 },
  { name: 'Beans', code: 'BNB', icon: '🫘', color: '#047857', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8 },
  { name: 'Beet', code: 'BET', icon: '🟣', color: '#be123c', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9 },
  { name: 'Broccoli', code: 'BRC', icon: '🥦', color: '#166534', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9 },
  { name: 'Cabbage', code: 'CAB', icon: '🥬', color: '#94a3b8', plantAfterFrostDays: -28, startIndoorsWeeks: 6, harvestWeeks: 11 },
  { name: 'Carrot', code: 'CAR', icon: '🥕', color: '#fb923c', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9 },
  { name: 'Cauliflower', code: 'CAF', icon: '🥦', color: '#6b7280', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 9 },
  { name: 'Corn', code: 'CRN', icon: '🌽', color: '#f59e0b', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 11 },
  { name: 'Cucumber', code: 'CUC', icon: '🥒', color: '#15803d', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 7 },
  { name: 'Eggplant', code: 'EGG', icon: '🍆', color: '#9333ea', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12 },
  { name: 'Garlic', code: 'GAR', icon: '🧄', color: '#78350f', plantAfterFrostDays: -180, startIndoorsWeeks: 0, harvestWeeks: 30 },
  { name: 'Kale', code: 'KAL', icon: '🥬', color: '#1e3a8a', plantAfterFrostDays: -28, startIndoorsWeeks: 5, harvestWeeks: 8 },
  { name: 'Lettuce', code: 'LET', icon: '🥬', color: '#65a30d', plantAfterFrostDays: -28, startIndoorsWeeks: 4, harvestWeeks: 7 },
  { name: 'Melon', code: 'MLN', icon: '🍈', color: '#10b981', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 12 },
  { name: 'Onion', code: 'ONI', icon: '🧅', color: '#92400e', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 12 },
  { name: 'Pea', code: 'PEA', icon: '🫛', color: '#22c55e', plantAfterFrostDays: -35, startIndoorsWeeks: 0, harvestWeeks: 10 },
  { name: 'Pepper', code: 'PEP', icon: '🌶️', color: '#ea580c', plantAfterFrostDays: 21, startIndoorsWeeks: 8, harvestWeeks: 12 },
  { name: 'Potato', code: 'POT', icon: '🥔', color: '#a16207', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 12 },
  { name: 'Pumpkin', code: 'PUM', icon: '🎃', color: '#ea580c', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 14 },
  { name: 'Radish', code: 'RAD', icon: '🔴', color: '#ef4444', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 4 },
  { name: 'Spinach', code: 'SPI', icon: '🥬', color: '#0f766e', plantAfterFrostDays: -28, startIndoorsWeeks: 4, harvestWeeks: 6 },
  { name: 'Squash', code: 'SQW', icon: '🎃', color: '#b45309', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 13 },
  { name: 'Strawberries', code: 'STR', icon: '🍓', color: '#f43f5e', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 52 },
  { name: 'Swiss Chard', code: 'CHD', icon: '🥬', color: '#14b8a6', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 8 },
  { name: 'Tomato', code: 'TOM', icon: '🍅', color: '#dc2626', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10 },
  { name: 'Zucchini', code: 'ZUC', icon: '🥒', color: '#4d7c0f', plantAfterFrostDays: 7, startIndoorsWeeks: 0, harvestWeeks: 8 },
];

export const BED_ROWS = 8;
export const BED_COLS = 4;
export const BED_COUNT = 3;
