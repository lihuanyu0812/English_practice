export function normalizeWord(value) {
  return String(value || '')
    .trim()
    .replace(/[.,!?;:"'()[\]{}]/g, '')
    .toLowerCase();
}
