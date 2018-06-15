new_db_settings = {
  adapter: 'postgresql',
  encoding: 'utf8',
  pool: 5 ,
  host: '127.0.0.1',
  username: 'nicolas',
  password: Rails.application.config.database_configuration["development"]["password"],
  database: 'mypocketconsultant'
}
