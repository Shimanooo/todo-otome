require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before do
  if session[:user].nil?
    unless request.path == "/sign_in" || request.path == "/sign_up" || request.path == "/top"
      redirect '/top'
    end
  end
end


before '/tasks' do
  if current_user.nil?
    redirect '/'
  end
end

get '/' do
  @lists = List.all
  if current_user.nil?
    @tasks = Task.none
  elsif params[:list].nil? then
    @tasks = current_user.tasks
  else
    @tasks = List.find(params[:list]).tasks.had_by(current_user)
  end
  erb :index
end

get '/sign_in' do
  erb :sign_in
end

get '/sign_up' do
  erb :sign_up
end

get '/index' do
  erb :index
end

get '/top' do
  erb :top
end

get '/voice_list' do
  erb :voice_list
end

post '/sign_up' do
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
    )
  # binding.pry
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

post '/sign_in' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
      session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/top'
end

get '/tasks/new' do
  erb :new
end

post '/tasks' do
  date = params[:due_date].split('-')
  list = List.find(params[:list])
  if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
      current_user.tasks.create(title:params[:title],
      due_date: Date.parse(params[:due_date]), list_id: list.id)
      redirect '/'
    else
      redirect '/tasks/new'
  end
end

post '/tasks/:id/done' do

  task = Task.find(params[:id])
  task.completed = true
  task.save
  sleep 4
  redirect '/'
end

get '/tasks/:id/star' do
  task = Task.find(params[:id])
  task.star = !task.star
  task.save
  redirect '/'
end

post '/tasks/:id/delete' do
  task = Task.find(params[:id])
  task.destroy
  redirect '/'
end

get '/tasks/:id/edit' do
  @task = Task.find(params[:id])
  erb :edit
end

post '/tasks/:id' do
  task = Task.find(params[:id])
  list = List.find(params[:list])
  date = params[:due_date].split('-')

  if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
      task.title = CGI.escapeHTML(params[:title])
      task.due_date = Date.parse(params[:due_date])
      task.list_id = list.id
      task.save

      redirect '/'
  else
    redirect "/tasks/#{task.id}/edit"
  end
end

get '/tasks/over' do
  @lists = List.all
  @tasks = current_user.tasks.where('due_date < ?', Date.today).where(completed: [nil,false])
  erb :index
end

get '/tasks/done' do
  @lists = List.all
  @tasks = current_user.tasks.due_over
  erb :index
end