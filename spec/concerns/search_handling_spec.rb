# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchHandling, type: :module do
  # ダミーのクラスを定義してモジュールをインクルードする
  let(:dummy_class) do
    #モジュールをテストするためのダミークラス
    Class.new do
      include SearchHandling
      attr_accessor :params, :session
      #テスト対象のモジュールがHTTPリクエストのパラメータやセッションを扱うことができるように、paramsとsession属性をダミークラスに追加
      def initialize
        @session = {}
      end
    end
  end

  let(:dummy_instance) { dummy_class.new }
  #ダミーインスタンスの生成

  before do
    # ActionController::Parametersを使って、実際のコントローラと同じようにパラメータを扱う
    dummy_instance.params = ActionController::Parameters.new({
      selected_transport: "車",
      address: "東京駅",
      selected_time: "30分",
      selected_activity: "公園",
      selected_age: "幼児"
    })
  end

  describe "#setup_session" do
    it "有効なパラメータをセッションに保存する" do
      dummy_instance.setup_session
      expect(dummy_instance.session['selected_transport']).to eq("車") 
    end
  end

  describe "#generate_user_input" do
    it "ユーザー入力から適切なリクエスト文字列を生成する" do
      expected_string = "東京駅から車で30分以内で幼児の子供が対象の公園できる場所を正式名称で2件提示してください"
      expect(dummy_instance.generate_user_input).to eq(expected_string)
    end
  end

  describe "#handle_response" do
    context "エラー応答の場合" do
      let(:error_response) do
        instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => { "message" => "アクセス拒否" } })
      end

      it "エラーメッセージを適切に処理する" do
        error_response = instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => { "message" => "アクセス拒否" } })
        allow(dummy_instance).to receive(:process_error_response).and_call_original # process_error_response メソッドを呼び出す準備
        dummy_instance.handle_response(error_response) # handle_response メソッドを直接呼び出し
        expect(dummy_instance.instance_variable_get(:@error_message)).to eq("Error: アクセス拒否")
      end
    end
  end
end
