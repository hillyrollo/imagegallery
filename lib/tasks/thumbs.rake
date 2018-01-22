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
  end
end
