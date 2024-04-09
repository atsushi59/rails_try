class SomeController < ApplicationController
    def search
      api_key = ENV['OPENAI_API_KEY']
      chatgpt_service = ChatgptService.new(api_key)
  
      selected_transport = params[:selected_transport]
      selected_time = params[:selected_time]
      selected_age = params[:selected_age]
      selected_activity = params[:selected_activity]
      address = params[:address]
      
      user_input = "#{address}から#{selected_transport}で#{selected_time}以内で#{selected_age}歳の子供が#{selected_activity}できる場所を正式名称のみ10件提示してください 条件、立ち入りの許可が必要ない、公式のHPが存在する場所、公共の施設のみ"
      
      request_data = {
        model: "gpt-4-turbo-preview",
        messages: [
          { role: 'system', content: 'You are a helpful assistant.' },
          { role: 'user', content: user_input }
        ]
      }

     
      response = chatgpt_service.create_chat_completion(request_data)

      if response.success?
        @result = response.parsed_response
        @answer = @result['choices'].first['text']
      else
        @error_message = "Error: #{response.parsed_response['error']['message']}"
      end
    end
  end
