# frozen_string_literal: true

require "rails_helper"

RSpec.describe GoogleDirectionsService, type: :service do
  let(:api_key) { "test_api_key" } #テスト用のAPIキーを定義
  let(:service) { described_class.new(api_key) } #GoogleDirectionsServiceの新しいインスタンス作成
  let(:origin) { "Tokyo Station" } #テスト用の始点
  let(:destination) { "Yokohama Station" } ##テスト用の終点
  let(:departure_time) { "now" } #テスト用の時刻(現在時刻)
  #serviceインスタンスメソッドを使用し、指定したパラメータ（起点、終点、出発時間）をもとにルート検索のテストを行う準備

  describe "#get_directions" do
    it "適切なエンドポイントに適切なクエリパラメータでリクエストを送信していることを確認する" do
      stub_request(:get, "https://maps.googleapis.com/maps/api/directions/json")
      #WebMock gemを使用して外部APIへのPOSTリクエスト 正しくルートを取得できるか
        .with(query: {
                origin: origin,
                destination: destination,
                mode: "driving",
                departure_time: departure_time,
                key: api_key
              })
        .to_return(status: 200, body: { routes: [] }.to_json)

      response = service.get_directions(origin, destination, departure_time)

      expect(WebMock).to have_requested(:get, "https://maps.googleapis.com/maps/api/directions/json")
      #WebMockを使用して送信されたHTTPリクエストを検証 正しいエンドポイントにリクエストを送れるか
        .with(query: {
                origin: origin,
                destination: destination,
                mode: "driving",
                departure_time: departure_time,
                key: api_key
              })
      expect(response).to be_a(HTTParty::Response)
      #受け取ったレスポンスがHTTParty::Responseクラスのインスタンスであるか
      expect(response.parsed_response).to include("routes")
      #レスポンスがjson形式でroutesを含んでいるか
    end
  end
end
