require 'httparty'

class NavitimeRouteService
  include HTTParty
  base_uri 'https://navitime-route-totalnavi.p.rapidapi.com'

  def initialize(api_key)
    @api_key = api_key
    @options = {
      headers: {
        "X-RapidAPI-Key" => @api_key,
        "X-RapidAPI-Host" => "navitime-route-totalnavi.p.rapidapi.com"
      }
    }
  end

  # get_directionsメソッドは指定されたパラメータを受け取りAPIリクエストを実行します
  def get_directions(origin, destination,start_time)

    formatted_time = format_departure_time(start_time)

    query_options = {
      query: {
        start: origin,
        goal: destination,  # 公式ドキュメントに合わせてパラメータ名を 'destination' から 'goal' に変更
        start_time: formatted_time,  # 'departure_time' を 'start_time' に変更
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