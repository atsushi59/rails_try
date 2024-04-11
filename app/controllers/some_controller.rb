class SomeController < ApplicationController
  def search
    api_key = ENV['OPENAI_API_KEY']
    chatgpt_service = ChatgptService.new(api_key)

    selected_transport = params[:selected_transport]
    selected_time = params[:selected_time]
    selected_age = params[:selected_age]
    selected_activity = params[:selected_activity]
    address = params[:address]
    
    user_input = "#{address}から#{selected_transport}で#{selected_time}以内で#{selected_age}歳の子供が#{selected_activity}できる場所を正式名称のみ10件提示してください"
    
      messages=[
        { role: 'system', content: 'You are a helpful assistant.' },
        { role: 'user', content: user_input }
      ]
    
    response = chatgpt_service.create_chat_completion(messages)
    
    if response.success?
      @result = response.parsed_response
      message_content = @result['choices'].first['message']['content']
      
      # コンテンツを改行で分割し、リストの要素のみを取得します
      places = message_content.split("\n").select { |line| line.match(/^\d+\./) }
      @answer = places.join("\n")
    else
      @error_message = "Error: #{response.parsed_response['error']['message']}"
    end
  end
end