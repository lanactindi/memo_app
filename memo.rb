# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def connect_to_db
  PG.connect(dbname: 'postgres')
end

get '/' do
  redirect to '/memos'
end

get '/memos' do
  load_memos
  erb :index
end

post '/memos' do
  connection = connect_to_db
  memo_id = SecureRandom.uuid
  results = connection.exec_params('insert into memos values($1, $2, $3)', [memo_id, params[:title], params[:content]])
  redirect to '/sql_error' if results.nil?
  redirect to "/memos/#{memo_id}"
end

get '/memos/new' do
  @title = 'メモ新規登録'
  erb :new
end

get '/memos/:id' do
  @title = 'メモ内容'
  load_memo
  erb :show
end

get '/memos/:id/edit' do
  @title = 'メモ修正'
  load_memo
  erb :edit
end

patch '/memos/:id' do
  connection = connect_to_db
  results = connection.exec_params('update memos set title = $1, content= $2
             where id = $3', [params[:title], params[:content], params[:id]])
  redirect to '/sql_error' if results.nil?
  redirect to "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  connection = connect_to_db
  results = connection.exec_params('delete from memos where id = $1', [params[:id]])
  redirect to '/sql_error' if results.nil?
  redirect to '/memos'
end

get '/not_found' do
  @title = '404 データ見つかれません'
end

get '/sql_error' do
  @title = '500 サーバーエラーになりました'
end

private

def load_memo
  connection = connect_to_db
  @memos = connection.exec_params('select * from memos where id = $1', [params[:id]])
  redirect to '/not_found' if @memos.nil?
  @memo = @memos[0]
end

def load_memos
  connection = connect_to_db
  @memos = connection.exec('select * from memos')
  redirect to '/not_found' if @memos.nil?
end
