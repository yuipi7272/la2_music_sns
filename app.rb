require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'
require 'open-uri'
require 'json'
require 'net/http'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before do 
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end 

get '/' do
    @posts = Post.all
    @likes = Like.all
    erb :index
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    img_url = ''
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    else
        img_url = "https://1.bp.blogspot.com/-zyvvuefJLQM/XkZdUNDP2UI/AAAAAAABXWU/zElc5fj6l2AnonYZne8LUzbltyzUWK0oQCNcBGAsYHQ/s400/yumekawa_animal_azarashi.png"
    end
    
    @user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        profile_image: img_url
    )
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/'
end

get '/signout' do
   session[:user] = nil
   redirect '/'
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/search'
end

get '/search' do
    if session[:user]
        erb :search
    else 
        erb :index
    end
end

post '/search' do
    if params[:search_word]
        uri = URI("https://itunes.apple.com/search/")
        uri.query = URI.encode_www_form({
            term: params[:search_word],
            attribute: "artistTerm",
            media: "music",
            country: "jp"
        })
        res = Net::HTTP.get_response(uri)
        json = JSON.parse(res.body)
        @songs = json["results"]
    end
    erb :search
end

post '/new' do
    current_user.posts.create(
       comment: params[:comment],
       title: params[:title],
       cd_image_url: params[:cd_image_url],
       artist: params[:artist],
       album: params[:album],
       sample: params[:sample]
    )
    redirect '/home'
end

get '/home' do
    if current_user.nil?
        @posts = Post.none
    else
        @posts = current_user.posts
        s_like = current_user.likes
        like_ids = []
        s_like.each do |like|
            like_ids.push(like["post_id"])
        end
        @likes = Post.where id: like_ids
        @likes_all = Like.all
    end
    erb :home
end

get '/delete/:id' do
    pos = Post.find(params[:id])
    pos.destroy
    redirect '/home'
end

get '/edit/:id' do
    @post = Post.find(params[:id])
    erb :edit
end

post '/edit/:id' do
    pos = Post.find(params[:id])
    pos["comment"] = params[:comment]
    pos.save
    redirect '/home'
end

get '/like/:post_id' do
    if current_user.likes.find_by(post_id: params[:post_id]).nil?
        Like.create(
            user_id: current_user["id"],
            post_id: params[:post_id]
        )
    end
    redirect '/'
end

get '/delete_like/:id' do 
    Like.destroy_by(post_id: params[:id], user_id: current_user["id"])
    redirect '/home'
end