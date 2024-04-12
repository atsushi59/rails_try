require 'httparty'

class ChatgptService
  include HTTParty
  base_uri 'https://api.openai.com/v1'
  #全てのリクエストとなるベースのURL

  def initialize(api_key)
    @api_key = ENV['OPEN_AI_API_KEY']
    #OpenAIのAPIキーを環境変数から取得しインスタンス変数@api_keyに設定
  end

  def create_chat_completion(messages)
    #チャットセッションを生成するためのメソッド
    options = {
      headers: {
        'Content-Type' => 'application/json',
        #Content-Typeとしてapplication/json
        'Authorization' => "Bearer #{@api_key}"
        #AuthorizationとしてBearerトークン形式でAPIキーを設定
      },
      body: {
        model: "gpt-4-turbo-preview",
        #使用するGPTのモデルの記載
        messages: messages
      }.to_json
    }

    self.class.post('/chat/completions', options)
    #HTTPartyによるPOSTリクエストを実行し、OpenAIのAPIエンドポイント/chat/completionsに対してリクエストを送信
  end
end