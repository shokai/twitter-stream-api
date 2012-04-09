# -*- coding: utf-8 -*-

before '/*' do
  @title = app_root
end

before '/*.json' do
  content_type 'application/json'
end

get '/' do
  haml :index
end

get '/track/:name' do
  @track = params[:name]
  @title = "#{app_title}/#{@track}"
  haml :track
end
