require 'pry'

class GenerateOpf
  attr_accessor :dir, :opf_file, :book_title, :book_isbn,
                :book_publisher, :book_creator, :book_contributor

  def initialize(pwd)
    @dir = pwd
    @opf_file_path = nil
    @book_title = nil
    @book_isbn = nil
    @book_publisher = nil
    @book_creator = nil
    @book_contributor = nil
  end

  def run
    @opf_file_path = create_new_opf_file
    write_header
    write_css
    write_fonts
    write_javascript
    write_video
    write_audio
    write_text
    write_toc
    write_spine
  end

  private

  def create_new_opf_file
    if !File.exist? 'content.opf'
      File.new('content.opf', 'w+').close
      @opf_file_path = 'content.opf'
    else
      @opf_file_path = iterate_opf_file
    end
  end

  def iterate_opf_file
    name = 'content'
    index = 1
    while File.exist? "#{name}-#{index}.opf"
      index+=1
    end
    File.new("#{name}-#{index}.opf", 'w+').close
    @opf_file_path = "#{name}-#{index}.opf"
  end

  def write_header
    header =
"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"ISBN\" version=\"3.0\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
    <dc:title>#{@book_title.to_s}</dc:title>
    <dc:identifier id=\"ISBN\">#{@book_isbn.to_s}</dc:identifier>
    <dc:publisher>#{@book_publisher.to_s}</dc:publisher>
    <dc:creator>#{@book_creator.to_s}</dc:creator>
    <dc:contributor>#{@book_contributor.to_s}</dc:contributor>
    <dc:language>en-US</dc:language>
    <meta property=\"dcterms:modified\">#{Time.now.to_s.split(' ')[0..1].join('T')}Z</meta>
  </metadata>
  <manifest>
