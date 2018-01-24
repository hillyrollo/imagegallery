require_relative '../thumbnail_helper.rb'
namespace :thumbs do
  desc "Generate Thumbnails"
  task generate: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    if !File.exist? thumbs_dir
      puts "Thumbnail directory, #{thumbs_dir}, does not exist. Create it and run this task again"
    end
    extensions = ['png', 'jpg', 'webm', 'mp4']
    extensions.each do |ext|
      create_thumbnails(ext)
    end
  end

  task generate_all: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"
    if !File.exist? thumbs_dir
      puts "Thumbnail directory, #{thumbs_dir}, does not exist. Create it and run this task again"
    end

    extensions = ['png', 'jpg', 'webm', 'mp4']
    extensions.each do |ext|
      create_thumbnails(ext, force_new: true)
    end
  end
end

def create_thumbnails(format, options = {})
  Dir["#{Settings.image_directory}/*.#{format}"].each do |image|
    if File.exist?("#{Settings.image_directory}/thumbs/#{File.basename(image).split('.').first}.png")
      next unless options[:force_new]
    end
    puts "creating thumbnail for #{image}"
    ThumbnailHelper.create_thumbnail(image)
  end
end
