import { useCallback, useEffect, useState } from 'react'
import { loadItems, saveItems } from '../lib/storage'
import type { Category, FridgeItem } from '../types'

export function useFridgeItems() {
  const [items, setItems] = useState<FridgeItem[]>(() => loadItems())

  useEffect(() => {
    saveItems(items)
  }, [items])

  const addItem = useCallback(
    (input: {
      name: string
      quantity: number
      unit: string
      category: Category
      expirationDate: string | null
      notes: string
    }) => {
      const item: FridgeItem = {
        id: crypto.randomUUID(),
        name: input.name.trim(),
        quantity: input.quantity,
        unit: input.unit.trim() || 'pcs',
        category: input.category,
        expirationDate: input.expirationDate || null,
        dateAdded: todayIso(),
        notes: input.notes.trim(),
      }
      setItems((prev) => [...prev, item])
    },
    [],
  )

  const useOne = useCallback((id: string) => {
    setItems((prev) =>
      prev
        .map((item) =>
          item.id === id ? { ...item, quantity: item.quantity - 1 } : item,
        )
        .filter((item) => item.quantity > 0),
    )
  }, [])

  const removeItem = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id))
  }, [])

  return { items, addItem, useOne, removeItem }
}

function todayIso(): string {
  const d = new Date()
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}
