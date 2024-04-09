class StaticPagesController < ApplicationController
  def index
    @current_location = Geocoder.search(request.remote_ip).first
    api_key = ENV['GOOGLE_API_KEY'] #環境変数からGoogle Places APIキーを取得
    google_places_service = GooglePlacesService.new(api_key) #GooglePlacesServiceクラスのインスタンスを作成し、APIキーを渡す

    query = params[:query] || 'デフォルトの検索キーワード'  # フォームからの入力またはデフォルト値
    search_response = google_places_service.search_places(query)
    #検索キーワードを使用して場所を検索し、結果をsearch_responseに格納
    if search_response.parsed_response['candidates'].any?
      first_result = search_response.parsed_response['candidates'].first
      place_id = first_result['place_id']
       #検索結果が存在する場合、最初の結果のplace_idを取得

      details_response = google_places_service.get_place_details(place_id)
      @place_details = details_response.parsed_response['result']
      #google_places_service.get_place_details(place_id): place_idを使用して場所の詳細を取得し取得した場所の詳細を@place_detailsに格納

      if @place_details['photos']
        photo_reference = @place_details['photos'].first['photo_reference']
        @photo_url = google_places_service.get_photo(photo_reference)
        #@place_details['photos']: 場所に写真がある場合、写真のURLを取得
        #first['photo_reference']により一番最初に取得した画像のみ表示される
      end
    else
      @place_details = nil
      @photo_url = nil
      #検索結果がない場合、@place_detailsと@photo_urlをnilに設定
    end
  end
end