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

CONN = PG.connect(dbname: 'postgres')

get '/' do
  redirect to '/memos'
end

get '/memos' do
  load_memos
  erb :index
end

post '/memos' do
  memo_id = SecureRandom.uuid
  results = CONN.exec("insert into memos values('#{memo_id}','#{h params[:title]}','#{h params[:content]}')")
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
  results = CONN.exec("update memos set title = '#{h params[:title]}', content= '#{h params[:content]}'
             where id = '#{params[:id]}'")
  redirect to '/sql_error' if results.nil?
  redirect to "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  results = CONN.exec("delete from memos where id = '#{params[:id]}'")
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
  @title = 'メモ内容'
  @memos = CONN.exec("select * from memos where id = '#{params[:id]}'")
  redirect to '/not_found' if @memos.nil?
  @memo = @memos[0]
end

def load_memos
  @memos = CONN.exec('select * from memos')
  redirect to '/not_found' if @memos.nil?
end
