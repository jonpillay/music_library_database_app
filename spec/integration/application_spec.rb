require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }


  context "POST to /albums" do
    it "returns 200 OK with albums listed" do
      # Send a GET request to /
      # and returns a response object we can test.
      post = post('/albums', title: 'Voyage', release_year: '2022', artist: 'ABBA') 
      response = get('/albums')
      
      # Assert the response status code and body.
      expect(response.status).to eq(200)
      expect(response.body).to include "Voyage"
    end
  end

  context "GET /albums" do
    it "returns 200 OK with album added" do
      # Send a GET request to /
      # and returns a response object we can test.
      #length_check = get('/albums')
      response = get('/albums')
      
      # Assert the response status code and body.
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/2">Surfer Rosa</h1></a>')
      expect(response.body).to include('<h2>Release Year: 1988</h2>')
      expect(response.body).to include('<h2>Artist: Pixies</h2>')
      expect(response.body).to include('<a href="/albums/3">Waterloo</h1></a>')
      expect(response.body).to include('<h2>Release Year: 1980</h2>')
      expect(response.body).to include('<h2>Artist: ABBA</h2>')
      expect(response.body).to include('<a href="/albums/4">Super Trouper</h1></a>')
      expect(response.body).to include('<a href="/albums/5">Bossanova</h1></a>')
    end
  end

  context 'POST to /artists' do
    it "returns 200 with artists listed" do
      post = post('/artists', name: 'Wild nothing', genre: 'Indie')

      expect(get('/artists').body).to include('Wild nothing')
    end
  end

  context 'GET to /artists' do
    it 'returns 200 with artists listed' do
      response = get('/artists')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1">Pixies</h1></a>')
      expect(response.body).to include('<h2>Genre: Rock</h2>')
      expect(response.body).to include('<a href="/artists/2">ABBA</h1></a>')
      expect(response.body).to include('<h2>Genre: Pop</h2>')
    end
  end
end
