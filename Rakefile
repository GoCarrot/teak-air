# frozen_string_literal: true

require 'rake/clean'
require 'httparty'
require 'awesome_print'
require 'tempfile'
CLEAN.include '**/.DS_Store'

KMS_KEY = `aws kms decrypt --ciphertext-blob fileb://kms/store_encryption_key.key --output text --query Plaintext | base64 --decode`.freeze
CIRCLE_TOKEN = ENV.fetch('CIRCLE_TOKEN') { `openssl enc -md MD5 -d -aes-256-cbc -in kms/encrypted_circle_ci_key.data -k #{KMS_KEY}` }
ADOBE_AIR_HOME = ENV.fetch('ADOBE_AIR_HOME', '~/adobe-air-sdk')

namespace :build do
  task :cleanroom do
    json = HTTParty.post("https://circleci.com/api/v1.1/project/github/GoCarrot/teak-air-cleanroom/build?circle-token=#{CIRCLE_TOKEN}",
                         body: {
                           build_parameters: {
                             FL_TEAK_SDK_VERSION: `git describe --tags --always`.strip
                           }
                         }.to_json,
                         headers: {
                           'Content-Type' => 'application/json',
                           'Accept' => 'application/json'
                         }).body
    ap(JSON.parse(json))
  end
end

namespace :sdk do
  task :build do
    `ADOBE_AIR_HOME=#{ADOBE_AIR_HOME} ./compile`
  end

  task :setup do
    unless File.exist?("#{ADOBE_AIR_HOME}/bin/compc")
      FileUtils.mkdir_p ADOBE_AIR_HOME
      Tempfile.create('cookies') do |f|
        json = JSON.parse(`curl --silent --cookie-jar #{f.path} https://airsdk.harman.com/api/config-settings/download`)
        air_sdk_version = '33.1.1.217' # json['latestVersion']['versionName']
        puts "Downloading AIR SDK #{air_sdk_version}..."
        dl_link =  "https://airsdk.harman.com/api/versions/#{air_sdk_version}/sdks/AIRSDK_MacOS.zip?id=#{json['id']}"
        zip_file = 'air_sdk.zip'
        `curl --cookie #{f.path} --cookie-jar #{f.path} #{dl_link} --output #{zip_file}`
        `unzip #{zip_file} -d #{ADOBE_AIR_HOME}`
        `rm #{zip_file}`
      end
    end
  end
end
