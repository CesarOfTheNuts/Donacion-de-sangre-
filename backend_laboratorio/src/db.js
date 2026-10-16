require('dotenv').config();
const sql = require('mssql');

// DB_SERVER puede ser "localhost" o una instancia con nombre: "localhost\SQL2022INTEC"
const [host, instanceName] = (process.env.DB_SERVER || 'localhost').split('\\');

const config = {
  server: host,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ...(instanceName ? {} : { port: parseInt(process.env.DB_PORT || '1433', 10) }),
  options: {
    encrypt: false,
    trustServerCertificate: true,
    ...(instanceName ? { instanceName } : {}),
  },
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then((pool) => { console.log('Conectado a SQL Server'); return pool; })
  .catch((err) => { console.error('Error de conexión a la BD:', err.message); process.exit(1); });

module.exports = { sql, poolPromise };
