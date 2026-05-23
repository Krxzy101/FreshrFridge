import { type FormEvent, useState } from 'react'
import { CATEGORIES, type Category } from '../types'

type Props = {
  onAdd: (input: {
    name: string
    quantity: number
    unit: string
    category: Category
    expirationDate: string | null
    notes: string
  }) => void
}

export function AddItemForm({ onAdd }: Props) {
  const [name, setName] = useState('')
  const [quantity, setQuantity] = useState(1)
  const [unit, setUnit] = useState('pcs')
  const [category, setCategory] = useState<Category>('Produce')
  const [expirationDate, setExpirationDate] = useState('')
  const [notes, setNotes] = useState('')

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!name.trim()) return
    onAdd({
      name,
      quantity: Math.max(1, quantity),
      unit,
      category,
      expirationDate: expirationDate || null,
      notes,
    })
    setName('')
    setQuantity(1)
    setUnit('pcs')
    setCategory('Produce')
    setExpirationDate('')
    setNotes('')
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="rounded-2xl border border-emerald-100 bg-white p-5 shadow-sm"
    >
      <h2 className="mb-4 text-lg font-semibold text-slate-900">Add to fridge</h2>
      <div className="grid gap-3 sm:grid-cols-2">
        <label className="block sm:col-span-2">
          <span className="mb-1 block text-sm font-medium text-slate-600">Item name</span>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. Greek yogurt"
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
            required
          />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium text-slate-600">Quantity</span>
          <input
            type="number"
            min={1}
            value={quantity}
            onChange={(e) => setQuantity(Number(e.target.value))}
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
          />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium text-slate-600">Unit</span>
          <input
            type="text"
            value={unit}
            onChange={(e) => setUnit(e.target.value)}
            placeholder="pcs, g, ml…"
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
          />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium text-slate-600">Category</span>
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value as Category)}
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
          >
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium text-slate-600">
            Best before / expiry
          </span>
          <input
            type="date"
            value={expirationDate}
            onChange={(e) => setExpirationDate(e.target.value)}
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
          />
        </label>
        <label className="block sm:col-span-2">
          <span className="mb-1 block text-sm font-medium text-slate-600">Notes (optional)</span>
          <input
            type="text"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Opened yesterday, half container…"
            className="w-full rounded-lg border border-slate-200 px-3 py-2 text-slate-900 outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100"
          />
        </label>
      </div>
      <button
        type="submit"
        className="mt-4 w-full rounded-lg bg-emerald-600 px-4 py-2.5 font-medium text-white transition hover:bg-emerald-700 sm:w-auto"
      >
        Add item
      </button>
    </form>
  )
}
