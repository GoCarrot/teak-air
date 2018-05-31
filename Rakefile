require "rake/clean"
require "httparty"
CLEAN.include "**/.DS_Store"

KMS_KEY = `aws kms decrypt --ciphertext-blob fileb://kms/store_encryption_key.key --output text --query Plaintext | base64 --decode`
CIRCLE_TOKEN = ENV.fetch('CIRCLE_TOKEN') { `openssl enc -md MD5 -d -aes-256-cbc -in kms/encrypted_circle_ci_key.data -k #{KMS_KEY}` }

namespace :build do
  task :cleanroom do
    HTTParty.post("https://circleci.com/api/v1.1/project/github/GoCarrot/teak-air-cleanroom/tree/master?circle-token=#{CIRCLE_TOKEN}",
                  body: {
                    build_parameters: {
                      FL_TEAK_SDK_VERSION: `git describe --tags --always`.strip
                    }
                  }.to_json,
                  headers: {
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json'
                  })
  end
end
