import type { FridgeItem } from '../types'

const STORAGE_KEY = 'freshrfridge-items'

export function loadItems(): FridgeItem[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return []
    const parsed = JSON.parse(raw) as FridgeItem[]
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

export function saveItems(items: FridgeItem[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items))
}
