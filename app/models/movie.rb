class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
  def self.Tmdbkey
    return "f4702b08c0ac6ea5b51425788bb26562"
  end
  
  class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      movies = Array.new
      Tmdb::Api.key(Movie.Tmdbkey)
      matching_movies = Tmdb::Movie.find(string)
      if matching_movies.empty?
        return movies
      end
      matching_movies.each do |matching_movie|
        countries = Tmdb::Movie.releases(matching_movie.id).fetch("countries")
        uscountry = countries.find {|country| country["iso_3166_1"] == "US"}
        unless(uscountry.nil?)
          rating = uscountry["certification"]
          date = uscountry["release_date"]
        else
          rating = "NR"
          date = matching_movie.release_date
        end
        movies.push({tmdb_id: matching_movie.id, title: matching_movie.title, rating: rating, release_date: date})
      end
      return movies
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
        raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end

  def self.create_from_tmdb(tmdb_id)
    detail = Tmdb::Movie.detail(tmdb_id)
    countries = Tmdb::Movie.releases(tmdb_id).fetch("countries")
    uscountry = countries.find {|country| country["iso_3166_1"] == "US"}
    unless(uscountry.nil?)
      rating = uscountry["certification"]
      date = uscountry["release_date"]
    else
      rating = "NR"
      date = detail[release_date]
    end
    self.create!({title: detail.fetch("title"), rating: rating, description: detail.fetch("overview"), release_date: date})
  end
end