"
    File.open(@opf_file_path, 'w') do |f|
      f.write(header)
    end
  end

  def write_css
    images = Dir["#{@dir}/**/*.{jpg,jpeg,png,gif,svg}"]
    images.map!{ |image| image.split('OPS/').last }
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- images -->")
      images.each do |image|
        media_type = media_type_conversion(File.extname(image).sub('.',''))
        f.puts("    <item id=\"#{image.gsub(/\//, '-').gsub(/ /, '-')}\" href=\"#{image}\" media-type=\"#{media_type}\">")
      end
      f.puts("\n")
    end
  end

  def write_fonts
    fonts = Dir["#{@dir}/**/*.{ttf,otf,eot,woff}"]
    fonts.map!{ |font| font.split('OPS/').last }
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- fonts -->")
      fonts.each do |font|
        media_type = media_type_conversion(File.extname(font).sub('.',''))
        f.puts("    <item id=\"#{font.gsub(/\//, '-').gsub(/ /, '-')}\" href=\"#{font}\" media-type=\"#{media_type}\">")
      end
      f.puts("\n")
    end
  end

  def write_javascript
    javascripts = Dir["#{@dir}/**/*.{js}"]
    javascripts.map!{ |javascript| javascript.split('OPS/').last }
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- javascript -->")
      javascripts.each do |javascript|
        media_type = media_type_conversion(File.extname(javascript).sub('.',''))
        f.puts("    <item id=\"#{javascript.gsub(/\//, '-').gsub(/ /, '-')}\" href=\"#{javascript}\" media-type=\"#{media_type}\">")
      end
      f.puts("\n")
    end
  end

  def write_video
    texts = Dir["#{@dir}/**/*.{html,xhtml}"]
    texts.map!{ |text| text.split('OPS/').last }
    absolute_videos = []
    texts.each do |text|
      File.open(text, 'r').each_line do |line|
        matches = line.scan(/src="http.+\.mp4"|src="http.+\.m4v"/)
        if matches.count > 0
          matches.map! { |match| match.chomp('"').sub('src="','') }
          absolute_videos.concat(matches)
        end
      end
    end
    videos = Dir["#{@dir}/**/*.{mp4,m4v}"]
    videos.map!{ |video| video.split('OPS/').last }
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- videos -->")
      videos.each do |video|
        media_type = media_type_conversion(File.extname(video).sub('.',''))
        f.puts("    <item id=\"#{video.gsub(/\//, '-').gsub(/ /, '-')}\" href=\"#{video}\" media-type=\"#{media_type}\">")
      end
      absolute_videos.each_with_index do |video, index|
        ext = File.extname(video).sub('.','')
        media_type = media_type_conversion(ext)
        f.puts("    <item id=\"external-video-url-#{ext}-#{index+1}\" href=\"#{video}\" media-type=\"#{media_type}\">")
      end
      f.puts("\n")
    end
  end

  def write_audio
    texts = Dir["#{@dir}/**/*.{html,xhtml}"]
    texts.map!{ |text| text.split('OPS/').last }
    absolute_audios = []
    texts.each do |text|
      File.open(text, 'r').each_line do |line|
        matches = line.scan(/src="http.+\.mp3"|src="http.+\.m4a"/)
        if matches.count > 0
          matches.map! { |match| match.chomp('"').sub('src="','') }
          absolute_audios.concat(matches)
        end
      end
    end
    audios = Dir["#{@dir}/**/*.{m4a,mp3}"]
    audios.map!{ |audio| audio.split('OPS/').last }
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- audio -->")
      audios.each do |audio|
        media_type = media_type_conversion(File.extname(audio).sub('.',''))
        f.puts("    <item id=\"#{audio.gsub(/\//, '-').gsub(/ /, '-')}\" href=\"#{audio}\" media-type=\"#{media_type}\">")
      end
      absolute_audios.each_with_index do |audio, index|
        ext = File.extname(audio).sub('.','')
        media_type = media_type_conversion(ext)
        f.puts("    <item id=\"external-audio-url-#{ext}-#{index+1}\" href=\"#{audio}\" media-type=\"#{media_type}\">")
      end
      f.puts("\n")
    end
  end

  def write_text
    texts = Dir["#{@dir}/**/*.{html,xhtml}"]
    texts.map! do |text|
      text = text.split('OPS/').last
      javascript_exists = nil
      external_resources_exist = nil
      File.open(text, 'r').each_line do |line|
        unless javascript_exists
          javascript_exists = true if line.scan(/text\/javascript/).count > 0
        end
        unless external_resources_exist
          external_resources_exist = true if line.scan(/src="http/).count > 0
        end
      end
      [text, javascript_exists, external_resources_exist]
    end
    File.open(@opf_file_path, 'a') do |f|
      f.puts("    <!-- text -->")
      texts.each do |text|
        unless text =~ /toc.xhtml/
          media_type = media_type_conversion(File.extname(text[0]).sub('.',''))
          if text[1] && text[2]
            properties = 'properties="scripted remote-resources" '
          elsif text[1]
            properties = 'properties="scripted" '
          elsif text[2]
            properties = 'properties="remote-resources" '
          else
            properties = ''
          end
          f.puts("    <item id=\"#{text[0].gsub(/\//, '-').gsub(/ /, '-')}\" #{properties}href=\"#{text[0]}\" media-type=\"#{media_type}\">")
        end
      end
      f.puts("\n")
    end
  end

  def write_toc

  end

  def write_spine

  end

  def media_type_conversion(ext)
    extension_match = {
      jpg:   'image/jpeg',
      jpeg:  'image/jpeg',
      png:   'image/png',
      gif:   'image/gif',
      svg:   'image/svg+xml',
      eot:   'application/vnd.ms-fontobject',
      woff:  'application/x-font-woff',
      ttf:   'application/x-font-ttf',
      otf:   'application/x-font-opentype',
      js:    'text/javascript',
      m4v:   'video/m4v',
      mp4:   'video/mp4',
      xhtml: 'application/xhtml+xml',
      html:  'text/html',
      mp3:   'audio/mpeg',
      m4a:   'audio/mpeg',
      ncx:   'application/x-dtbncx+xml'
    }
    extension_match[ext.to_sym]
  end
end

GenerateOpf.new(Dir.getwd).run