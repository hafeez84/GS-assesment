require 'down'

def read_urls_from_file(file)
  urls = Array.new
  File.open(file).each do |line|
    line = line.strip
    next if line == nil || line.length == 0
    urls.push(line)
  end
  urls
end

def create_directory(dirname)
  unless Dir.exists?(dirname)
    Dir.mkdir(dirname)
  else
    puts "Skip creating directory " + dirname + ". It already exists."
  end
end

def download_urls(urls)
  urls.each do |uri|
    filename = uri.split("/").last
    puts "Starting download for: " + filename
    unless File.exists?(filename)
      begin
        tempfile = Down.download(
          uri,
          destination: "./#{filename}",
          max_redirects: 5,
          max_size: 20 *1024*1024
        )
        puts "Stored download as" + filename
      rescue Exception => e
        puts "=> Exception: '#{e}'. Skipping download."
      end
    else
      puts "Skipping download for " + filename + ". It already exists."
    end
  end
end


def main
  sources_file = ARGV.first
  urls = read_urls_from_file(sources_file)

  target_dir_name = sources_file.split(".")[0] + "Downloaded"
  create_directory(target_dir_name)
  Dir.chdir(target_dir_name)
  puts "Changed directory: " + Dir.pwd

  download_urls(urls)
end


if __FILE__ == $0
  usage = <<-EOU
usage: ruby #{File.basename($0)} sources.txt
  The file sources.txt should contain the urls.
  The expected file format is:
  http://www.domain.com/file
  https://www.domain.com/file
  EOU

  abort usage if ARGV.length < 1
  main

end
