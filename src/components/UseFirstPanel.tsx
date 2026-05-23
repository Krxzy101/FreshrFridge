import { sortUseFirst } from '../lib/priority'
import type { FridgeItem } from '../types'
import { FridgeItemCard } from './FridgeItemCard'

type Props = {
  items: FridgeItem[]
  onUseOne: (id: string) => void
  onRemove: (id: string) => void
}

export function UseFirstPanel({ items, onUseOne, onRemove }: Props) {
  const prioritized = sortUseFirst(items)

  if (prioritized.length === 0) {
    return (
      <section className="rounded-2xl border border-dashed border-emerald-200 bg-emerald-50/50 p-8 text-center">
        <p className="text-lg font-medium text-emerald-900">Your fridge is empty</p>
        <p className="mt-1 text-sm text-emerald-700">
          Add items with expiry dates and we&apos;ll tell you what to use first.
        </p>
      </section>
    )
  }

  return (
    <section>
      <div className="mb-4">
        <h2 className="text-xl font-semibold text-slate-900">Use first</h2>
        <p className="text-sm text-slate-600">
          Sorted by expiry date, then by when you added items without a date.
        </p>
      </div>
      <ul className="space-y-3">
        {prioritized.map((item, index) => (
          <li key={item.id}>
            <FridgeItemCard
              item={item}
              rank={index + 1}
              onUseOne={onUseOne}
              onRemove={onRemove}
            />
          </li>
        ))}
      </ul>
    </section>
  )
}
