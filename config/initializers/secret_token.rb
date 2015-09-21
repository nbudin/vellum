# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Vellum::Application.config.secret_token = ENV['SESSION_SECRET'] || 'ec75b5c165405218b90b3b9f03a1fe7a07ac71f962817695159bebf0aac0f3e645dc08065850a3d788fae7c08ac8f490f85b905322e1f2920cb0c53fe38aee77'
Vellum::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || '434485d9316afcab97537f4c56711c1365435b4b7c1dd53cc5eb55f773d392c7eb382b5931be3e70d0ae99fee3b79c4a362b91012d045897eaf156815aab1d26'

