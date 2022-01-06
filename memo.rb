# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect to '/memos'
end

get '/memos' do
  load_memos
  erb :index
end

post '/memos' do
  memo = { 'id': SecureRandom.uuid, 'title': h(params[:title]), 'content': h(params[:content]) }
  load_memos
  @memos << memo
  rewrite_json
  redirect to "/memos/#{memo[:id]}"
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
  load_memo
  @memos.delete_if { |memo| memo['id'] == params[:id] }
  @memo['title'] = h(params[:title])
  @memo['content'] = h(params[:content])
  @memos << @memo
  rewrite_json
  redirect to "/memos/#{@memo['id']}"
end

delete '/memos/:id' do
  load_memos
  @memos = @memos.delete_if { |memo| memo['id'] == params[:id]}
  rewrite_json
  redirect to '/memos'
end

get '/not_found' do
  @title = '404 データ見つかれません'
end

private

def load_memo
  @title = 'メモ内容'
  file = File.read('./data/memo.json')
  @memos = JSON.parse(file)
  @memo = @memos.find { |memo| memo['id'] == params[:id] }
  redirect to '/not_found' if @memo.nil?
end

def load_memos
  file = File.read('./data/memo.json')
  @memos = JSON.parse(file)
end

def rewrite_json
  File.open('./data/memo.json', 'w') do |f|
    f.write(JSON.pretty_generate(@memos))
  end
end
