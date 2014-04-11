module MoviesHelper

  def imdb_url(id)
    "http://www.imdb.com/title/tt#{id}"
  end
end
