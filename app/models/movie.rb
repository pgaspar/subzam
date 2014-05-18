class Movie < ActiveRecord::Base

  validates :imdb_id, uniqueness: true

  searchable do
    text :content, :stored => true do |m| ActionView::Base.full_sanitizer.sanitize(m.content).gsub("\r\n", "\n") end
    text :name, :boost => 0.005
    integer :movie_id do |m| m.id end
  end

  def self.create_from_sub(sub)
    self.create({
      content:      Movie.extract_timed_text(sub.body),
      original_srt: sub.body,
      imdb_id:      sub.raw_data["IDMovieImdb"],
      year:         sub.raw_data["MovieYear"],
      filename:     sub.filename,
      imdb_rating:  sub.raw_data["MovieImdbRating"],
      name:         sub.movie_name,
      poster_url:   Movie.find_poster(sub.raw_data["IDMovieImdb"]),
    })
  end

  def keywords
    clean_content = MoviesController.helpers.strip_timestamps(content)
    doc = Pismo::Document.new(clean_content)
    tags = doc.keywords(:stem_at => 4, :limit => 15).reject{|p| p.first.length < 3 || !Stopwords.valid?(p.first)}#.map {|k,v| ["#{k} (#{v})", v]}
  end

  def poster
    self.update_attribute(:poster_url, Movie.find_poster(normalized_imdb_id)) unless self.poster_url
    self.poster_url
  end

  def extract_timed_text
    Movie.extract_timed_text(original_srt)
  end

  def self.extract_timed_text(body)
    text = []

    body.split("\r\n").each do |line|
      next if line =~ /^\d+$/ || line.empty?

      if line.include?(' --> ')
        time = line.match(/^([^,]+),.+$/i).captures rescue nil
        p line unless time
        text << "[#{time.first}]"
      else
        text << line
      end
    end

    text.join("\n")
  end

  def self.extract_text(body)
    text = []

    body.split("\r\n").each do |line|
      next if line =~ /^\d+$/ || line.include?(' --> ') || line.empty?
      text << line
    end

    text.join("\n")
  end

  private

  def normalized_imdb_id
    '0' * (7 - imdb_id.size) + imdb_id
  end

  def self.find_poster(id)
    CanHazPoster.grab_poster_by_imdb(id)
    #FilmBuff.new.look_up_id("tt#{id}").poster_url rescue nil
  end
end
