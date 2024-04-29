# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChatgptService, type: :service do
  let(:api_key) { "test_api_key" }
  #テスト用のAPIキーを定義
  let(:service) { described_class.new(api_key) }
  #ChatgptServiceクラスの新しいインスタンスを作成 api_keyがコンストラクタに渡され、認証に必要なキーとして機能
  let(:messages) { [{ role: "user", content: "Hello" }] }
  #テストで使用するメッセージの配列を定義

  before do
    #一連の事前設定
    ENV["OPEN_AI_API_KEY"] = api_key
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
    #WebMock gemを使用して外部APIへのPOSTリクエスト
      .with(
        headers: {
          "Authorization" => "Bearer #{api_key}",
          "Content-Type" => "application/json"
        },
        body: {
          model: "gpt-4-turbo-preview",
          messages: messages
        }.to_json
      )
      .to_return(status: 200, body: { choices: [{ message: { content: "Hello, how can I help you?" } }] }.to_json)
  end

  describe "APIキーを正しく取得できているか" do
    it "APIキーが環境変数から正しく設定されていること" do
      expect(service.instance_variable_get(:@api_key)).to eq(api_key)
      #instance_variable_getメソッド(インスタンス変数の値を取得)
    end
  end

  describe "正しいエンドポイントのアクセスしているか" do
    it "適切なエンドポイントにリクエストを送信していること" do
      service.create_chat_completion(messages)
      #create_chat_completionメソッドが正しいエンドポイントにリクエストできているかどうか
      expect(a_request(:post, "https://api.openai.com/v1/chat/completions")).to have_been_made.once
    end
  end

  describe "APIからのエラーが適切にハンドルされるか" do
    it "APIからのエラーレスポンスを適切に処理できること" do
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .to_return(status: 500, body: { error: "Internal Server Error" }.to_json)

      expect { service.create_chat_completion(messages) }
        .to_not raise_error
    end
  end
end
