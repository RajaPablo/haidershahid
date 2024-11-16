require 'sinatra/base'
require 'sinatra/contrib'
require 'securerandom'
require_relative 'config/database'
require_relative 'models/user'
require_relative 'helpers/auth_helper'

class GamblingSite < Sinatra::Base
  set :server, 'webrick'
  
  configure do 
    session_name = 'gambling_site.session'
    session_secret = SecureRandom.hex(32)
    session_expire_time = 2592000

    Database.init
    enable :sessions
    set :session_secret, session_secret
    set :sessions, { 
      key: session_name,
      secret: session_secret,
      expire_after: session_expire_time
    }
  end
  
  helpers AuthHelper
  
  get '/' do
    erb :welcome
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.authenticate(params[:username], params[:password])
    @error = "Invalid credentials"

    return erb :login unless user
  
    session[:username] = user.username
    init_session_stats
    redirect '/bet'
  end

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    begin
      return redirect '/login' if User.create(params[:username], params[:password])
    rescue SQLite3::ConstraintException
      @error = "Username already taken"
      erb :signup
    end
  end

  get '/bet' do
    require_login
    @user = current_user
    erb :bet
  end

  post '/bet' do
    require_login
    
    bet_amount = params[:bet_money].to_i
    bet_number = params[:on].to_i
    dice_roll = rand(1..6)

    if dice_roll != bet_number
      session[:total_loss] += bet_amount
      session[:total_profit] -= bet_amount
      @result = "You lost. The dice roll was #{dice_roll}."
    else
      win_amount = bet_amount * 5
      session[:total_win] += win_amount
      session[:total_profit] += win_amount - bet_amount
      @result = "You won. The dice roll was #{dice_roll}. You win #{win_amount}!"
    end
    
    @user = current_user
    erb :bet
  end

  get '/logout' do
    if !current_user
      session.clear
      redirect '/login'
    else
      current_user.update_stats({
        total_win: session[:total_win],
        total_loss: session[:total_loss],
        total_profit: session[:total_profit]
      })
      session.clear
      redirect '/login'
    end
  end

  not_found do
    status 404
    erb :not_found
  end

  error do
    status 500
    erb :error
  end

  run! if app_file == $0
end