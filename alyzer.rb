require 'bcrypt'
require 'couchrest'
require 'rack-flash'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'



# Flush STDOUT when using foreman.
$stdout.sync = true


begin
  DB_CONFIG = YAML.load_file('config/db.yml')
rescue Errno::ENOENT
  DB_CONFIG = {
    url: ENV['ALYZER_COUCH_URL'],
    db: ENV['ALYZER_COUCH_DB']
  }
end


# http://www.combobulate.com/techquotes.php
# http://searchservervirtualization.techtarget.com/definition/Our-Favorite-Technology-Quotations
QUOTES = [
  "Not everything that can be counted counts, and not everything that counts can be counted.",
  "If I have seen further it is by standing on the shoulders of giants.",
  "Man is still the most extraordinary computer of all.",
  "Computers are useless. They can only give you answers.",
  "Technology has the shelf life of a banana.",
  "Just because something doesn't do what you planned it to do doesn't mean it's useless.",
  "Computers are like bikinis. They save people a lot of guesswork.",
  "Save early, save often.",
  "Never let a computer know you're in a hurry."
]


class App < Sinatra::Base
  helpers Sinatra::ContentFor
  use Rack::Flash

  configure do
    set(:sessions, true)
  end

  configure :development do
    # Shotgun restarts the server every request, thereby recreating a new
    # session secret and invalidating the previously set cookies.
    set :session_secret, "My session secret"
  end


  helpers do
    def media_url(path)
      return url(File.join('/public/', path))
    end
    alias_method :to_media, :media_url

    def authenticated?
      !session['user'].nil?
    end
  end


  before do
    if !authenticated? && !request.path_info.eql?('/login/')
      return redirect(to('/login/'))
    end

    @futon_url = "#{DB_CONFIG[:url]}/_utils/"
    @db = CouchRest.new(DB_CONFIG[:url]).database(DB_CONFIG[:db])
    @config = @db.get('alizer-config')
  end


  get '/' do
    @rows = @db.info['doc_count'] - 1 # Don't count the configuration doc.
    haml :index
  end

  get '/login/' do
    haml :login
  end

  post '/login/' do
    username = params[:inputUsername]
    password = params[:inputPassword]

    if username.eql?("") || password.eql?("")
      @error = "This is not a difficult form. Just fill it!"
    else
      @config[:users].each do |user|
        if user['username'].eql?(username) && BCrypt::Password.new(user['password']) == password
          session['user'] = user['username']
          return redirect("/")
        end
      end
      @error = "Wrong username or password."
    end

    haml :login
  end

  get '/logout/' do
    session['user'] = nil
    redirect('/')
  end


  get '/configuration/' do
    begin
      @views = @db.get("_design/alyzer_views")[:views]
    rescue RestClient::ResourceNotFound
      @views = nil
    end

    haml :configuration
  end

  get '/configuration/:name/' do |name|
    begin
      doc = @db.get("_design/alyzer_views")
      views = doc[:views]
    rescue RestClient::ResourceNotFound
      flash[:error] = "You haven't defined any view yet!"
    else
      if not views.has_key?(name)
        flash[:error] = "This view does not exist!"
      else
        @name = name
        @view = views[name]
      end
    end

    return haml :configure
  end

  post '/configuration/:name/' do |name|
    begin
      doc = @db.get("_design/alyzer_views")
      views = doc[:views]
    rescue RestClient::ResourceNotFound
      flash[:error] = "You tried to edit a view, but you don't have any. So weird."
      return redirect('/configuration/')
    end

    if not views.has_key?(params[:name])
      flash[:error] = "You tried to edit an inexistant view. So weird."
      return redirect('/configuration/')
    end

    view = views[params[:name]]
    view[:map] = params[:map]
    view[:reduce] = params[:reduce]
    view[:adapter] = params[:adapter]
    view[:template_map] = params[:template_map]
    view[:template_reduce] = params[:template_reduce]
    view[:template_adapter] = params[:template_adapter]
    view[:do_reduce] = (params[:do_reduce] == "true")
    views[params[:name]] = view
    doc[:views] = views
    @db.save_doc(doc)

    flash[:success] = "The view was successfully edited."
    return redirect("/configuration/#{name}")
  end

  post '/configuration/new' do
    begin
      views = @db.get("_design/alyzer_views")
    rescue RestClient::ResourceNotFound
      views = {
        _id: "_design/alyzer_views",
        language: "javascript",
        views: {}
      }
    end

    name = params[:name]

    views[:views][name] = {
      map: "function(doc) {\n}",
      reduce: "function(key, values, rereduce) {\n}",
      adapter: "function(data) {return data;}",
      do_reduce: false,
      template_adapter: "identity",
      template_map: "custom",
      template_reduce: "custom"
    }

    @db.save_doc(views)
    redirect("/configuration/#{name}/")
  end

  get '/configuration/:name/delete' do |name|
    begin
      doc = @db.get("_design/alyzer_views")
      views = doc[:views]
    rescue RestClient::ResourceNotFound
      flash[:error] = "You tried to delete a view, but you don't have any. So weird."
    else
      if not views.has_key?(name)
        flash[:error] = "You tried to delete an inexistant view. So weird."
      else
        views.delete(name)
        doc[:views] = views
        @db.save_doc(doc)
        flash[:success] = "The view was successfully deleted."
      end
    end

    return redirect('/configuration/')
  end

  get '/visualization/' do
    begin
      @views = @db.get("_design/alyzer_views")[:views]
    rescue RestClient::ResourceNotFound
      @views = nil
    end

    haml :visualization
  end

  get '/visualization/:name' do |name|
    begin
      views = @db.get("_design/alyzer_views")[:views]
    rescue RestClient::ResourceNotFound
      flash[:error] = "You don't have any view. Seriously?"
      return redirect('/visualization/')
    end

    if not views.has_key?(name)
      flash[:error] = "This view does not exist. Are you kidding me?"
      return redirect('/visualization/')
    end

    @name = name
    @quote = QUOTES.sample
    @view = views[name]

    haml :visualize
  end

  get '/couchdb/:view_name' do |view_name|
    args = params[:arguments]
    content_type "application/json"
    return @db.view("alyzer_views/#{view_name}", args).to_json
  end

end
