const router = require('express').Router();
const { sql, poolPromise } = require('../db');
const auth = require('../middleware/auth');
const { GRUPOS, normalizarGenero, limpio } = require('../util');

// POST /api/solicitudes
router.post('/', auth, async (req, res) => {
  const b = req.body || {};
  const paciente = limpio(b.paciente), telefono = limpio(b.telefono),
        tel2 = limpio(b.telefono_emergencia), causa = limpio(b.causa);
  const bolsas = parseInt(b.bolsas, 10);

  if (!paciente || !b.grupo_sanguineo || !telefono || !tel2 || !causa || !b.fecha_limite)
    return res.status(400).json({ error: 'Faltan campos obligatorios' });
  if (!GRUPOS.includes(b.grupo_sanguineo))
    return res.status(400).json({ error: 'grupo_sanguineo inválido' });
  if (!(bolsas > 0))
    return res.status(400).json({ error: 'bolsas debe ser un número mayor que 0' });

  try {
    const pool = await poolPromise;
    const r = await pool.request()
      .input('uid', sql.Int, req.user.id)
      .input('paciente', sql.NVarChar, paciente)
      .input('grupo', sql.NVarChar, b.grupo_sanguineo)
      .input('bolsas', sql.Int, bolsas)
      .input('tel', sql.NVarChar, telefono)
      .input('tel2', sql.NVarChar, tel2)
      .input('causa', sql.NVarChar, causa)
      .input('genero', sql.NVarChar, normalizarGenero(b.genero))
      .input('ubicacion', sql.NVarChar, limpio(b.ubicacion))
      .input('fecha', sql.Date, b.fecha_limite)
      .input('otros', sql.NVarChar, limpio(b.otros))
      .query(`INSERT INTO Solicitudes
                (usuario_id, paciente, grupo_sanguineo, bolsas, telefono, telefono_emergencia,
                 causa, genero, ubicacion, fecha_limite, otros, fecha_creacion)
              OUTPUT INSERTED.*
              VALUES (@uid, @paciente, @grupo, @bolsas, @tel, @tel2, @causa, @genero, @ubicacion, @fecha, @otros,
                      SYSUTCDATETIME())`);
    res.status(201).json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/solicitudes?grupo=A+&estado=Abierta&limit=10   (por defecto solo Abiertas)
router.get('/', auth, async (req, res) => {
  const { grupo, estado } = req.query;
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 100, 1), 200);
  try {
    const pool = await poolPromise;
    const rq = pool.request()
      .input('estado', sql.NVarChar, estado || 'Abierta')
      .input('limit', sql.Int, limit);
    let where = 'WHERE estado = @estado';
    if (grupo) { where += ' AND grupo_sanguineo = @grupo'; rq.input('grupo', sql.NVarChar, grupo); }
    const r = await rq.query(
      `SELECT TOP (@limit) * FROM Solicitudes ${where} ORDER BY fecha_creacion DESC`);
    res.json(r.recordset);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/solicitudes/:id
router.get('/:id', auth, async (req, res) => {
  try {
    const pool = await poolPromise;
    const r = await pool.request().input('id', sql.Int, req.params.id)
      .query('SELECT * FROM Solicitudes WHERE id = @id');
    if (!r.recordset.length) return res.status(404).json({ error: 'Solicitud no encontrada' });
    res.json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PATCH /api/solicitudes/:id/estado  { estado }  (solo el dueño)
router.patch('/:id/estado', auth, async (req, res) => {
  const { estado } = req.body || {};
  if (!['Abierta', 'Cubierta', 'Cancelada'].includes(estado))
    return res.status(400).json({ error: 'estado inválido' });
  try {
    const pool = await poolPromise;
    const r = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('uid', sql.Int, req.user.id)
      .input('estado', sql.NVarChar, estado)
      .query(`UPDATE Solicitudes SET estado = @estado
              OUTPUT INSERTED.*
              WHERE id = @id AND usuario_id = @uid`);
    if (!r.recordset.length)
      return res.status(404).json({ error: 'Solicitud no encontrada o no te pertenece' });
    res.json(r.recordset[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
