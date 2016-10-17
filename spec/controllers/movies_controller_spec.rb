require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {search: {:search_terms => 'Ted'}}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {search: {:search_terms => 'Ted'}}
      expect(response).to render_template('search_tmdb')
    end
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {search: {:search_terms => 'Ted'}}
      expect(assigns(:movies)).to eq(fake_results)
      expect(assigns(:titlebar)).to eq('Ted')
    end
    context 'with no or nil search terms' do
      it 'should not call find_in_tmdb with blank string' do
        expect(Movie).not_to receive(:find_in_tmdb).with('')
        post :search_tmdb, {search: {:search_terms => ""}}
        expect(response).to redirect_to(movies_path)
        expect(flash[:notice]).to eq('Invalid search term')
      end
      it 'should not call find_in_tmdb with nil' do
        expect(Movie).not_to receive(:find_in_tmdb).with(nil)
        post :search_tmdb, {search: {:search_terms => nil}}
      end
      it 'should return to index page with flash message' do
        allow(Movie).to receive(:find_in_tmdb).with("")
        post :search_tmdb, {search: {:search_terms => ""}}
        expect(response).to redirect_to(movies_path)
        expect(flash[:notice]).to eq('Invalid search term')
      end
    end
    it 'should return flash message if no results are found' do
      fake_results = Array.new
      expect(Movie).to receive(:find_in_tmdb).with('NoSuchMovie').and_return(fake_results)
      post :search_tmdb, {search: {:search_terms => 'NoSuchMovie'}}
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to eq('No matching movies were found on TMDb')
    end
    context 'with movies found and search_tmdb rendered' do
      it 'should return to index when Add Selected Movies clicked' do
        fake_movies = {double("key1") => 1, double("key2") => 1}
        allow(Movie).to receive(:create_from_tmdb)
        post :add_tmdb, {:tmdb_movies => fake_movies}
        expect(response).to redirect_to(movies_path)
        expect(flash[:notice]).to eq('Movies successfully added to Rotten Potatoes')
      end
      it 'should return No movies selected when user selects none' do
        fake_movies = {};
        allow(Movie).to receive(:create_from_tmdb)
        post :add_tmdb, {:tmdb_movies => fake_movies}
        expect(response).to redirect_to(movies_path)
        expect(flash[:notice]).to eq("No movies selected")
      end
    end
  end
end
