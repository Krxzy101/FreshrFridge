let voicesReady: Promise<SpeechSynthesisVoice[]> | null = null

function loadVoices(): Promise<SpeechSynthesisVoice[]> {
  if (typeof window === 'undefined' || !('speechSynthesis' in window)) {
    return Promise.resolve([])
  }
  if (voicesReady) return voicesReady

  voicesReady = new Promise((resolve) => {
    const pick = () => {
      const voices = window.speechSynthesis.getVoices()
      if (voices.length) resolve(voices)
    }
    pick()
    window.speechSynthesis.onvoiceschanged = pick
    setTimeout(pick, 250)
    setTimeout(pick, 800)
  })
  return voicesReady
}

export function speechSupported(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window
}

export function speakText(text: string, lang = 'en-US'): Promise<void> {
  const trimmed = text.trim()
  if (!trimmed) return Promise.resolve()

  if (!speechSupported()) {
    console.warn('Speech synthesis is not supported in this browser.')
    return Promise.reject(new Error('Speech not supported in this browser'))
  }

  return loadVoices().then((voices) => {
    window.speechSynthesis.cancel()

    return new Promise<void>((resolve, reject) => {
      const utterance = new SpeechSynthesisUtterance(trimmed)
      utterance.lang = lang
      utterance.rate = 1
      const en =
        voices.find((v) => v.lang.startsWith('en') && v.localService) ??
        voices.find((v) => v.lang.startsWith('en')) ??
        voices[0]
      if (en) utterance.voice = en

      utterance.onend = () => resolve()
      utterance.onerror = () => reject(new Error('Speech failed'))
      window.speechSynthesis.speak(utterance)
    })
  })
}

export function stopSpeaking() {
  if (speechSupported()) window.speechSynthesis.cancel()
}
