require 'get_subtitles'

task :extract_timed_text => :environment do
  puts "-----> Extracting times to content of movies with original srt"
  puts "-----> Movies with original srt: #{Movie.where.not(original_srt: nil).count}"
  
  Movie.where.not(original_srt: nil).each do |m|
    m.content = m.extract_timed_text
    p m.errors if not m.save
  end
  
  puts "-----> Done"
end

task :fetch_missing_original_srt => :environment do
  puts "-----> Fetching missing original SRTs"
  puts "-----> Movies missing original srt: #{Movie.where(original_srt: nil).count}"

  Movie.where(original_srt: nil).each do |m|
    next if m.content.match(/\[[:\d]+\]\n/i) || m.name == 'Underground'

    begin
      sub = FetchSubtitle.new.search(m.name, [OSDb::Search::IMDB])
      sleep 2 if sub == false
    end while sub == false

    if sub && sub.raw_data["IDMovieImdb"] == m.imdb_id
      begin
        m.content = Movie.extract_timed_text(sub.body)
        m.original_srt = sub.body
        p m.errors if not m.save
        puts ">> Done with #{m.name}"
      rescue Zlib::GzipFile::Error => e
        puts "Gzip Error - Probably because of Anti Leeching protection"
      end
    end
    puts
    
  end

  puts "-----> Movies missing original srt: #{Movie.where(original_srt: nil).count}"
  puts "-----> Done"
end
