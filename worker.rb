loop do
  File.open('log.txt', 'a') do |f|
    f.puts "Working.. #{i}"
  end
  i = i + 1
  sleep 5
end
