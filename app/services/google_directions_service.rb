# frozen_string_literal: true

require 'httparty'

# Defines an action to obtain the time from departure point to destination using the google direction API
class GoogleDirectionsService
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/directions'

  def initialize(api_key)
    @api_key = api_key
    # api_keyの初期化
  end

  def get_directions(origin, destination, departure_time)
    options = {
      query: {
        origin:, # スタート地点(必須)
        destination:, # ゴール地点(必須)
        mode: 'driving', # ルート計算に使用する移動手段(必須)
        departure_time:, # スタートする時間(省略可)
        key: @api_key
      }
    }
    self.class.get('/json', options)
    # /jsonはGoogle Directions APIのルート検索を行うための具体的なパス
  end
end
