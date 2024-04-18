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

  def get_directions(origin, destination, departure_time, travel_mode: 'transit')
    query_options = {
      query: {
        origin: origin,
        destination: destination,
        mode: travel_mode,
        departure_time: departure_time
      }
    }
    self.class.get('/your-endpoint', @options.merge(query_options))
  end
end
