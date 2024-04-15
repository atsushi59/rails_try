class StaticPagesController < ApplicationController
    def index
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
  
        # 営業時間情報の取得
        if @place_details['opening_hours']
          #@place_details に opening_hours キーが存在するかどうかをチェック
          day_of_week = Time.zone.today.wday
          #現在の曜日のインデックスを取得
          day_of_week = day_of_week.zero? ? 6 : day_of_week - 1 
          # 日曜始まりに調整
          @today_opening_hours = @place_details['opening_hours']['weekday_text'][day_of_week]
          #調整されたインデックスを使用して、weekday_text 配列から本日の営業時間を取得し、それを @today_opening_hours に格納
        else
          @today_opening_hours = "営業時間の情報はありません。"
        end
  
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