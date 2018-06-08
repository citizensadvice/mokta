# frozen_string_literal: true

require "sinatra"
require "sinatra/json"
require "hamlit"
require "jwt"
require "openssl"
require "base64"
require "sinatra/reloader"
enable :reloader
set :haml, format: :html5

KEY = OpenSSL::PKey::RSA.generate 1024

get "/embed_uri" do
  haml :embed_uri_form
end

post "/login" do
  # login all the time
  token = JWT.encode user_claims, KEY, "RS256", kid: "kid"
  redirect "#{env_redirect_url}?id_token=#{token}", 307
end

get "/openid_config_uri" do
  json jwks_uri: "#{env_mokta_url}/jwks_uri", issuer: env_issuer
end

get "/jwks_uri" do
  json jwks
end

get "/signout" do
  uri = URI(params[:fromURI]) if params[:fromURI]
  redirect params[:fromURI], 307 if uri&.host == ENV["URL_HOST"]
end

private

def role
  params[:username][/\A(.+)@/, 1] || "test.user"
end

def user_claims
  read_json(role).merge(time_claims)
end

def public_key
  KEY.public_key
end

def n
  Base64.urlsafe_encode64(public_key.n.to_s(2))
end

def read_json(file_name)
  JSON.parse(File.read("data/#{file_name}.json"))
end

def env_issuer
  ENV.fetch("MOKTA_ISSUER", "https://cadev.oktapreview.com")
end

def env_mokta_url
  ENV.fetch("MOKTA_URL", "http://okta.test:4001")
end

def env_redirect_url
  ENV.fetch("MOKTA_REDIRECT_URL", "http://#{ENV['URL_HOST']}:3000/session")
end

def time_claims
  {
    iat: Time.now.to_i,
    exp: (Time.now + 3600).to_i
  }
end

def jwks
  { "keys": [jwk] }
end

def jwk
  {
    "kty": "RSA",
    "e": "AQAB",
    "use": "sig",
    "kid": "kid",
    "alg": "RS256",
    "n": n
  }
end
