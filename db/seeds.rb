api_key = Rails.application.credentials.dig(:onwater_api_key)
rate_limit = 15
requests_in_batch = 0
last_reset = Time.now
center_point = { lat: 50.0515918, lng: 19.9357531 }

def check_coords_for_water(coords, api_key)
  payload = coords.map { |coord| "#{coord[:lat]},#{coord[:lng]}" }.to_json
  res = RestClient.post("https://api.onwater.io/api/v1/results?access_token=#{api_key}", payload, {content_type: :json, accept: :json})

  JSON.parse(res.body).each_with_index do |result, i|
    return coords[i] unless result['water']
  end
  nil
end

def sleep_with_progress(seconds)
  text = "Rate limit reached. Sleeping 😴🛌 for %d seconds...\r"
  print text % seconds
  1.upto(seconds) do |i|
    sleep(1)
    print text % (seconds - i)
  end
  $stdout.flush
end

1.upto(100) do |i|
  puts "Preparing Place #{i}..."
  coord = nil
  while coord.nil? do
    if requests_in_batch >= rate_limit
      diff = (Time.now - last_reset).to_i
      sleep_time = 60 - diff
      sleep_with_progress(sleep_time)
      requests_in_batch = 0
      last_reset = Time.now
    end

    coordinates = []
    1.upto(3) do |_|
      coordinates << {lng: center_point[:lng] + rand(-8.00..8.00), lat: center_point[:lat] + rand(-8.00..8.00)}
    end
    coord = check_coords_for_water(coordinates, api_key)
    requests_in_batch += 1
  end

  puts "Verified location for Place #{i}: #{coord}"

  Place.create!(
    name: Faker::Address.city,
    description: Faker::Lorem.paragraph(sentence_count: 8),
    longitude: coord[:lng],
    latitude: coord[:lat],
    price: rand(1..500)
  )
end