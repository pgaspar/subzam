require 'uri'

module OSDb
  class Sub
    alias_method :old_body, :body
    
    def body
      old_body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end

    def extract_text
      text = []

      body.split("\r\n").each do |line|
        next if line =~ /^\d+$/ || line.include?('-->') || line.empty?
        text << line
      end

      text.join("\n")
    end
  end
end

class FetchSubtitle

  def initialize
  end

  def env_lang
    OSDb::Language.from_locale(ENV['LANG'] || 'en_US.UTF-8')
  end

  def search(movie_name)
    language = "eng"
    
    begin
      puts "* Search subtitles for #{movie_name}"

      movie_file = OSDb::MovieFile.new(movie_name)

      if sub = subtitle_finder.find_sub_for(movie_file, language)
        #download_sub!(sub.body, movie_file.path)
        #download_sub!(sub.extract_text, movie_file.path + '_parsed')
      else
        puts "* No sub found"
      end
      puts
    rescue Exception => e
      report_exception(e)
      return false
    end
    return sub
  end

  def report_exception(exception)
    puts
    puts "Something crashed."
    puts "Feel free to report the error here: https://github.com/byroot/ruby-osdb/issues"
    puts "With the following debug informations:"
    puts
    puts "#{exception.class.name}: #{exception.message}:"
    puts exception.backtrace
    puts
  end

  def subtitle_finder
    @subtitle_finder ||= OSDb::SubtitleFinder.new(search_engines, finders, selectors)
  end

  SEARCH_ENGINES = [OSDb::Search::IMDB, OSDb::Search::Name, OSDb::Search::Path]

  def search_engines
    SEARCH_ENGINES.map { |se| se.new(server) }
  end

  def finders
    [OSDb::Finder::Score.new]
  end

  def selectors
    movie_finder = OSDb::Finder::First.new
    
    selectors = [
      OSDb::Selector::Movie.new(movie_finder)
    ]
    selectors << OSDb::Selector::Format.new('.srt')
    selectors
  end

  def server
    @server ||= OSDb::Server.new(
      :timeout => 90, 
      :useragent => "SubDownloader 2.0.10" # register useragent ? WTF ? too boring.
    ) 
  end

  def download_sub!(content, path)
    local_path = "#{path}.srt"
    print "* download to #{local_path} ..."
    
    unless content
      puts "failed"
      return
    end

    File.open(local_path, 'w+') do |file|
      file.write(content)
    end
    puts "done"
  end

end
