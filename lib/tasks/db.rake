task :extract_timed_text => :environment do
  puts "-----> Extracting times to content of movies with original srt"
  puts "-----> Movies with original srt: #{Movie.where.not(original_srt: nil).count}"
  
  Movie.where.not(original_srt: nil).each do |m|
    m.content = m.extract_timed_text
    p m.errors if not m.save
  end
  
  puts "-----> Done"
end
