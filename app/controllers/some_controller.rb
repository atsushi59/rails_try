class SomeController < ApplicationController
  before_action :set_google_places_service
  before_action :set_directions_service
  before_action :set_navitime_route_service

  def search
    api_key = ENV['OPENAI_API_KEY']
    #apiキーの取得
    chatgpt_service = ChatgptService.new(api_key)
    #取得したapiキーを渡し新しいインスタンスの作成

    selected_transport = params[:selected_transport]
    selected_time = params[:selected_time]
    selected_age = params[:selected_age]
    selected_activity = params[:selected_activity]
    address = params[:address]
    #フォームから送信されたパラメーターをuser_inputに代入

    session[:selected_transport] = selected_transport
    #selected_transportで選択された(車,電車)パラメータをサーバー側のセッションに保存
    session[:address] = address if address.present?
    #addressで選択された(住所)パラメータをサーバー側のセッションに保存　indexで使用
    session[:selected_time] = params[:selected_time]
    #selected_timeで選択された(時間)パラメータをサーバー側のセッションに保存　indexで使用
    session[:selected_activity] = params[:selected_activity]
    #placeテーブルに保存するためにサーバー側のセッションに保存
    
    user_input = "#{address}から#{selected_transport}で#{selected_time}以内で#{selected_age}の子供が対象の#{selected_activity}できる場所を正式名称で2件提示してください"
    
      messages=[
        { role: 'system', content: 'You are a helpful assistant.' },
        #roleはsystemであり、ChatGPTの動作モードや役割に関する指示を提供
        { role: 'user', content: user_input }
        #実際のユーザー入力を模しています user_input変数から取得
      ]
    
    response = chatgpt_service.create_chat_completion(messages)
    #作成されたメッセージをcreate_chat_completionメソッドに渡して、ChatGPT APIにリクエストを送信
    
    if response.success?
      @result = response.parsed_response
      #response.parsed_response: 応答の内容を解析し、@result変数に格納
      #parsed_responseは、JSON形式で返されたデータをRubyのハッシュに変換したもの
      message_content = @result['choices'].first['message']['content']
      #最初の選択肢(choices)のメッセージ内容を取得してmessage_contentに代入します。これは、ChatGPTが生成したテキスト内容
      
      places = message_content.split("\n").select { |line| line.match(/^\d+\./) }
      #取得したメッセージ内容を改行文字(\n)で分割し、各行を配列の要素として扱います
      #その後、行の始めが数字で始まるもの（例：1. Place Name）を選択し、そのようなパターンに一致する行のみをplaces配列に格納
      @answer = places.join("\n")
      #places配列の要素を改行で結合して@answerに代入
      session[:query] = @answer
      #sessionでブラウザに一時的に保存
      redirect_to index_path
      

    else
      @error_message = "Error: #{response.parsed_response['error']['message']}"
    end
  end

  def index
    # セッションからクエリリストを取得して配列に変換
    queries = session[:query].to_s.split("\n").map { |q| q.split('. ').last.strip }
    #queryキーに関連付けられた値を取得, \n）で分割し、個々の行を要素とする配列を作成
    @places_details = []
    #@places_detailsを初期化し、空の配列を割り当て 後に使う
  
    selected_time = session[:selected_time].to_i

    # 各クエリに対して検索を行い、結果を配列に保存
    queries.each do |query|
      response = @google_places_service.search_places(query)
      if response["candidates"].any?
        #candidatesは検索クエリに基づいて見つかった場所の候補一覧を含む配列 検索結果の候補リストが空でないかどうかを確認
        first_result = response["candidates"].first
        #検索結果リストの最初の要素を first_result に格納 最も関連性の高い結果を取得するための処理
        place_id = first_result["place_id"]
        #first_result から "place_id" キーに関連する値を取得し、place_id 変数に格納
        details_response = @google_places_service.get_place_details(place_id)
        #lace_id を用いて、@google_places_service の get_place_details メソッドを呼び出し、その場所の詳細情報を取得 結果は details_response に格納
        place_detail = details_response["result"]
        #details_response から "result" キーに関連する値を取得(名前、住所等)し、place_detail に格紀保存します。この値には場所の詳細データが含まれる
        
        # 営業時間と写真のURLを取得
        opening_hours = place_detail['opening_hours'] ? place_detail['opening_hours']['weekday_text'][Time.zone.today.wday.zero? ? 6 : Time.zone.today.wday - 1] : "営業時間の情報はありません。"
        #条件演算子を使用して、場所の営業時間を取得 opening_hours が存在する場合、現在の曜日に対応する営業時間のテキストを取得
        photo_reference = place_detail['photos'] ? @google_places_service.get_photo(place_detail['photos'].first['photo_reference']) : nil
        #photos キーが存在する場合、最初の写真の photo_reference を使って、その写真を取得するためのリンクまたはデータを @google_places_service の get_photo メソッドを通じて取得し、photo_reference に格納

      #placesテーブルに検索結果を保存
      place = Place.find_or_create_by(name: place_detail['name'], address: place_detail['formatted_address']) do |new_place|
        new_place.website = place_detail['website']
        new_place.opening_hours = opening_hours
        new_place.photo_url = photo_reference
        new_place.selected_activity = session[:selected_activity]
      end
      
      travel_time_minutes = calculate_travel_time(place_detail)
      #calculate_travel_time(place_detail)で取得した時間をtravel_time_minutesに格納(指定された場所への所要時間を分単位で計算し、その結果を返す)
      place_detail['travel_time_text'] = "#{travel_time_minutes}分" if travel_time_minutes
      #travel_time_minutesがtrueだった場合"#{travel_time_minutes}分が30分という形になりplace_detail['travel_time_text']に30分が格納される

      if travel_time_minutes && travel_time_minutes <= selected_time
        #travel_time_minutesがnilまたはfalseでなく、かつselected_time（ユーザーが指定した最大所要時間）以下の場合
        @places_details.push(place_detail.merge("today_opening_hours" => opening_hours, "photo_url" => photo_reference))
        #取得した詳細情報を配列に追加 "today_opening_hours" と "photo_url" という新しいキーに割り当てて、元の place_detail ハッシュにマージ
        #place_detailとtoday_opening_hours" と "photo_url"が検索結果として表示
      else
        @places_details.push({ "name" => query, "error" => "No results found" })
        #travel_time_minutesが存在しないか、またはselected_timeよりも大きい場合、結果が見つからなかったとしてエラーメッセージを持つオブジェクトを配列に追加
      end
    else
      @places_details.push({ "name" => query, "error" => "No results found" })
    end
  end
