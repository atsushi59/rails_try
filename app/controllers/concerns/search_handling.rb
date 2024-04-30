# frozen_string_literal: true

# SearchHandlingモジュールは、検索処理とそれに関連するセッション管理の機能を提供します。
# このモジュールは、SomeControllerや他のコントローラで再利用可能なメソッドを含んでおり、
# ユーザー入力の処理、メッセージの生成、レスポンスのハンドリングなどを担当します。
# 各メソッドは特定の機能を独立して担当し、コントローラのコードをすっきりと保つことを助けます。
module SearchHandling
  extend ActiveSupport::Concern

  def setup_session
    params.each do |key, value|
      if %w[selected_transport address selected_time selected_activity].include?(key) && value.present?
        session[key] = value 
      end
    # paramsに[selected_transport address selected_time selected_activity]の値があるか確認しあればセッションに保存
    end
  end

  def generate_user_input
    base = "#{params[:address]}から#{params[:selected_transport]}で"
    condition = "#{params[:selected_time]}以内で#{params[:selected_age]}"
    activity = "の子供が対象の#{params[:selected_activity]}"
    request = "できる場所を正式名称で2件提示してください"
    [base, condition, activity, request].join
  end

  def generate_messages(user_input)
    [
      { role: "system", content: "You are a helpful assistant." },
      # roleはsystemであり、ChatGPTの動作モードや役割に関する指示を提供
      { role: "user", content: user_input }
      # roleはsystemであり、ChatGPTの動作モードや役割に関する指示を提供
    ]
  end

  def handle_response(response)
    if response.success?
      process_successful_response(response)
      redirect_to index_path
    else
      process_error_response(response)
    end
  end

  private

  def process_successful_response(response)
    @result = response.parsed_response
    # response.parsed_response: 応答の内容を解析し、@result変数に格納
    message_content = @result["choices"].first["message"]["content"]
    # 最初の選択肢(choices)のメッセージ内容を取得してmessage_contentに代入します。これは、ChatGPTが生成したテキスト内容
    places = message_content.split("\n").select { |line| line.match(/^\d+\./) }
    # 取得したメッセージ内容を改行文字(\n)で分割し、各行を配列の要素として扱います
    # その後、行の始めが数字で始まるもの（例：1. Place Name）を選択し、そのようなパターンに一致する行のみをplaces配列に格納
    @answer = places.join("\n")
    # places配列の要素を改行で結合して@answerに代入
    session[:query] = @answer
    # sessionでサーバーに一時的に保存
  end

  def process_error_response(response)
    @error_message = "Error: #{response.parsed_response['error']['message']}"
  end
end
