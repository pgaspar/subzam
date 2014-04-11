json.array!(@movies) do |movie|
  json.extract! movie, :id, :content, :imdb_id, :year, :filename, :imdb_rating, :name
  json.url movie_url(movie, format: :json)
end
