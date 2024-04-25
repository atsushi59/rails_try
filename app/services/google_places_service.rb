# frozen_string_literal: true

require 'httparty' # 使用するgem

# This is an action that uses the Google Places API to obtain detailed information about a location.
class GooglePlacesService
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/place'
  # APIエンドポイントの基本となるURI

  # APIキーを受け取るコンストラクタ
  def initialize(api_key)
    @api_key = api_key
  end

  # 場所を検索するためのメソッド
  def search_places(query)
    options = {
      query: { # queryメソッドで検索された値が入る（例 東京タワー）
        input: query,
        inputtype: 'textquery', # 検索の種類
        fields: 'place_id,name,formatted_address,business_status', # APIから取得する情報のフィールドを指定
        key: @api_key, # APIキーを指定
        language: 'ja' # 言語
      }
    }
    self.class.get('/findplacefromtext/json', options)
    # HTTParty gemを使用してGoogle Places APIにGETリクエストを送信するためのコード
  end

  # 表示したい項目をパラメーターに記載
  def get_place_details(place_id, fields = 'name,formatted_address,opening_hours,website,photo')
    # search_places(query)で取得したデーターをどう表示するか書く
    options = {
      query: {
        place_id:, # search_places(query)で取得したplace_idを渡している
        fields:,
        key: @api_key,
        language: 'ja'
      }
    }
    self.class.get('/details/json', options)
  end

  def get_photo(photo_reference, max_width = 400)
    options = {
      query: {
        photoreference: photo_reference,
        maxwidth: max_width,
        key: @api_key
      }
    }
    self.class.get('/photo', options).request.last_uri.to_s
  end
end
