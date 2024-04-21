require 'httparty'

class NavitimeRouteService
  include HTTParty
  base_uri 'https://navitime-route-totalnavi.p.rapidapi.com'

  def initialize(api_key)
    @api_key = api_key
    @google_api_key = ENV['GOOGLE_API_KEY']
    @options = {
      headers: {
        "X-RapidAPI-Key" => @api_key,
        "X-RapidAPI-Host" => "navitime-route-totalnavi.p.rapidapi.com"
      }
    }
  end

  # 住所を緯度経度に変換
  def geocode_address(address)
    query = {
      address: address,
      key: @google_api_key
    }
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json", query: query)
    if response.success?
      results = response.parsed_response["results"]
      if results.any?
        location = results.first["geometry"]["location"]
        return "#{location['lat']},#{location['lng']}"
      end
    end
    "情報を取得できませんでした"
  end

  # get_directionsメソッドは指定されたパラメータを受け取りAPIリクエストを実行します
  def get_directions(origin, destination,start_time)

    formatted_origin = geocode_address(origin)
    formatted_destination = geocode_address(destination)
    formatted_time = format_departure_time(start_time)

    query_options = {
      query: {
        start: formatted_origin,
        goal: formatted_destination,
        start_time: formatted_time,
        mode: 'transit'  # 'transit'をデフォルトとして指定
      }
    }
    self.class.get('/route_transit', @options.merge(query_options))
  end


  private

  def format_departure_time(start_time)
    Time.parse(start_time).strftime('%Y-%m-%dT%H:%M:%S')
  end
end