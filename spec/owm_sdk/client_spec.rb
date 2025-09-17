require "spec_helper"
require "owm_sdk/client"

RSpec.describe OwmSdk::Client do
  let(:client) { described_class.new(api_key: "XYZ123") }
  let(:base) { "api.openweathermap.org/" }
  let(:city_id) { 12_345 }

  it "return current forecast" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(query: hash_including("id" => city_id.to_s, "appid" => "XYZ123"))
      .to_return(
        status: 200,
        body: {
          list: [
            {
              dt: 1_758_121_200,
              main: { temp: 20.52 },
              weather: [
                { description: "nuvens dispersas" }
              ],
              dt_txt: "2025-09-17 15:00:00"
            },
            {
              dt: 1_758_132_000,
              main: { temp: 21.97 },
              weather: [
                { description: "algumas nuvens" }
              ],
              dt_txt: "2025-09-18 15:00:00"
            }
          ],
          city: { name: "City" }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    res = client.fetch(city_id)

    expect(res[:city]).to eq("City")
    expect(res[:current][:temp]).to eq(20.52)
    expect(res[:current][:description]).to eq("nuvens dispersas")
    expect(res[:current][:date]).to eq("2025-09-17 15:00:00")
    expect(res[:daily_average]).to eq({ "2025-09-17" => 20.52, "2025-09-18" => 21.97 })
  end

  it "raises an error when api response status 401" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(query: hash_including("id" => city_id.to_s, "appid" => "XYZ123"))
      .to_return(
        status: 401,
        body: { "cod" => 401, "message" => "Invalid API key" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    expect { client.fetch(city_id) }.to raise_error(OwmSdk::Client::Error, /Invalid API key/)
  end

  it "raises an error when api response 404" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(query: hash_including("id" => city_id.to_s, "appid" => "XYZ123"))
      .to_return(
        status: 404,
        body: { "cod" => 404, "message" => "city not found" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    expect { client.fetch(city_id) }.to raise_error(OwmSdk::Client::Error, /city not found/)
  end

  it "raises an error when api response 50x" do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast")
      .with(query: hash_including("id" => city_id.to_s, "appid" => "XYZ123"))
      .to_return(
        status: 500,
        body: { "cod" => 500, "message" => "internal server error" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    expect { client.fetch(city_id) }.to raise_error(OwmSdk::Client::Error, /internal server error/)
  end
end
