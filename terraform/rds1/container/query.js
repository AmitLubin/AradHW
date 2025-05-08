const mysql = require('mysql2');
const AWS = require('aws-sdk');

// Initialize the AWS SDK
const ssm = new AWS.SSM();
const secretsManager = new AWS.SecretsManager();

// Function to retrieve a secret from Secrets Manager
async function getSecretValue(secretName) {
  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
    if (data.SecretString) {
      return JSON.parse(data.SecretString); // Assuming secret is in JSON format
    }
    const buff = Buffer.from(data.SecretBinary, 'base64');
    return JSON.parse(buff.toString('ascii')); // Decode if it's binary
  } catch (err) {
    console.error('Error retrieving secret:', err);
    throw err;
  }
}

// Function to retrieve a parameter from SSM Parameter Store
async function getSSMParameter(name) {
  try {
    const params = {
      Name: name,
      WithDecryption: true, // Decrypt if it’s a SecureString
    };
    const data = await ssm.getParameter(params).promise();
    return data.Parameter.Value;
  } catch (err) {
    console.error('Error retrieving SSM parameter:', err);
    throw err;
  }
}

// Main function to connect to the database
async function connectToDatabase() {
  try {
    // Retrieve database connection details
    const dbSecret = await getSecretValue('rds!db-777ab260-d218-40d6-8bff-a5f247435ce3'); // Secret Manager
    const dbHost = await getSSMParameter('/amit/db/db-host');  // Parameter Store

    // console.log("host:" + dbHost);
    // console.log("user:" + dbSecret.username);
    // console.log("password:" + dbSecret.password);

    // Assuming dbSecret has properties like: username, password, dbname
    const connection = mysql.createConnection({
      host: dbHost,                    // Retrieved from Parameter Store
      user: dbSecret.username,         // Retrieved from Secrets Manager
      password: dbSecret.password,     // Retrieved from Secrets Manager
      database: "liordb",
      port: "3306"      
    });

    // Connect to the database
    connection.connect(err => {
      if (err) {
        console.error('Connection error:', err.stack);
        return;
      }
      console.log('Connected as id', connection.threadId);
    });

    // Run a query (for example)
    // connection.query('SELECT * FROM your_table', (err, results) => {
    //   if (err) {
    //     console.error('Query error:', err.stack);
    //     return;
    //   }
    //   console.log('Query results:', results);
    // });

    // Close the connection
    connection.end();
  } catch (err) {
    console.error('Error during DB connection:', err);
  }
}

// Run the connection
connectToDatabase();
