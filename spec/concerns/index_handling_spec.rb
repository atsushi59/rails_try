# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexHandling, type: :module do
  #モジュールに対するテストの定義
  let(:dummy_class) do
    Class.new do
      include IndexHandling
      attr_accessor :google_places_service
      #IndexHandlingを含む一時的なクラス定義 
      #このダミークラスにattr_accessor :google_places_serviceを追加することで、インスタンス変数@google_places_serviceへのゲッターとセッターを自動的に提供
    end
  end
  let(:instance) { dummy_class.new }
  let(:google_places_service) { instance_double("GooglePlacesService") }

  before do
    instance.google_places_service = google_places_service
  end

  describe "#process_queries" do
    it "クエリ結果が見つからない場合、エラーメッセージが含まれること" do
      allow(google_places_service).to receive(:search_places).and_return({ "candidates" => [] })
      #search_placesメソッドで空の候補を返された場合
      instance.process_queries(["公園"])
      expect(instance.instance_variable_get(:@places_details)).to include({ "name" => "公園",
                                                                            "error" => "No results found" })
    end

    it "クエリ結果が見つかる場合、候補が正しく処理されること" do
      candidate = { "place_id" => "123" }
      allow(google_places_service).to receive(:search_places).and_return({ "candidates" => [candidate] })
      #search_placesメソッドでcandidateというリストを返すように設定(candidate = 123)
      expect(instance).to receive(:process_candidate).with(candidate)
      instance.process_queries(["公園"])
    end
  end
end
