export const CATEGORIES = [
  'Produce',
  'Dairy',
  'Meat',
  'Seafood',
  'Leftovers',
  'Beverages',
  'Condiments',
  'Other',
] as const

export type Category = (typeof CATEGORIES)[number]

export type FridgeItem = {
  id: string
  name: string
  quantity: number
  unit: string
  category: Category
  expirationDate: string | null
  dateAdded: string
  notes: string
}

export type Urgency = 'expired' | 'critical' | 'warning' | 'soon' | 'ok' | 'unknown'
