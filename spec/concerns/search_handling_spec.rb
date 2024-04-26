# frozen_string_literal: true

require "rails_helper"

RSpec.describe SomeController, type: :controller do
  controller do
    include SearchHandling
  end

  before do
    routes.draw do
      post "handle_response" => "some#setup_session"
      get "index" => "some#index"
    end
  end

  describe "#setup_session" do
    it "有効なパラメータをセッションに保存する" do
      post :setup_session,
           params: { selected_transport: "バス", address: "東京駅", selected_time: "30分", selected_activity: "公園",
                     selected_age: "幼児" }
      expect(session[:selected_transport]).to eq("バス")
    end
  end

  let(:valid_params) do
    { address: "東京駅", selected_transport: "バス", selected_time: "30分", selected_activity: "公園", selected_age: "幼児" }
  end

  describe "#generate_user_input" do
    it "ユーザー入力から適切なリクエスト文字列を生成する" do
      controller.params = valid_params # 正しいパラメータの定義を使用する
      expected_string = "東京駅からバスで30分以内で幼児の子供が対象の公園できる場所を正式名称で2件提示してください"
      expect(controller.generate_user_input).to eq(expected_string)
    end
  end

  describe "#handle_response" do
    context "エラー応答の場合" do
      let(:error_response) do
        instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => { "message" => "アクセス拒否" } })
      end

      it "エラーメッセージを適切に処理する" do
        allow(controller).to receive(:process_error_response).and_call_original # process_error_response メソッドを呼び出す準備
        controller.handle_response(error_response) # handle_response メソッドを直接呼び出し
        expect(controller.instance_variable_get(:@error_message)).to eq("Error: アクセス拒否")
      end
    end
  end
end
