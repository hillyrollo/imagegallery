module ThumbnailHelper
  def self.create_thumbnail(file_path)
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    extension = File.extname(file_path)
    image_formats = ['.jpg', '.png']
    video_formats = ['.webm', '.mp4']

    if image_formats.include? extension
      `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{file_path} #{thumbs_dir}/#{File.basename(file_path).split('.').first}.png`
    elsif video_formats.include? extension
      if extension == '.mp4'
        `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{file_path}[0] #{thumbs_dir}/#{File.basename(file_path, '.mp4')}.png`
      elsif extension == '.webm'
        temp_thumbname = "#{thumbs_dir}/TEMP_#{File.basename(file_path, '.webm')}.png"
        `ffmpegthumbnailer -i #{file_path} -s 0 -o #{temp_thumbname}`
        `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{temp_thumbname} #{thumbs_dir}/#{File.basename(file_path, '.webm')}.png`
        File.delete(temp_thumbname)
      end
    else
      puts "File type #{extension} not supported. Supported: #{image_formats} #{video_formats}"
      exit 1
    end
  end
end
