# encoding: utf-8

##
# Backup Generated: imagegallery_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t imagegallery_backup [-c <path_to_configuration_file>]
#
Backup::Model.new(:imagegallery_backup, 'Description for imagegallery_backup') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = ENV["IMAGEGALLERY_DB_NAME"]
    db.username           = ENV["IMAGEGALLERY_DB_USER"]
    db.password           = ENV["IMAGEGALLERY_DB_PASSWORD"]
    db.host               = "localhost"
    db.port               = 3306
  end

  store_with Local do |l|
    l.path = "/path/to/backups"
    l.keep = 5
  end

end
