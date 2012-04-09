
def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def app_title
  @@conf['title']
end

def tracks
  @@conf['track']
end

def websocket_url
  @@conf['websocket']
end
