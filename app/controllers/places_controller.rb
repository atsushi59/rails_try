class PlacesController < ApplicationController
    def index
      api_key = ENV['GOOGLE_API_KEY']  # 環境変数からGoogle Places APIキーを取得
      google_places_service = GooglePlacesService.new(api_key)  # GooglePlacesServiceクラスのインスタンスを作成し、APIキーを渡す
  
      queries = Array(params[:query].presence || session.delete(:places) || 'デフォルトの検索キーワード')
      
      @place_details = []
      queries.each do |query|
        search_response = google_places_service.search_places(query)
        if search_response.parsed_response['candidates'].any?
          first_result = search_response.parsed_response['candidates'].first
          place_id = first_result['place_id']
  
          details_response = google_places_service.get_place_details(place_id)
          place_details = details_response.parsed_response['result']
  
          if place_details
            @place_details.push(place_details)
  
            if place_details['opening_hours']
              day_of_week = Time.zone.today.wday
              day_of_week = day_of_week.zero? ? 6 : day_of_week - 1  # 日曜始まりに調整
              place_details['today_opening_hours'] = place_details['opening_hours']['weekday_text'][day_of_week]
            else
              place_details['today_opening_hours'] = "営業時間の情報はありません。"
            end
  
            if place_details['photos']
              photo_reference = place_details['photos'].first['photo_reference']
              place_details['photo_url'] = google_places_service.get_photo(photo_reference)
            end
          end
        end
      end
  
      @place_details.compact!
    end
  end
  