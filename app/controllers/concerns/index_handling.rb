# frozen_string_literal: true

# IndexHandlingモジュールは、Google Places APIを使用して検索クエリの結果を処理し、詳細を取得します。
# このモジュールは、取得した場所の名称、アドレス、営業時間、ウェブサイト、および所要時間をユーザーに表示します。
# 取得した場所のデータはPlaceモデルに保存され、所要時間がユーザーが指定した時間内であれば結果として表示されます。
# セッションを使用してユーザーの選択した条件（時間など）を保存し、それに基づいて表示する情報をフィルタリングします。
module IndexHandling
  extend ActiveSupport::Concern

  def process_queries(queries)
    @places_details = []

    queries.each do |query|
      response = @google_places_service.search_places(query)
      if response['candidates'].any?
        process_candidate(response['candidates'].first)
      else
        @places_details.push({ 'name' => query, 'error' => 'No results found' })
      end
    end
  end

  private

  def process_candidate(candidate)
    place_detail = get_place_details(candidate['place_id'])
    process_place_detail(place_detail)
  end

  def get_place_details(place_id)
    details_response = @google_places_service.get_place_details(place_id)
    details_response['result']
  end

  def process_place_detail(place_detail)
    opening_hours = format_opening_hours(place_detail)
    photo_reference = fetch_photo_reference(place_detail)
    save_place_details(place_detail, opening_hours, photo_reference)
    travel_time_minutes = calculate_travel_time(place_detail)
    add_place_to_results(place_detail, travel_time_minutes, opening_hours, photo_reference)
  end

  def format_opening_hours(place_detail)
    if place_detail['opening_hours']
      place_detail['opening_hours']['weekday_text'][Time.zone.today.wday.zero? ? 6 : Time.zone.today.wday - 1]
    else
      '営業時間の情報はありません。'
    end
  end

  def fetch_photo_reference(place_detail)
    return unless place_detail['photos']

    @google_places_service.get_photo(place_detail['photos'].first['photo_reference'])
  end

  def save_place_details(place_detail, opening_hours, photo_reference)
    Place.find_or_create_by(name: place_detail['name'], address: place_detail['formatted_address']) do |place|
      place.website = place_detail['website']
      place.opening_hours = opening_hours
      place.photo_url = photo_reference
      place.selected_activity = session[:selected_activity]
    end
  end

  def add_place_to_results(place_detail, travel_time_minutes, opening_hours, photo_reference)
    travel_time_minutes = travel_time_minutes.to_i

    if travel_time_minutes && travel_time_minutes <= session[:selected_time].to_i
      @places_details.push(place_detail.merge('today_opening_hours' => opening_hours,
                                              'photo_url' => photo_reference))
    else
      @places_details.push({ 'name' => place_detail['name'], 'error' => 'No results found' })
    end
  end
end
