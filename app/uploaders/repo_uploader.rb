class RepoUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def size_range
    1..5.megabytes
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    '/images/fallback/' + [version_name, 'default.png'].compact.join('_')
  end

  def public_bucket?
    true
  end

  def bucket_name
    ENV['AWS_S3_PUBLIC_IMAGES_BUCKET_NAME']
  end

  def fog_directory
    bucket_name
  end

  process :fix_exif_rotation

  #
  # 何かと使うサムネイル画像を作成しておく
  #
  version :thumb_400x400 do
    process resize_to_fill: [400, 400]
  end
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  #
  # EXIF情報を削除
  #
  def fix_exif_rotation
    manipulate! do |img|
      img.tap(&:auto_orient!)
    end
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, Digest::MD5.hexdigest(Time.current.to_f.to_s))
  end
end
