require "faraday"
require "json"

class OwmSdk::Client
  class Error < StandardError; end

  BASE_URL = "https://api.openweathermap.org/data/2.5".freeze

  def initialize(api_key:, base: BASE_URL, conn: nil, timeout: 5)
    @api_key = api_key
    @base = base
    @timeout = timeout
    @conn = conn || build_conn
  end

  def fetch(city_id)
    res = @conn.get("forecast", { id: city_id, appid: @api_key, units: "metric" })

    handle_errors(res)
    handle_response(res)
  end

  private

  def handle_response(response)
    data = parse_json(response.body)

    {
      city: data["city"]["name"],
      current: current_temp(data),
      daily_average: daily_forecasts(data)
    }
  end

  def current_temp(data)
    current = data["list"].first

    {
      temp: current["main"]["temp"],
      description: current["weather"].first["description"],
      date: current["dt_txt"]
    }
  end

  def daily_forecasts(data)
    grouped = data["list"].group_by { |item| item["dt_txt"][0..9] }

    grouped.transform_values do |forecasts|
      temps = forecasts.map { |f| f["main"]["temp"] }
      (temps.sum / temps.size.to_f).round(2)
    end
  end

  def handle_errors(response)
    return if response.success?

    data = parse_json(response.body)
    message = data["message"] || "Unknown Error"
    raise Error, message
  end

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    {}
  end

  def build_conn
    @conn = Faraday.new(url: @base) do |builder|
      builder.options.timeout = @timeout
      builder.adapter Faraday.default_adapter
    end
  end
end
