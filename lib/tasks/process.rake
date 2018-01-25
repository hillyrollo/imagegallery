require_relative '../image_processing_helper.rb'

namespace :process do
  desc "Adds new images to the database"
  task new: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    files = Dir["#{Settings.processing_directory}/*.png"]
    file_amt = files.length
    Dir["#{Settings.processing_directory}/*.png"].each_with_index do |image, index|
      puts "#{index+1} of #{file_amt}"
      ImageProcessingHelper.process(image, Settings.image_directory, thumbs_dir)
      puts ''
      sleep 10
    end

    files = Dir["#{Settings.processing_directory}/*.jpg"]
    file_amt = files.length
    Dir["#{Settings.processing_directory}/*.jpg"].each_with_index do |image, index|
      puts "#{index+1} of #{file_amt}"
      ImageProcessingHelper.process(image, Settings.image_directory, thumbs_dir)
      puts ''
      sleep 10
    end
  end

  # Goes through all images in the images directory and adds them to the database, if possible
  task all: :environment do
    thumbs_dir = "#{Settings.image_directory}/thumbs"

    Dir["#{Settings.images_directory}/*.png"].each do |image|
      ImageProcessingHelper.process(image, Settings.image_directory, thumbs_dir)
    end

    Dir["#{Settings.images_directory}/*.jpg"].each do |image|
      ImageProcessingHelper.process(image, Settings.image_directory, thumbs_dir)
    end
  end

  # Delete any images in the database that are no longer on the filesystem
  task removed: :environment do
    Image.all.each do |image|
      next if File.exist?("#{Settings.image_directory}/#{image.filename}")
      image.destroy
    end
  end
end
