class User
    attr_reader :id, :username, :total_win, :total_loss, :total_profit
  
    def self.find_by_username(username)
      query = "SELECT * FROM users WHERE username = ?"
      result = Database.connection.execute(query, [username]).first
      if result
        new(result)
      else
        nil
      end
    end
  
    def self.authenticate(username, password)
      query = "SELECT * FROM users WHERE username = ? AND password = ?"
      result = Database.connection.execute(query, [username, password]).first
      if result
        new(result)
      else
        nil
      end
    end
    
    def self.create(username, password)
      query = "INSERT INTO users (username, password) VALUES (?, ?)"
      params = [username, password]
      return nil unless username && password
      Database.connection.execute(query, params)
    end
    
    def initialize(data)
      @id = data['id']
      @username = data['username']
      @total_win = data['total_win']
      @total_loss = data['total_loss']
      @total_profit = data['total_profit']
    end
    
    def update_stats(session_stats)
      query = "UPDATE users SET " \
      "total_win = total_win + ?, " \
      "total_loss = total_loss + ?, " \
      "total_profit = total_profit + ? " \
      "WHERE username = ?"

      params = [
        session_stats[:total_win],
        session_stats[:total_loss],
        session_stats[:total_profit],
        @username
      ]
      
      Database.connection.execute(query, params)
    end
  
    def stats
      {
        total_win: @total_win,
        total_loss: @total_loss,
        total_profit: @total_profit
      }
    end
  end