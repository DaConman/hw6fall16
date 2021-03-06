
describe Movie do
  fixtures :movies
    before :each do
      @movies = [movies(:milk_movie), movies(:other_movie)]
      @countries = 
      { double("id")=>double("id"), "countries" => 
        [
          {"certification" => "R" , "iso_3166_1" => "US", "primary" => false, "release_date" => "2000-05-01"},
          {"certification" => "15", "iso_3166_1" => "GB", "primary" => false, "release_date" => "2000-05-12"}
        ]
      }
    end
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      context 'and results found' do
        it 'should call Tmdb with title keywords' do
          expect(Tmdb::Movie).to receive(:find).with('hardware').and_return(@movies)
          allow(Tmdb::Movie).to receive(:releases).with(1..2).and_return(@countries)
          Movie.find_in_tmdb('hardware')
        end
        it 'should return an array of hashes' do
          expect(Tmdb::Movie).to receive(:find).with('hardware').and_return(@movies)
          allow(Tmdb::Movie).to receive(:releases).with(1..2).and_return(@countries)
          results = Movie.find_in_tmdb('hardware')
          expect(results).to be_an_instance_of(Array)
          expect(results.each {|e| Hash === e})
        end
      end
      it 'should return an empty array if no results found' do
        expect(Tmdb::Movie).to receive(:find).with('hardware').and_return([])
        expect(Movie.find_in_tmdb('hardware')).to match_array([])
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return({'code' => '401'})
        expect { Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  describe 'Adding movies with create_from_tmdb' do
    it 'should add to db' do
      movie = movies(:milk_movie)
      results = {"id" => movie.id, "title" => movie.title, "release_date" => movie.release_date, "overview" => "The milk man comeith"}
      expect(Tmdb::Movie).to receive(:detail).with(movie.id).and_return(results)
      allow(Tmdb::Movie).to receive(:releases).with(movie.id).and_return(@countries)
      Movie.create_from_tmdb(movie.id)
      expect(Movie.where(:title => movie.title, :rating => "R", :release_date => movie.release_date, :description => results.fetch("overview"))).to exist
    end
  end
end
