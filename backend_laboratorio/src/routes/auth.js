const router = require('express').Router();
const { sql, poolPromise } = require('../db');
const auth = require('../middleware/auth');
const { GRUPOS, normalizarGenero, limpio } = require('../util');

const CAMPOS = 'id, nombre, email, telefono, ubicacion, genero, grupo_sanguineo, fecha_creacion';

// GET /api/auth/me  -> perfil (crea al usuario en SQL Server si es su primera vez)
router.get('/me', auth, async (req, res) => {
  try {
    const pool = await poolPromise;
    const r = await pool.request().input('id', sql.Int, req.user.id)
      .query(`SELECT ${CAMPOS} FROM Usuarios WHERE id = @id`);
    res.json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PUT /api/auth/me  { nombre, telefono, ubicacion, genero, grupo_sanguineo }
// Solo se actualizan los campos que vengan en el cuerpo; un campo vacío ("") lo borra.
router.put('/me', auth, async (req, res) => {
  const b = req.body || {};
  if ('nombre' in b && !limpio(b.nombre))
    return res.status(400).json({ error: 'El nombre no puede estar vacío' });
  if (limpio(b.grupo_sanguineo) && !GRUPOS.includes(b.grupo_sanguineo))
    return res.status(400).json({ error: 'grupo_sanguineo inválido' });
  if (limpio(b.genero) && !normalizarGenero(b.genero))
    return res.status(400).json({ error: 'genero inválido' });

  const sets = [];
  const rq = (await poolPromise).request().input('id', sql.Int, req.user.id);
  const campo = (col, tipo, valor) => { sets.push(`${col} = @${col}`); rq.input(col, tipo, valor); };

  if ('nombre' in b) campo('nombre', sql.NVarChar, limpio(b.nombre));
  if ('telefono' in b) campo('telefono', sql.NVarChar, limpio(b.telefono));
  if ('ubicacion' in b) campo('ubicacion', sql.NVarChar, limpio(b.ubicacion));
  if ('genero' in b) campo('genero', sql.NVarChar, normalizarGenero(b.genero));
  if ('grupo_sanguineo' in b) campo('grupo_sanguineo', sql.NVarChar, limpio(b.grupo_sanguineo));

  try {
    if (!sets.length) {
      const r = await rq.query(`SELECT ${CAMPOS} FROM Usuarios WHERE id = @id`);
      return res.json(r.recordset[0]);
    }
    const r = await rq.query(`UPDATE Usuarios SET ${sets.join(', ')} WHERE id = @id;
                              SELECT ${CAMPOS} FROM Usuarios WHERE id = @id`);
    res.json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
