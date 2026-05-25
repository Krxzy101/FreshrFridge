import type { FridgeItem } from '../types'

/**
 * API base URL. Defaults to /api so the Vite dev proxy forwards to localhost:3000
 * (same origin as the page — avoids host/CORS issues with 127.0.0.1 vs localhost).
 */
export const API_BASE =
  import.meta.env.VITE_API_BASE?.replace(/\/$/, '') ?? '/api'

export type Suggestions = {
  expiry_warnings: { item: string; message: string; urgency: string }[]
  recipes: {
    name: string
    ingredients_used: string[]
    instructions: string
    time_minutes: number
  }[]
  shopping_suggestions: string[]
  tip: string
}

function toApiItem(item: FridgeItem) {
  return {
    id: item.id,
    name: item.name,
    quantity: item.quantity,
    unit: item.unit,
    category: item.category,
    date_added: item.dateAdded,
    expiration_date: item.expirationDate ?? '',
    notes: item.notes,
  }
}

export async function syncInventory(items: FridgeItem[]): Promise<Suggestions> {
  const res = await fetch(`${API_BASE}/inventory`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ items: items.map(toApiItem) }),
  })
  if (!res.ok) {
    const err = (await res.json().catch(() => ({}))) as { error?: string }
    throw new Error(err.error ?? `Server error (${res.status})`)
  }
  const data = (await res.json()) as { suggestions: Suggestions }
  return data.suggestions
}

export async function checkApiHealth(): Promise<boolean> {
  try {
    const res = await fetch(`${API_BASE}/health`, { signal: AbortSignal.timeout(3000) })
    return res.ok
  } catch {
    return false
  }
}
