# frozen_string_literal: true

require "httparty"

# Defines an action to obtain the time from departure point to destination using NAVITIME API
class NavitimeRouteService
  include HTTParty
  base_uri "https://navitime-route-totalnavi.p.rapidapi.com"

  def initialize(api_key)
    @api_key = api_key # api_keyの初期化下も
    @google_api_key = ENV["GOOGLE_API_KEY"]
    @options = { # APIリクエスト時にHTTPartyライブラリが使用するヘッダー情報を設定
      headers: {
        "X-RapidAPI-Key" => @api_key,
        "X-RapidAPI-Host" => "navitime-route-totalnavi.p.rapidapi.com"
      }
    }
  end

  # 住所を緯度経度に変換
  def geocode_address(address)
    query = { # query というハッシュを定義 addressキーに引数で受け取った住所をGoogle APIのキーインスタンス変数 @google_api_key から取得）を設定
      address: address,
      key: @google_api_key
    }
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json", query: query)
    # HTTParty.get メソッドを使用して、GoogleのGeocoding APIエンドポイントにGETリクエストを送信 query ハッシュがクエリパラメータとして付加
    if response.success?
      # APIリクエストが成功したか
      process_geocode_response(response)
    else
      "情報を取得できませんでした"
    end
  end

  # get_directionsメソッドは指定されたパラメータを受け取りAPIリクエストを実行します
  def get_directions(origin, destination, start_time)
    formatted_origin = geocode_address(origin)
    # originで取得した住所を緯度経度に変換
    formatted_destination = geocode_address(destination)
    # destinationで取得した住所を緯度経度に変換
    formatted_time = format_departure_time(start_time)
    # format_departure_time(start_time)で定義したのを使う
    perform_directions_query(formatted_origin, formatted_destination, formatted_time)
  end

  private

  def perform_directions_query(formatted_origin, formatted_destination, formatted_time)
    query_options = {
      query: {
        start: formatted_origin, # start(必須)
        goal: formatted_destination, # goal(必須)
        start_time: formatted_time, # (省略可だが日にちの指定は必須)
        mode: "transit" # 'transit'をデフォルトとして指定(省略可)
      }
    }
    self.class.get("/route_transit", @options.merge(query_options))
    # /route_transit公式に書いてあるエンドポイント
  end

  def process_geocode_response(response)
    results = response.parsed_response["results"] || []
    # resultsがnilなら空の配列を返す
    return "情報を取得できませんでした" if results.empty?

    # resultsがnilなら'情報を取得できませんでした'
    first_result = results.first
    # 取得したresults配列の最初の要素をfirst_resultに割り当て
    if first_result && first_result["geometry"] && first_result["geometry"]["location"]
      # first_resultに有効なgeometryオブジェクトとその中のlocationオブジェクトが存在するかを確認
      location = first_result["geometry"]["location"]
      # 有効なlocationオブジェクトが見つかった場合、その緯度(lat)と経度(lng)を取り出す
      "#{location['lat']},#{location['lng']}"
    else
      "情報を取得できませんでした"
    end
  end

  def format_departure_time(start_time)
    Time.parse(start_time).strftime("%Y-%m-%dT%H:%M:%S")
    # start_time 文字列を解析してISO 8601形式の日時文字列に変換
  end
end
