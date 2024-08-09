module.exports = {
  global: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    host: process.env.DB_HOST,
    dialect: 'postgres',
    operatorsAliases: false,
  },

  test: {
    username: process.env.POSTGRES_USER || 'test', // Fallback to 'test' if not set
    password: process.env.POSTGRES_PASSWORD || 'postgres', // Fallback to 'postgres'
    database: process.env.POSTGRES_DB || 'test_db', // Fallback to 'test_db'
    host: process.env.DB_HOST || 'localhost', // Fallback to 'localhost'
    dialect: 'postgres',
    operatorsAliases: false,
  },
  // dev: {
  //   // For a refresher on how to set up your local database, revisit steps 1
  //   // and 2 of the SQL Bites challenges from Databases week
  //   // (https://github.com/makersacademy/databases#phase-one-sql-bites).
  //   username: process.env.DB_USER,
  //   password: process.env.DB_PASSWORD,
  //   database: 'task_listing_app',
  //   host: 'host.docker.internal',
  //   dialect: 'postgres',
  //   operatorsAliases: false,
  // },

  development: {
    username: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'hyrfayteam',
    database: process.env.DB_DATABASE || 'HyrFayExampleAppDataBase',
    host: process.env.DB_HOST || 'hyr-fay-example-app-prod.cvruukypsgyb.eu-west-2.rds.amazonaws.com',
    dialect: 'postgres',
    operatorsAliases: false,
  },

  prod: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    host: process.env.DB_HOST,
    dialect: 'postgres',
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false
      }
    },
    operatorsAliases: false,
  },
};
