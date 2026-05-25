import { useMemo, useState } from 'react'
import { AddItemForm } from './components/AddItemForm'
import { AssistantPanel } from './components/AssistantPanel'
import { FridgeItemCard } from './components/FridgeItemCard'
import { UseFirstPanel } from './components/UseFirstPanel'
import { useFridgeItems } from './hooks/useFridgeItems'
import { CATEGORIES, type Category } from './types'

type Tab = 'priority' | 'inventory'

function App() {
  const { items, addItem, useOne, removeItem } = useFridgeItems()
  const [tab, setTab] = useState<Tab>('priority')
  const [filterCategory, setFilterCategory] = useState<Category | 'all'>('all')

  const filteredInventory = useMemo(() => {
    if (filterCategory === 'all') return items
    return items.filter((item) => item.category === filterCategory)
  }, [items, filterCategory])

  const stats = useMemo(() => {
    const withExpiry = items.filter((i) => i.expirationDate).length
    return { total: items.length, withExpiry }
  }, [items])

  return (
    <div className="min-h-svh bg-gradient-to-b from-emerald-50 to-slate-50">
      <header className="border-b border-emerald-100/80 bg-white/80 backdrop-blur">
        <div className="mx-auto max-w-3xl px-4 py-6">
          <p className="text-sm font-medium uppercase tracking-wide text-emerald-600">
            FreshrFridge
          </p>
          <h1 className="mt-1 text-2xl font-bold text-slate-900 sm:text-3xl">
            Fridge assistant
          </h1>
          <p className="mt-1 text-slate-600">
            Track what&apos;s inside and use the right items before they spoil.
          </p>
          {stats.total > 0 && (
            <p className="mt-2 text-sm text-slate-500">
              {stats.total} item{stats.total === 1 ? '' : 's'} tracked
              {stats.withExpiry > 0 &&
                ` · ${stats.withExpiry} with expiry date${stats.withExpiry === 1 ? '' : 's'}`}
            </p>
          )}
        </div>
      </header>

      <main className="mx-auto max-w-3xl space-y-6 px-4 py-8">
        <AddItemForm onAdd={addItem} />

        <AssistantPanel items={items} />

        <div className="flex gap-2 rounded-xl bg-white p-1 shadow-sm ring-1 ring-slate-100">
          <button
            type="button"
            onClick={() => setTab('priority')}
            className={`flex-1 rounded-lg px-3 py-2 text-sm font-medium transition ${
              tab === 'priority'
                ? 'bg-emerald-600 text-white'
                : 'text-slate-600 hover:bg-slate-50'
            }`}
          >
            Use first
          </button>
          <button
            type="button"
            onClick={() => setTab('inventory')}
            className={`flex-1 rounded-lg px-3 py-2 text-sm font-medium transition ${
              tab === 'inventory'
                ? 'bg-emerald-600 text-white'
                : 'text-slate-600 hover:bg-slate-50'
            }`}
          >
            All items
          </button>
        </div>

        {tab === 'priority' ? (
          <UseFirstPanel items={items} onUseOne={useOne} onRemove={removeItem} />
        ) : (
          <section>
            <div className="mb-4 flex flex-wrap items-end justify-between gap-3">
              <div>
                <h2 className="text-xl font-semibold text-slate-900">Full inventory</h2>
                <p className="text-sm text-slate-600">Filter by category</p>
              </div>
              <select
                value={filterCategory}
                onChange={(e) =>
                  setFilterCategory(e.target.value as Category | 'all')
                }
                className="rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-900"
              >
                <option value="all">All categories</option>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
            {filteredInventory.length === 0 ? (
              <p className="rounded-xl border border-dashed border-slate-200 p-6 text-center text-slate-500">
                No items in this category.
              </p>
            ) : (
              <ul className="space-y-3">
                {filteredInventory.map((item) => (
                  <li key={item.id}>
                    <FridgeItemCard
                      item={item}
                      onUseOne={useOne}
                      onRemove={removeItem}
                    />
                  </li>
                ))}
              </ul>
            )}
          </section>
        )}
      </main>

      <footer className="pb-8 text-center text-xs text-slate-400">
        Inventory saved in your browser · AI suggestions use the local backend when online
      </footer>
    </div>
  )
}

export default App
