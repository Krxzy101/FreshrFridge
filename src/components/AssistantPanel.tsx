import { useCallback, useEffect, useState } from 'react'
import { checkApiHealth, syncInventory, type Suggestions } from '../lib/api'
import { speakText, speechSupported, stopSpeaking } from '../lib/speech'
import type { FridgeItem } from '../types'

type Props = {
  items: FridgeItem[]
}

function buildSpeechText(items: FridgeItem[], suggestions: Suggestions | null): string {
  if (!suggestions) {
    if (items.length === 0) {
      return 'Your fridge is empty. Add some items with expiry dates, then tap Talk again for advice.'
    }
    return `You have ${items.length} item${items.length === 1 ? '' : 's'} in the fridge. Tap Talk to hear AI suggestions.`
  }

  const parts: string[] = []
  if (suggestions.expiry_warnings.length) {
    parts.push(
      'Expiry alerts. ' +
        suggestions.expiry_warnings.map((w) => `${w.item}: ${w.message}`).join('. '),
    )
  }
  if (suggestions.tip) parts.push(suggestions.tip)
  if (suggestions.recipes[0]) {
    parts.push(
      `Recipe idea: ${suggestions.recipes[0].name}. ${suggestions.recipes[0].instructions}`,
    )
  }
  if (suggestions.shopping_suggestions.length) {
    parts.push(`Shopping ideas: ${suggestions.shopping_suggestions.join(', ')}`)
  }
  return parts.join(' ') || 'No suggestions right now. Add items with expiry dates.'
}

export function AssistantPanel({ items }: Props) {
  const [online, setOnline] = useState<boolean | null>(null)
  const [loading, setLoading] = useState(false)
  const [speaking, setSpeaking] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [speechError, setSpeechError] = useState<string | null>(null)
  const [suggestions, setSuggestions] = useState<Suggestions | null>(null)
  const canSpeak = speechSupported()

  const refreshOnline = useCallback(async () => {
    setOnline(await checkApiHealth())
  }, [])

  useEffect(() => {
    let cancelled = false
    checkApiHealth().then((ok) => {
      if (!cancelled) setOnline(ok)
    })
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => () => stopSpeaking(), [])

  async function askAssistant(): Promise<Suggestions | null> {
    setLoading(true)
    setError(null)
    try {
      const result = await syncInventory(items)
      setSuggestions(result)
      setOnline(true)
      return result
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not reach the assistant server')
      setOnline(false)
      return null
    } finally {
      setLoading(false)
    }
  }

  async function speakNow(text: string) {
    if (!canSpeak) {
      setSpeechError('Your browser does not support speech. Try Chrome or Edge.')
      return
    }
    setSpeechError(null)
    setSpeaking(true)
    stopSpeaking()
    try {
      await speakText(text)
    } catch {
      setSpeechError('Could not play speech. Click Talk again.')
    } finally {
      setSpeaking(false)
    }
  }

  /** Main on-screen Talk button: fetch AI (if online) then speak aloud */
  async function handleTalk() {
    if (loading || speaking) return

    if (online === false) {
      await speakNow(buildSpeechText(items, suggestions))
      return
    }

    let latest = suggestions
    if (online && items.length > 0) {
      latest = await askAssistant()
    }

    await speakNow(buildSpeechText(items, latest))
  }

  return (
    <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ring-1 ring-slate-100">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold text-slate-900">AI assistant</h2>
          <p className="mt-1 text-sm text-slate-600">
            Tap <strong>Talk</strong> to hear advice aloud. Uses backend on port 3000 when online.
          </p>
        </div>
        <span
          className={`rounded-full px-3 py-1 text-xs font-medium ${
            online === null
              ? 'bg-slate-100 text-slate-600'
              : online
                ? 'bg-emerald-100 text-emerald-800'
                : 'bg-amber-100 text-amber-900'
          }`}
        >
          {online === null ? 'Checking server…' : online ? 'Server online' : 'Server offline'}
        </span>
      </div>

      <div className="mt-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <button
          type="button"
          onClick={() => void handleTalk()}
          disabled={loading || speaking || !canSpeak}
          className="flex min-h-14 min-w-[200px] flex-1 items-center justify-center gap-2 rounded-2xl bg-emerald-600 px-6 py-4 text-lg font-semibold text-white shadow-md transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-50"
          aria-label="Talk — hear fridge advice aloud"
        >
          <span className="text-2xl" aria-hidden>
            {speaking ? '🔊' : '🎤'}
          </span>
          {loading ? 'Thinking…' : speaking ? 'Speaking…' : 'Talk'}
        </button>

        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => void askAssistant()}
            disabled={loading || speaking}
            className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-2 text-sm font-medium text-emerald-800 hover:bg-emerald-100 disabled:opacity-50"
          >
            {loading ? 'Loading…' : 'Get suggestions'}
          </button>
          <button
            type="button"
            onClick={() => void refreshOnline()}
            disabled={loading || speaking}
            className="rounded-lg border border-slate-200 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50 disabled:opacity-50"
          >
            Retry connection
          </button>
        </div>
      </div>

      {!canSpeak && (
        <p className="mt-2 text-sm text-amber-800">
          Speech needs Chrome or Edge. Open this page in one of those browsers.
        </p>
      )}

      {error && (
        <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-800">{error}</p>
      )}

      {speechError && (
        <p className="mt-3 rounded-lg bg-amber-50 px-3 py-2 text-sm text-amber-900">
          {speechError}
        </p>
      )}

      {!online && online !== null && (
        <p className="mt-3 text-sm text-amber-800">
          Backend offline — Talk still works for a short message. For AI advice, run{' '}
          <code className="rounded bg-amber-50 px-1">START-BACKEND.bat</code>
        </p>
      )}

      {suggestions && (
        <div className="mt-4 space-y-4 text-sm text-slate-700">
          {suggestions.expiry_warnings.length > 0 && (
            <div>
              <h3 className="font-semibold text-slate-900">Expiry warnings</h3>
              <ul className="mt-1 list-disc space-y-1 pl-5">
                {suggestions.expiry_warnings.map((w, i) => (
                  <li key={`${w.item}-${i}`}>
                    <strong>{w.item}</strong>: {w.message}
                  </li>
                ))}
              </ul>
            </div>
          )}
          {suggestions.recipes.length > 0 && (
            <div>
              <h3 className="font-semibold text-slate-900">Recipes</h3>
              <ul className="mt-1 space-y-2">
                {suggestions.recipes.map((r) => (
                  <li key={r.name} className="rounded-lg bg-emerald-50/80 p-3">
                    <p className="font-medium text-emerald-900">{r.name}</p>
                    <p className="mt-1 text-slate-600">{r.instructions}</p>
                  </li>
                ))}
              </ul>
            </div>
          )}
          {suggestions.shopping_suggestions.length > 0 && (
            <div>
              <h3 className="font-semibold text-slate-900">Shopping list</h3>
              <p className="mt-1">{suggestions.shopping_suggestions.join(', ')}</p>
            </div>
          )}
          {suggestions.tip && (
            <p className="rounded-lg bg-slate-50 p-3 italic text-slate-600">{suggestions.tip}</p>
          )}
        </div>
      )}
    </section>
  )
}
