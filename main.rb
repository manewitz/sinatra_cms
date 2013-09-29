require "sinatra"
require "sinatra/reloader" if development?
require "mongoid"
require "slim"
require "redcarpet"

configure do
  Mongoid.load!("./mongoid.yml")
end

class Page
  include Mongoid::Document

  field :title,     type: String
  field :content,   type: String
  field :permalink, type: String, default: -> { make_permalink }


  def make_permalink
    title.downcase.
      gsub(/W/,'-').
      gsub("\s", "_").
      squeeze('-').
      chomp('-') if title
  end

end

get '/:permalink' do
  begin
    @page = Page.find_by(permalink: params[:permalink])
  rescue
    pass
  end
  slim :show
end

get('/styles/main.css'){ sass :styles }

get '/pages' do
  @pages = Page.all
  @title = "Simple CMS: Page List"
  slim :index
end

get '/pages/new' do
  @page = Page.new
  slim :new
end

get '/pages/:id/edit' do
  @page = Page.find(params[:id])
  slim :edit
end

get '/pages/delete/:id' do
  @page = Page.find(params[:id])
  slim :delete
end

get '/pages/:id' do
  @page = Page.find(params[:id])
  @title = @page.title
  slim :show
end

post '/pages' do
  page = Page.create(params[:page])
  redirect to("/pages/#{page.id}")
end

put '/pages/:id' do
  page = Page.find(params[:id])
  page.update_attributes(params[:page])
  redirect to("/pages/#{page.id}")
end

delete '/pages/:id' do
  Page.find(params[:id]).destroy
  redirect to('/pages')
end