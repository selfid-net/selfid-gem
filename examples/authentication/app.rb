# frozen_string_literal: true

require 'selfid'

# Process input data
abort("provide self_id to authenticate") if ARGV.length != 1
user = ARGV.first

# Connect your app to Self network, get your connection details creating a new
# app on https://developer.selfid.net/
@app = Selfid::App.new(ENV["SELF_APP_ID"], ENV["SELF_APP_SECRET"])

# Allows connections from everyone on self network to your app.
@app.permit_connection("*")

# Authenticate a user to your app.
puts "Sending an authentication request to your device..."
@app.authenticate user do |auth|
  # The user has rejected the authentication
  if not auth.accepted?
    puts "Authentication request has been rejected"
    exit!
  end

  puts "User is now authenticated 🤘"
end

# Wait for asyncrhonous process to finish
sleep 100