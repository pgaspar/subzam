# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'get_subtitles'

def import_250
  CSV.foreach('db/seed_data/imdb_250.csv') do |rnd, num_votes, rating, title|
    import_movie(title)
  end
end

def filter_all
  open('db/seed_data/imdb.csv').each do |line|
    line = line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    rnd, num_votes, rating, title = line.match(/^\s+([^\s]+)\s+(\d+)\s+([\d.]+)\s+(.+)$/i).captures rescue next
    
    unless num_votes.to_i < 80000 || rating.to_f < 7.5
      #puts title
      import_movie(title)
    end
  end
end

def import_movie(title)
  title_without_year = title.split(' (').first
  return if Movie.find_by(name: title_without_year)

  begin
    sub = FetchSubtitle.new.search(title, [OSDb::Search::IMDB])
    sleep 2 if sub == false
  end while sub == false

  if sub
    begin
      movie = Movie.find_by(imdb_id: sub.raw_data["IDMovieImdb"])
      movie ||= Movie.create_from_sub(sub)
      puts ">> Done with #{movie.name}"
    rescue Zlib::GzipFile::Error => e
      puts "Gzip Error - Probably because of Anti Leeching protection"
    end
  end
  puts
end

#t: 310922
#30000: 2735
#30000 e > 7.0: 1359

puts "Movie Count: #{Movie.count}"

#import_250
filter_all

puts "Movie Count: #{Movie.count}"
