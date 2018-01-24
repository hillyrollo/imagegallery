namespace :thumbs do
  desc "Generate Thumbnails"
  task generate: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    if !File.exist? thumbs_dir
      puts "Thumbnail directory, #{thumbs_dir}, does not exist. Create it and run this task again"
    end

    Dir["#{Settings.image_directory}/*.png"].each do |image|
      `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{image} #{thumbs_dir}/#{File.basename(image)}`
    end

    Dir["#{Settings.image_directory}/*.jpg"].each do |image|
      `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{image} #{thumbs_dir}/#{File.basename(image)}`
    end

    Dir["#{Settings.image_directory}/*.webm"].each do |image|
      puts 'making webm thumbnail'
      temp_thumbname = "#{thumbs_dir}/TEMP_#{File.basename(image, '.webm')}.png"
      `ffmpegthumbnailer -i #{image} -s 0 -o #{temp_thumbname}`
      `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{temp_thumbname} #{thumbs_dir}/#{File.basename(image, '.webm')}.png`
      puts temp_thumbname
      File.delete(temp_thumbname)
    end

    Dir["#{Settings.image_directory}/*.mp4"].each do |image|
      `convert -thumbnail 180x180 -gravity center -background white -extent 180x180 #{image}[0] #{thumbs_dir}/#{File.basename(image, '.mp4')}.png`
    end
  end
end
