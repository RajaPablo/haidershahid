require 'sqlite3'

module Database
  def self.connection
    unless @db
      @db = SQLite3::Database.new(File.join(File.dirname(__FILE__), '..', 'db', 'database.db'))
      @db.results_as_hash = true
    end
    @db
  end
  
  def self.init
    connection.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT UNIQUE,
        password TEXT,
        total_win INTEGER DEFAULT 0,
        total_loss INTEGER DEFAULT 0,
        total_profit INTEGER DEFAULT 0
      );
    SQL
  end
end