namespace :thumbs do
  desc "Generate Thumbnails"
  task generate: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    if !File.exist? thumbs_dir
      puts "Thumbnail directory, #{thumbs_dir}, does not exist. Create it and run this task again"
    end

    Dir["#{Settings.image_directory}/*.png"].each do |image|
      RakeHelper.create_thumbnail(image, Settings.image_directory)
    end

    Dir["#{Settings.image_directory}/*.jpg"].each do |image|
      RakeHelper.create_thumbnail(image, Settings.image_directory)
    end
  end
end
