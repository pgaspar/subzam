# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'get_subtitles'

puts "Movie Count: #{Movie.count}"

CSV.foreach('db/seed_data/imdb_250.csv') do |rnd, num_votes, rating, title|
  title_without_year = title.split(' (').first
  next if Movie.find_by(name: title_without_year)

  begin
    sub = FetchSubtitle.new.search(title, [OSDb::Search::IMDB])
    sleep 2 if sub == false
  end while sub == false

  if sub
    movie = Movie.find_by(imdb_id: sub.raw_data["IDMovieImdb"])
    movie ||= Movie.create_from_sub(sub)
    puts ">> Done with #{movie.name}"
  end
  puts
end

puts "Movie Count: #{Movie.count}"
