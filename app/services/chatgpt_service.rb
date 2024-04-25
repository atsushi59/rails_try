# frozen_string_literal: true

require 'httparty'

# This service class is responsible for sending messages to the GPT-4 API.
# It defines actions for interacting with the API, handling requests and processing responses.
class ChatgptService
  include HTTParty
  base_uri 'https://api.openai.com/v1'
  # 全てのリクエストとなるベースのURL

  def initialize(_api_key)
    @api_key = ENV['OPEN_AI_API_KEY']
    # OpenAIのAPIキーを環境変数から取得しインスタンス変数@api_keyに設定
  end

  def create_chat_completion(messages)
    options = build_request_options(messages)
    self.class.post('/chat/completions', options)
  end

  private

  # リクエストオプションを生成する新しいメソッド
  def build_request_options(messages)
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      },
      body: {
        model: 'gpt-4-turbo-preview',
        messages:
      }.to_json
    }
  end
end
