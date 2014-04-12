module MoviesHelper

  def imdb_url(id)
    "http://www.imdb.com/title/tt#{id}"
  end

  def timed_highlights(highlights)
    highlights.map do |h|
      [h, find_timestamp(h)]
    end
  end

  def find_timestamp(h)
    h.format{|m| m}.match(/\[([:\d]+)\]/i).captures.first rescue nil
  end

  def strip_timestamps(html)
    html.gsub(/\[[:\d]+\]\n/i, '').gsub(/[:\d]+\]/i, '').gsub(/\[[:\d]+/i, '').gsub(/^\]/i, '').gsub(/\[$/i, '')
  end
end
