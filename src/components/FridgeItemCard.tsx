import { expiryDescription, getUrgency, urgencyLabel } from '../lib/priority'
import type { FridgeItem } from '../types'

type Props = {
  item: FridgeItem
  rank?: number
  onUseOne: (id: string) => void
  onRemove: (id: string) => void
}

const urgencyStyles = {
  expired: 'border-red-200 bg-red-50',
  critical: 'border-amber-300 bg-amber-50',
  warning: 'border-orange-200 bg-orange-50',
  soon: 'border-yellow-200 bg-yellow-50',
  ok: 'border-emerald-100 bg-white',
  unknown: 'border-slate-200 bg-slate-50',
} as const

const badgeStyles = {
  expired: 'bg-red-600 text-white',
  critical: 'bg-amber-600 text-white',
  warning: 'bg-orange-500 text-white',
  soon: 'bg-yellow-500 text-slate-900',
  ok: 'bg-emerald-100 text-emerald-800',
  unknown: 'bg-slate-200 text-slate-700',
} as const

export function FridgeItemCard({ item, rank, onUseOne, onRemove }: Props) {
  const urgency = getUrgency(item)

  return (
    <article
      className={`rounded-xl border p-4 shadow-sm ${urgencyStyles[urgency]}`}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2">
            {rank !== undefined && (
              <span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-emerald-600 text-sm font-bold text-white">
                {rank}
              </span>
            )}
            <h3 className="truncate text-base font-semibold text-slate-900">
              {item.name}
            </h3>
            <span
              className={`rounded-full px-2 py-0.5 text-xs font-medium ${badgeStyles[urgency]}`}
            >
              {urgencyLabel(urgency)}
            </span>
          </div>
          <p className="mt-1 text-sm text-slate-600">
            {item.quantity} {item.unit} · {item.category}
          </p>
          <p className="mt-1 text-sm font-medium text-slate-700">
            {expiryDescription(item)}
          </p>
          {item.notes && (
            <p className="mt-1 text-sm italic text-slate-500">{item.notes}</p>
          )}
        </div>
      </div>
      <div className="mt-3 flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => onUseOne(item.id)}
          className="rounded-lg bg-emerald-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-emerald-700"
        >
          Used 1
        </button>
        <button
          type="button"
          onClick={() => onRemove(item.id)}
          className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm font-medium text-slate-600 hover:bg-slate-50"
        >
          Remove
        </button>
      </div>
    </article>
  )
}
