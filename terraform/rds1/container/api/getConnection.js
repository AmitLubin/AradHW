// Fixed getConnection.js
const mysql = require('mysql2/promise'); // Use promise-based version
const AWS = require('aws-sdk');

// Configure AWS SDK with region
const region = process.env.AWS_REGION || 'il-central-1'; // Match your Terraform region
AWS.config.update({ region });

// Initialize the AWS services
// const ssm = new AWS.SSM();
// const secretsManager = new AWS.SecretsManager();

// // Function to retrieve a secret from Secrets Manager
// async function getSecretValue(secretName) {
//   try {
//     const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
//     if (data.SecretString) {
//       return JSON.parse(data.SecretString);
//     }
//     const buff = Buffer.from(data.SecretBinary, 'base64');
//     return JSON.parse(buff.toString('ascii'));
//   } catch (err) {
//     console.error(`Error retrieving secret '${secretName}':`, err);
//     throw err;
//   }
// }

// // Function to retrieve a parameter from SSM Parameter Store
// async function getSSMParameter(name) {
//   try {
//     const params = {
//       Name: name,
//       WithDecryption: true,
//     };
//     const data = await ssm.getParameter(params).promise();
//     return data.Parameter.Value;
//   } catch (err) {
//     console.error(`Error retrieving SSM parameter '${name}':`, err);
//     throw err;
//   }
// }

// Create a connection pool instead of single connections
let pool = null;

async function getConnection() {
  try {
    if (pool) {
      return pool.getConnection();
    }
    
    console.log('Initializing DB connection pool...');
    
    // Retrieve database connection details
    // const dbSecret = await getSecretValue('rds!db-777ab260-d218-40d6-8bff-a5f247435ce3');
    // const dbHost = await getSSMParameter('/amit/db/db-host');
    
    // Log connection info for debugging (remove in production)
    //console.log(`Connecting to DB at ${dbHost} with user ${dbSecret.username}`);
    
    // Create a connection pool
    pool = mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: "liordb",
      port: 3306, // Number instead of string
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    });

    console.log("pool created");
    
    // Test the connection
    const conn = await pool.getConnection();
    console.log('Connected to database successfully');
    conn.release();
    
    return pool.getConnection();
  } catch (err) {
    console.error('Error during DB connection:', err);
    throw err; // Throw the error instead of returning null
  }
}

// Export pool and getConnection
module.exports = { getConnection, pool };
