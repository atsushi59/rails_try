class SomeController < ApplicationController
  before_action :set_google_places_service
  before_action :set_directions_service

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
    session[:address] = address if address.present?
    session[:selected_transport] = params[:selected_transport]
    #selected_transportで選択された(車,電車)パラメータをサーバー側のセッションに保存
    #後にviews/indexで使用
    
    user_input = "現在地#{address}から移動手段は#{selected_transport}で#{selected_time}以内で目的地に到着する場所のみ提示してください。年齢は#{selected_age}歳の子供が対象で#{selected_activity}できる場所を正式名称のみ10件提示してください"
    
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
  
    # 各クエリに対して検索を行い、結果を配列に保存
    queries.each do |query|
      response = @google_places_service.search_places(query)
      if response["candidates"].any?
        #candidatesは検索クエリに基づいて見つかった場所の候補一覧を含む配列
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
        Place.create(
        name: place_detail['name'],
        address: place_detail['formatted_address'],
        website: place_detail['website'],
        opening_hours: 'opening_hours',
        photo_url: 'photo_reference'
      )

      travel_time = calculate_travel_time(place_detail)
  
        # 取得した詳細情報を配列に追加
        @places_details.push(place_detail.merge("today_opening_hours" => opening_hours, "photo_url" => photo_reference,  "travel_time" => travel_time))
        #"today_opening_hours" と "photo_url" という新しいキーに割り当てて、元の place_detail ハッシュにマージ
        #place_detailとtoday_opening_hours" と "photo_url"が検索結果として表示
      else
        @places_details.push({ "name" => query, "error" => "No results found" })
      end
    end
  end

  def calculate_travel_time(place_detail)
    origin = session[:address]
    destination = place_detail['formatted_address']
    travel_mode = determine_travel_mode(session[:selected_transport])
    current_time = DateTime.now.to_i  # 現在のUNIXタイムスタンプを取得
    response = @directions_service.get_directions(
      origin, 
      destination,
      current_time,
      travel_mode: travel_mode
    )

    if response.success? && response.parsed_response['routes'].any?
      response.parsed_response['routes'].first['legs'].first['duration']['text']
    else
      "所要時間の情報は利用できません。"
    end
  end

  def determine_travel_mode(transport_mode)
    case transport_mode
    when '車'
      'driving'
    when '電車'
      'transit'
    else
      'driving'
    end
  end
  
  private

  def set_google_places_service
    api_key = ENV['GOOGLE_API_KEY'] #環境変数からGoogle Places APIキーを取得
    @google_places_service = GooglePlacesService.new(api_key) #GooglePlacesServiceクラスのインスタンスを作成し、APIキーを渡す
  end

  def set_directions_service
    api_key = ENV['GOOGLE_API_KEY']
    @directions_service = GoogleDirectionsService.new(api_key)
  end
end