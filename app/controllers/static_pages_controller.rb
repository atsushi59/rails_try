class StaticPagesController < ApplicationController
    def index
      api_key = ENV['GOOGLE_PLACES_API_KEY']
      google_places_service = GooglePlacesService.new(api_key)
  
      query = params[:query] || 'デフォルトの検索キーワード'  # フォームからの入力またはデフォルト値
      search_response = google_places_service.search_places(query)
      if search_response.parsed_response['candidates'].any?
        first_result = search_response.parsed_response['candidates'].first
        place_id = first_result['place_id']
  
        details_response = google_places_service.get_place_details(place_id)
        @place_details = details_response.parsed_response['result']
  
        if @place_details['photos']
          photo_reference = @place_details['photos'].first['photo_reference']
          @photo_url = google_places_service.get_photo(photo_reference)
        end
      else
        @place_details = nil
        @photo_url = nil
      end
    end
  end
  