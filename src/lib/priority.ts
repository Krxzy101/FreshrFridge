import type { FridgeItem, Urgency } from '../types'

export function daysUntil(dateIso: string): number {
  const today = startOfDay(new Date())
  const target = startOfDay(parseLocalDate(dateIso))
  const diffMs = target.getTime() - today.getTime()
  return Math.round(diffMs / (1000 * 60 * 60 * 24))
}

export function getUrgency(item: FridgeItem): Urgency {
  if (!item.expirationDate) return 'unknown'
  const days = daysUntil(item.expirationDate)
  if (days < 0) return 'expired'
  if (days <= 1) return 'critical'
  if (days <= 3) return 'warning'
  if (days <= 7) return 'soon'
  return 'ok'
}

export function sortUseFirst(items: FridgeItem[]): FridgeItem[] {
  return [...items].sort((a, b) => {
    const aHasExpiry = Boolean(a.expirationDate)
    const bHasExpiry = Boolean(b.expirationDate)

    if (aHasExpiry && bHasExpiry) {
      return a.expirationDate!.localeCompare(b.expirationDate!)
    }
    if (aHasExpiry) return -1
    if (bHasExpiry) return 1
    return a.dateAdded.localeCompare(b.dateAdded)
  })
}

export function urgencyLabel(urgency: Urgency): string {
  switch (urgency) {
    case 'expired':
      return 'Expired'
    case 'critical':
      return 'Use today'
    case 'warning':
      return 'Use soon'
    case 'soon':
      return 'This week'
    case 'ok':
      return 'Fresh'
    case 'unknown':
      return 'No expiry set'
  }
}

export function expiryDescription(item: FridgeItem): string {
  if (!item.expirationDate) {
    const added = formatShortDate(item.dateAdded)
    return `Added ${added} · use older items first`
  }
  const days = daysUntil(item.expirationDate)
  if (days < 0) return `Expired ${Math.abs(days)} day${Math.abs(days) === 1 ? '' : 's'} ago`
  if (days === 0) return 'Expires today'
  if (days === 1) return 'Expires tomorrow'
  return `Expires in ${days} days (${formatShortDate(item.expirationDate)})`
}

function startOfDay(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate())
}

function parseLocalDate(iso: string): Date {
  const [y, m, d] = iso.split('-').map(Number)
  return new Date(y, m - 1, d)
}

function formatShortDate(iso: string): string {
  return parseLocalDate(iso).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
  })
}