end

  def calculate_travel_time(place_detail)
    origin = session[:address]
    #ユーザーがフォームで送信した住所
    destination = place_detail['formatted_address']
    #place_detailで提示された住所

    # セッションから選択された交通手段を取得し、それが「車」であるかどうかをチェック
    if session[:selected_transport] == '車'
      travel_mode = 'driving'
      response = @directions_service.get_directions(
        origin, 
        destination,
        Time.now.to_i
      )
      #@directions_serviceで定義したget_directionsを使用しoriginからdestinationまでを現在の時間からルート検索する
      if response.success? && response.parsed_response['routes'].any?
        #上記のresponseとparsed_response['routes']がtrueだった場合 routesについては下記に詳細を記載
        travel_time_text = response.parsed_response['routes'].first['legs'].first['duration']['text']
        #response.parsed_response['routes']で取得した一番最初の['legs']の中の['duration']['text']を取得(ルートの時間)
        travel_time_text = convert_duration_to_minutes(travel_time_text)
        #convert_duration_to_minutesを使用しルートの時間を1 hours 30 minsから90に変更(privateに定義)(比較する際に90という形に合わせる為)
      else
        travel_time_text = "所要時間の情報は利用できません。"
      end
    elsif session[:selected_transport] == '公共交通機関'
      # セッションから選択された交通手段を取得し、それが「公共交通機関」であるかどうかをチェック
      travel_mode = 'transit'
      formatted_origin = @navitime_route_service.geocode_address(origin)
      #指定された住所を@navitime_route_service.geocode_addressを用いて緯度経度に変換
      formatted_destination = @navitime_route_service.geocode_address(destination)
      response = @navitime_route_service.get_directions(
        formatted_origin, #上記で定義
        formatted_destination, #上記で定義
        start_time = (Time.now.utc + 9.hours).strftime('%Y-%m-%dT%H:%M:%S')
      ) #現在のUTC時間から9時間加えて日本の標準時に調整
        #@navitime_route_serviceで定義したget_directionsを使用しstartからgoalまでを現在の時間からルート検索する

        if response.success? && response.parsed_response['items'].any?
        #上記のresponseとparsed_response['items']がtrueだった場合 itemsについては下記に詳細を記載
        travel_time_text = response["items"].first["summary"]["move"]["time"]
        #response.parsed_response['items']で取得した一番最初の['summary']['move']['time']を取得(ルートの時間)
    else
      travel_time_text = "所要時間の情報は利用できません。"
    end
  end
end
  
  private

  def set_google_places_service
    api_key = ENV['GOOGLE_API_KEY'] #環境変数からGoogle Places APIキーを取得
    @google_places_service = GooglePlacesService.new(api_key) #GooglePlacesServiceクラスのインスタンスを作成し、APIキーを渡す
  end

  def set_directions_service
    api_key = ENV['GOOGLE_API_KEY'] #環境変数からGoogle Places APIキーを取得
    @directions_service = GoogleDirectionsService.new(api_key) #GoogleDirectionsServiceクラスのインスタンスを作成し、APIキーを渡す
  end

  def set_navitime_route_service
    api_key = ENV['Rapid_API_KEY'] # 環境変数からNAVITIME APIキーを取得
    @navitime_route_service = NavitimeRouteService.new(api_key) # NavitimeRouteServiceクラスのインスタンスを作成し、APIキーを渡す
  end

  def convert_duration_to_minutes(duration_text)
    #〜時間〜分を整数に変換する(90という形にする)
    hours = duration_text.scan(/(\d+)\s*hour/).flatten.first.to_i
    #1時間30分を1 30分という形にする(時間をなくす)
    minutes = duration_text.scan(/(\d+)\s*min/).flatten.first.to_i
    #1時間30分を1時間30という形にする(分をなくす)
    total_minutes = hours * 60 + minutes
    #1 30 という形になっているので1に60をかけ(時間を分に直す)30に足す = 90
    total_minutes
    #計算された合計
  end
  
end