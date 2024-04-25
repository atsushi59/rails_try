# frozen_string_literal: true

# SearchHandlingモジュールは、検索処理とそれに関連するセッション管理の機能を提供します。
# このモジュールは、SomeControllerや他のコントローラで再利用可能なメソッドを含んでおり、
# ユーザー入力の処理、メッセージの生成、レスポンスのハンドリングなどを担当します。
# 各メソッドは特定の機能を独立して担当し、コントローラのコードをすっきりと保つことを助けます。
module SearchHandling
  extend ActiveSupport::Concern

  included do
    helper_method :generate_user_input, :generate_messages, :handle_response, :setup_session
  end

  def setup_session
    params.each do |key, value|
      session[key] = value if %w[selected_transport address selected_time
                                 selected_activity].include?(key) && value.present?
    end
    # paramsに[selected_transport address selected_time selected_activity]の値があるか確認しあればセッションに保存
  end

  def generate_user_input
    base = "#{params[:address]}から#{params[:selected_transport]}で"
    condition = "#{params[:selected_time]}以内で#{params[:selected_age]}"
    activity = "の子供が対象の#{params[:selected_activity]}"
    request = 'できる場所を正式名称で2件提示してください'
    [base, condition, activity, request].join
  end

  def generate_messages(user_input)
    [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: user_input }
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
    message_content = @result['choices'].first['message']['content']
    places = message_content.split("\n").select { |line| line.match(/^\d+\./) }
    @answer = places.join("\n")
    session[:query] = @answer
  end

  def process_error_response(response)
    @error_message = "Error: #{response.parsed_response['error']['message']}"
  end
end
