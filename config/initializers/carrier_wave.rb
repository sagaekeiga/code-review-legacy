# HerokuでFog関連のエラーが出る問題の対応
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

#
# CarrierWaveの初期設定
#
CarrierWave.configure do |config|
  config.fog_provider = 'fog-aws'
  config.fog_credentials = {
    provider:                'AWS',
    aws_access_key_id:       ENV['AWS_ACCESS_KEY'] || '',
    aws_secret_access_key:   ENV['AWS_SECRET_KEY'] || '',
    region:                  ENV['AWS_REGION'] || ''
  }
  case Rails.env
  when 'development'
    config.cache_dir = "#{Rails.root}/tmp/images"
    config.storage = :file
    # config.permissions = 0666
    # config.directory_permissions = 0777
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.asset_host = "//#{ENV['WEB_DOMAIN']}"
  when 'test'
    config.storage = :file
    config.asset_host = "//#{ENV['WEB_DOMAIN']}"
    config.enable_processing = false
  when 'staging'
    config.storage = :fog
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.asset_host = proc do |uploader|
      uploader.public_bucket? ? "https://#{ENV['WEB_DOMAIN']}" : "https://#{uploader.bucket_name}.s3.amazonaws.com";
    end
  else
    config.storage = :fog
    config.cache_dir = "#{Rails.root}/tmp/images"
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.asset_host = proc do |uploader|
      uploader.public_bucket? ? "https://#{ENV['WEB_DOMAIN']}" : "https://#{uploader.bucket_name}.s3.amazonaws.com";
    end
  end
end