# frozen_string_literal: true

require "httparty"

Geocoder.configure(
  lookup: :google, # ジオコーディングサービスとしてGoogleを使用
  api_key: ENV["GOOGLE_API_KEY"],
  use_https: true # HTTPSプロトコルを使用してリクエストを送信
)
