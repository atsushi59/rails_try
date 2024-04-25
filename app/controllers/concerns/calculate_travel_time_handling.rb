# frozen_string_literal: true

# deirections APIを使用し車のルートの時間を取得
# NAVITIME APIを使用し徒歩こみの公共交通機関のルートの時間を取得
# 取得した時間をユーザーが選択した時間と比較するので形を修正
module CalculateTravelTimeHandling
  extend ActiveSupport::Concern

  def calculate_travel_time_by_car(origin, destination)
    response = @directions_service.get_directions(origin, destination, Time.now.to_i)
    #@directions_service.get_directionsアクションでルート検索
    return '所要時間の情報は利用できません。' unless response.success? && response.parsed_response['routes'].any?
    duration_text = response.parsed_response['routes'].first['legs'].first['duration']['text']
    #response.parsed_response['routes']で取得した一番最初の['legs']の中の['duration']['text']を取得(ルートの時間)
    convert_duration_to_minutes(duration_text)
    # convert_duration_to_minutesを使用しルートの時間を1 hours 30 minsから90に変更(privateに定義)(比較する際に90という形に合わせる為)
  end

  def calculate_travel_time_by_public_transport(origin, destination)
    formatted_origin = @navitime_route_service.geocode_address(origin)
    # 指定された住所を@navitime_route_service.geocode_addressを用いて緯度経度に変換
    formatted_destination = @navitime_route_service.geocode_address(destination)
    time_now_adjusted = (Time.now.utc + 9.hours).strftime('%Y-%m-%dT%H:%M:%S')
    # 現在のUTC時間から9時間加えて日本の標準時に調整
    response = @navitime_route_service.get_directions(formatted_origin, formatted_destination, time_now_adjusted)
    # @navitime_route_serviceで定義したget_directionsを使用しstartからgoalまでを現在の時間からルート検索する
    extract_time_from_response(response)
  end

  def convert_duration_to_minutes(duration_text)
    # 〜時間〜分を整数に変換する(90という形にする)
    hours = duration_text.scan(/(\d+)\s*hour/).flatten.first.to_i
    # 1時間30分を1 30分という形にする(時間をなくす)
    minutes = duration_text.scan(/(\d+)\s*min/).flatten.first.to_i
    # 1時間30分を1時間30という形にする(分をなくす)
    hours * 60 + minutes
    # 1 30 という形になっているので1に60をかけ(時間を分に直す)30に足す = 90
  end

  def extract_time_from_response(response)
    return '所要時間の情報は利用できません。' unless response.success? && response.parsed_response['items'].any?

    response['items'].first['summary']['move']['time']
    # response.parsed_response['items']で取得した一番最初の['summary']['move']['time']を取得(ルートの時間)
  end
end
