# The MIT License (MIT)

# Copyright (c) 2014 Lee Duan

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class GenerateOpf
  attr_accessor :current_directory, :opf_name, :opf_file_path, :book_title,
                :book_isbn, :book_publisher, :book_creator, :book_contributor

  OPEN_PUBLICATION_STRUCTURE = 'OPS/'

  def initialize(pwd)
    @current_directory = pwd
    @opf_name = nil
    @opf_file_path = nil
    @book_title = nil
    @book_isbn = nil
    @book_publisher = nil
    @book_creator = nil
    @book_contributor = nil
  end

  def run
    request_metadata
    get_opf_name
    assign_new_opf_path
    write_header
    write_image
    write_css
    write_font
    write_javascript
    write_video
    write_audio
    write_html
    write_text
    write_toc
    write_spine
    success_message
  end

  private

  def request_metadata
    puts '=> What is the book\'s title?'
    self.book_title = gets.chomp

    puts '=> What is the book\'s ISBN or eISBN?'
    self.book_isbn = gets.chomp

    puts '=> Who is the publisher?'
    self.book_publisher = gets.chomp

    puts '=> Who are the creator(s) or author(s)?'
    self.book_creator = gets.chomp

    puts '=> Who are the contributor(s)?'
    self.book_contributor = gets.chomp
  end

  def get_opf_name
    container_xml_path = File.expand_path('../META-INF/container.xml')

    if File.exist? container_xml_path
      full_path = []

      File.open(container_xml_path, 'r').each_line do |line|
        full_path << line.scan(/full-path=".+\/.+\.opf"/).first
      end

      self.opf_name = full_path.compact.first.chomp('"').split(OPEN_PUBLICATION_STRUCTURE).last
    else
      puts '=> ERROR: no container.xml file found in /META-INF folder'
      exit
    end
  end

  def assign_new_opf_path
    if !File.exist? opf_name
      self.opf_file_path = opf_name
    else
      add_opf_increment
    end
  end

  def add_opf_increment
    filename_without_extension = opf_name.split('.opf').first
    increment = 1

    while File.exist? "#{filename_without_extension}-#{increment}.opf"
      increment += 1
    end
    self.opf_file_path = "#{filename_without_extension}-#{increment}.opf"
  end

  def write_header
    manifest_header =
"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"ISBN\" version=\"3.0\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
    <dc:title>#{@book_title}</dc:title>
    <dc:identifier id=\"ISBN\">#{@book_isbn}</dc:identifier>
    <dc:publisher>#{@book_publisher}</dc:publisher>
    <dc:creator>#{@book_creator}</dc:creator>
    <dc:contributor>#{@book_contributor}</dc:contributor>
    <dc:language>en</dc:language>
    <meta property=\"dcterms:modified\">#{Time.now.to_s.split(' ')[0..1].join('T')}Z</meta>
  </metadata>
  <manifest>
