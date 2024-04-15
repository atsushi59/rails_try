class SomeController < ApplicationController
  before_action :set_google_places_service

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
    
    user_input = "#{address}から#{selected_transport}で#{selected_time}以内で#{selected_age}歳の子供が#{selected_activity}できる場所を正式名称のみ10件提示してください"
    
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
      redirect_to index_path
      

    else
      @error_message = "Error: #{response.parsed_response['error']['message']}"
    end
  end

  def index
    # セッションからクエリリストを取得して配列に変換
    queries = session[:query].to_s.split("\n").map { |q| q.split('. ').last.strip }
    @places_details = []
  
    # 各クエリに対して検索を行い、結果を配列に保存
    queries.each do |query|
      response = @google_places_service.search_places(query)
      if response["candidates"].any?
        first_result = response["candidates"].first
        place_id = first_result["place_id"]
        details_response = @google_places_service.get_place_details(place_id)
        place_detail = details_response["result"]
  
        # 営業時間と写真のURLを取得
        opening_hours = place_detail['opening_hours'] ? place_detail['opening_hours']['weekday_text'][Time.zone.today.wday.zero? ? 6 : Time.zone.today.wday - 1] : "営業時間の情報はありません。"
        photo_reference = place_detail['photos'] ? @google_places_service.get_photo(place_detail['photos'].first['photo_reference']) : nil

        Place.create(
        name: place_detail['name'],
        address: place_detail['formatted_address'],
        website: place_detail['website'],
        opening_hours: opening_hours,
        photo_url: photo_reference
      )
  
        # 取得した詳細情報を配列に追加
        @places_details.push(place_detail.merge("today_opening_hours" => opening_hours, "photo_url" => photo_reference))
      else
        @places_details.push({ "name" => query, "error" => "No results found" })
      end
    end
  end
  
  
  private

  def set_google_places_service
    api_key = ENV['GOOGLE_API_KEY'] #環境変数からGoogle Places APIキーを取得
    @google_places_service = GooglePlacesService.new(api_key) #GooglePlacesServiceクラスのインスタンスを作成し、APIキーを渡す
  end
end