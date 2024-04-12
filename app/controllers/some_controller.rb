class SomeController < ApplicationController
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
    else
      @error_message = "Error: #{response.parsed_response['error']['message']}"
    end
  end
end