"
    File.open(opf_file_path, 'w') do |f|
      f.write(manifest_header)
    end
  end

  def write_image
    images_path = relative_path(Dir["#{current_directory}/**/*.{jpg,jpeg,png,gif,svg}"])

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- images -->")

      images_path.each do |image_path|
        f.puts("    <item id=\"#{replace_id_chars(image_path)}\" href=\"#{image_path}\" " +
          "media-type=\"#{media_type_conversion(image_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_css
    css_paths = relative_path(Dir["#{current_directory}/**/*.{css}"])

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- css -->")

      css_paths.each do |css_path|
        f.puts("    <item id=\"#{replace_id_chars(css_path)}\" href=\"#{css_path}\" " +
          "media-type=\"#{media_type_conversion(css_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_font
    fonts_path = relative_path(Dir["#{current_directory}/**/*.{ttf,otf,eot,woff}"])

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- fonts -->")

      fonts_path.each do |font_path|
        f.puts("    <item id=\"#{replace_id_chars(font_path)}\" href=\"#{font_path}\" " +
          "media-type=\"#{media_type_conversion(font_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_javascript
    js_paths = relative_path(Dir["#{current_directory}/**/*.{js}"])

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- javascript -->")

      js_paths.each do |js_path|
        f.puts("    <item id=\"#{replace_id_chars(js_path)}\" href=\"#{js_path}\" " +
          "media-type=\"#{media_type_conversion(js_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_video
    videos_path = relative_path(Dir["#{current_directory}/**/*.{mp4,m4v}"])
    external_videos_path = external_resources_search(/src="http.+\.mp4"|src="http.+\.m4v"|src="http.+\.mov"/)

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- videos -->")

      videos_path.each do |video_path|
        f.puts("    <item id=\"#{replace_id_chars(video_path)}\" href=\"#{video_path}\" " +
          "media-type=\"#{media_type_conversion(video_path)}\" />")
      end

      external_videos_path.each_with_index do |video_path, index|
        f.puts("    <item id=\"external-video-#{File.extname(video_path).sub('.','')}-#{index+1}\" " +
          "href=\"#{video_path}\" media-type=\"#{media_type_conversion(video_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_audio
    audios_path = relative_path(Dir["#{current_directory}/**/*.{m4a,mp3}"])
    external_audios_path = external_resources_search(/src="http.+\.mp3"|src="http.+\.m4a"/)

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- audio -->")

      audios_path.each do |audio_path|
        f.puts("    <item id=\"#{replace_id_chars(audio_path)}\" href=\"#{audio_path}\" " +
          "media-type=\"#{media_type_conversion(audio_path)}\" />")
      end

      external_audios_path.each_with_index do |audio_path, index|
        f.puts("    <item id=\"external-audio-url-#{File.extname(audio_path).sub('.','')}-#{index+1}\" " +
          "href=\"#{audio_path}\" media-type=\"#{media_type_conversion(audio_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_html
    html_paths = relative_path(Dir["#{current_directory}/**/*.{html}"])

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- html -->")

      html_paths.each do |html_path|
        f.puts("    <item id=\"#{replace_id_chars(html_path)}\" href=\"#{html_path}\" " +
          "media-type=\"#{media_type_conversion(html_path)}\" />")
      end
      f.puts("\n")
    end
  end

  def write_text
    text_paths_with_options = text_properties

    File.open(opf_file_path, 'a') do |f|
      f.puts("    <!-- text -->")

      text_paths_with_options.each do |text_file|
        unless text_file[:path] =~ /toc.xhtml/
          f.puts("    <item id=\"#{replace_id_chars(text_file[:path])}\" #{text_properties_output(text_file)}" +
            "href=\"#{text_file[:path]}\" media-type=\"#{media_type_conversion(text_file[:path])}\" />")
        end
      end
      f.puts("\n")
    end
  end

  def write_toc
    toc = relative_path(Dir["#{current_directory}/**/*toc.xhtml"]).last
    ncx = relative_path(Dir["#{current_directory}/**/*.ncx"]).last

    if toc || ncx
      File.open(opf_file_path, 'a') do |f|
        f.puts("    <!-- toc -->")
        f.puts("    <item id=\"#{replace_id_chars(toc)}\" properties=\"nav\" " +
          "href=\"#{toc}\" media-type=\"application/xhtml+xml\" />") if toc
        f.puts("    <item id=\"#{replace_id_chars(ncx)}\" " +
          " href=\"#{ncx}\" media-type=\"application/x-dtbncx+xml\" />") if ncx
        f.puts("  </manifest>")
        f.puts("\n")
        f.puts("  <spine#{' toc="' + replace_id_chars(ncx) + '"' if ncx}>")
      end
    end
  end

  def write_spine
    main_texts_path = relative_path(Dir["#{current_directory}/*.xhtml"])
    main_texts_path.concat(relative_path(Dir["#{current_directory}/*/*.xhtml"]))
      .reject!{ |text_path| text_path =~ /toc.xhtml/ }

    File.open(opf_file_path, 'a') do |f|
      main_texts_path.each do |text_path|
        f.puts("    <itemref idref=\"#{replace_id_chars(text_path)}\" />")
      end
      f.puts("  </spine>")
      f.puts("</package>")
    end
  end

  def success_message
    puts "=> SUCCESS: generated #{opf_file_path} file."
  end

  def relative_path(path_matches)
    path_matches.map{ |path_match| path_match.split(OPEN_PUBLICATION_STRUCTURE).last }
  end

  def replace_id_chars(str)
    str.gsub(/\/| |\@|\&|\!|\#|\$|\%|\^|\*|\~|\./, '-')
  end

  def external_resources_search(regex)
    urlArray = []

    text_paths = relative_path(Dir["#{current_directory}/**/*.{xhtml}"]).each do |text_path|
      File.open(text_path, 'r').each_line do |line|
        url_paths = line.scan(regex)

        if url_paths.count > 0
          url_paths.map! { |path| path.chomp('"').sub('src="','') }
          urlArray.concat(url_paths)
        end
      end
    end
    urlArray
  end

  def text_properties
    relative_path(Dir["#{current_directory}/**/*.{xhtml}"]).map do |text_path|
      javascripts_exist = nil
      external_resources_exist = nil

      File.open(text_path, 'r').each_line do |line|
        unless javascripts_exist
          javascripts_exist = true if line.scan(/text\/javascript/).count > 0
        end

        unless external_resources_exist
          external_resources_exist = true if line.scan(/src="http/).count > 0
        end
      end
      {path: text_path, javascript: javascripts_exist, resources: external_resources_exist}
    end
  end

  def text_properties_output(options)
    if options[:javascript] && options[:resources]
      properties = 'properties="scripted remote-resources" '
    elsif options[:javascript]
      properties = 'properties="scripted" '
    elsif options[:resources]
      properties = 'properties="remote-resources" '
    else
      properties = ''
    end
  end

  def media_type_conversion(file_name)
    extension_name = File.extname(file_name).sub('.','')
    media_types = {
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
      mov:   'video/mov',
      xhtml: 'application/xhtml+xml',
      html:  'text/html',
      css:   'text/css',
      mp3:   'audio/mpeg',
      m4a:   'audio/mpeg',
      ncx:   'application/x-dtbncx+xml'
    }
    media_types[extension_name.to_sym]
  end
end

GenerateOpf.new(Dir.getwd).run