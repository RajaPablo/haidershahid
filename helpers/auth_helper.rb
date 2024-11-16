module AuthHelper
    def current_user
      if @current_user
        @current_user
      else
        if session[:username]
          @current_user = User.find_by_username(session[:username])
        end
      end
    end
    
    def logged_in?
      current_user != nil
    end
    
    def require_login
      if !logged_in?
        redirect '/login'
      end
    end
  
    def init_session_stats
      session[:total_win] = 0
      session[:total_loss] = 0
      session[:total_profit] = 0
    end
  end