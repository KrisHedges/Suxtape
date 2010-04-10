require 'rubygems'
require 'sinatra'
require "lib/authorization"
require "mp3info" 

helpers do
  include Sinatra::Authorization
  
  def base_url
    if Sinatra.port == 80
      "http://#{Sinatra::Application.host}"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/"
    end    
  end
  
  def nil_zero?
    self.nil? || self == 0
  end
end

get '/' do
  @songs = Dir['public/songs/*.mp3'].sort{|b,a| File.mtime(b) <=> File.mtime(a)}.map {|f| File.basename(f, ".mp3") }
  erb :tape
end

get '/admin' do
  require_admin
  @songs = Dir['public/songs/*.mp3'].sort{|b,a| File.mtime(b) <=> File.mtime(a)}.map {|f| File.basename(f, ".mp3") }
  erb :admin_tape, :layout  => :admin
end

post '/upload' do
  require_admin
  file = params[:file][:tempfile]
  Mp3Info.open(file.path) do |song|
    @filename = song.tag.artist + "  -  " + song.tag.title + ".mp3"
  end
  File.open("public/songs/#{@filename}", 'wb') {|f| f.write file.read }
  redirect '/admin'
end

get '/erase' do
  require_admin
  @songs= Dir['public/songs/*.mp3'].map {|f| File.basename(f)}
  @songs.each do |song|
    File.delete("public/songs/#{song}")
  end
  redirect  '/admin'
end