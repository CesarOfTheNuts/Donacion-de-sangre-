const GRUPOS = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

// Acepta "male", "Male", "FEMALE"... y devuelve 'Male' | 'Female' | 'Other' | null
function normalizarGenero(g) {
  if (!g) return null;
  const v = String(g).trim().toLowerCase();
  if (v === 'male') return 'Male';
  if (v === 'female') return 'Female';
  if (v === 'other') return 'Other';
  return null;
}

// Convierte "" en null y recorta espacios
const limpio = (v) => {
  if (v === undefined || v === null) return null;
  const s = String(v).trim();
  return s === '' ? null : s;
};

module.exports = { GRUPOS, normalizarGenero, limpio };
