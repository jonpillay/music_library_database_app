# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  def sanitize(list)
    ['<html>', '<script>'].any? { |inj| list.include?(inj) }
  end

  get '/albums/new' do
    return erb(:new_album_form)
  end

  post '/albums/new' do
    if invalid_request_parameters?
      status 400
      return ''
    end

    title = params[:title]
    release_year = params[:release_year]
    artist = params[:artist]
    check_list = [title, artist]
    if sanitize(check_list)
      return erb(:nice_try)
    end
    artist_repo = ArtistRepository.new
    artist_id = artist_repo.find_id_by_name(artist.downcase)
    
    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = artist_id

    repo = AlbumRepository.new    
    repo.create(album)
    redirect '/albums'
  end

  get '/artists/new' do
    return erb(:new_artist_form)
  end

  post '/artists/new' do
    if invalid_request_parameters?
      status 400
      return ''
    end

    artist_repo = ArtistRepository.new
    artist = Artist.new
    name = params[:name]
    genre = params[:genre]
    check_list = [name, genre]
    if sanitize(check_list)
      return erb(:nice_try)
    end
    artist_repo.create(artist)
    redirect '/artists'
  end

  get '/albums/:id' do
    @id = params[:id]
    album_repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    album = album_repo.find(@id)
    @title = album.title
    @release_year = album.release_year
    @artist = artist_repo.find(album.artist_id)
    
    return erb(:album)
  end

  get '/albums' do
    album_repo = AlbumRepository.new
    @albums = album_repo.all
    @artists = ArtistRepository.new
    return erb(:albums)
  end

  post '/albums' do
    title = params[:title]
    release_year = params[:release_year]
    artist = params[:artist]
    artist_repo = ArtistRepository.new
    artist_id = artist_repo.find_id_by_name(artist.downcase)
    
    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = artist_id

    repo = AlbumRepository.new    
    repo.create(album)
    redirect '/albums'
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  get '/artists/:id' do
    @id = params[:id]
    album_repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(@id)
    @artist_albums = album_repo.find_by_artist(@id)
    return erb(:artist)
  end

  post '/artists' do
    artist_repo = ArtistRepository.new
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]
    artist_repo.create(artist)
    redirect '/artists'
  end

  def invalid_request_parameters?
    path = request.path_info
    if path.include? "albums"
      return true if params[:title] == nil || params[:release_year] == nil || params[:artist] == nil
      return true if params[:title] == "" || params[:release_year] == "" || params[:artist] == ""
      return false
    elsif path.include? "artists"
      return true if params[:name] == nil || params[:genre] == nil 
      return true if params[:name] == "" || params[:genre] == "" 
      return false 
    end
  end
end