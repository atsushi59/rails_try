# frozen_string_literal: true

# deirections APIを使用し車のルートの時間を取得
# NAVITIME APIを使用し徒歩こみの公共交通機関のルートの時間を取得
# 取得した時間をユーザーが選択した時間と比較するので形を修正
module CalculateTravelTimeHandling
  extend ActiveSupport::Concern

  def calculate_travel_time(origin, destination, transport_mode)
    case transport_mode
    when '車'
      calculate_travel_time_by_car(origin, destination)
    when '公共交通機関'
      calculate_travel_time_by_public_transport(origin, destination)
    else
      '所要時間の情報は利用できません。'
    end
  end

  private

  def calculate_travel_time_by_car(origin, destination)
    response = @directions_service.get_directions(origin, destination, Time.now.to_i)
    return '所要時間の情報は利用できません。' unless response.success? && response.parsed_response['routes'].any?

    duration_text = response.parsed_response['routes'].first['legs'].first['duration']['text']
    convert_duration_to_minutes(duration_text)
  end

  def calculate_travel_time_by_public_transport(origin, destination)
    formatted_origin = @navitime_route_service.geocode_address(origin)
    formatted_destination = @navitime_route_service.geocode_address(destination)
    time_now_adjusted = (Time.now.utc + 9.hours).strftime('%Y-%m-%dT%H:%M:%S')
    response = @navitime_route_service.get_directions(formatted_origin, formatted_destination, time_now_adjusted)
    extract_time_from_response(response)
  end

  def convert_duration_to_minutes(duration_text)
    hours = duration_text.scan(/(\d+)\s*hour/).flatten.first.to_i
    minutes = duration_text.scan(/(\d+)\s*min/).flatten.first.to_i
    hours * 60 + minutes
  end

  def extract_time_from_response(response)
    return '所要時間の情報は利用できません。' unless response.success? && response.parsed_response['items'].any?

    response['items'].first['summary']['move']['time']
  end
end
