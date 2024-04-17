require 'httparty'

class GoogleDirectionsService
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/directions'

  def initialize(api_key)
    @api_key = api_key
  end

  def get_directions(origin, destination, departure_time, travel_mode: 'driving')
    options = {
      query: {
        origin: origin,
        destination: destination,
        mode: travel_mode,
        departure_time: departure_time,
        key: @api_key
      }
    }
    self.class.get('/json', options)
  end 
end
