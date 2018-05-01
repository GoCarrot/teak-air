require "rake/clean"
CLEAN.include "**/.DS_Store"

CIRCLE_TOKEN = ENV.fetch('CIRCLE_TOKEN') { `aws kms decrypt --ciphertext-blob fileb://kms/encrypted_circle_ci_key.data --output text --query Plaintext | base64 --decode` }

namespace :build do
  task :cleanroom do
    HTTParty.post("https://circleci.com/api/v1.1/project/github/GoCarrot/teak-air-cleanroom/tree/master?circle-token=#{CIRCLE_TOKEN}",
                  body: {
                    build_parameters: {
                      FL_TEAK_SDK_VERSION: `git describe --tags --always`
                    }
                  }.to_json,
                  headers: {
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json'
                  })
  end
end
