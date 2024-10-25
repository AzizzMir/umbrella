require "http"
require "json"
require "dotenv/load"
require "active_support/all"

class Umbrella

  def initialize
    @user_location = ""
  end

  def run
    puts "
  ========================================
      Will you need an umbrella today?    
  ========================================
    \n"
    puts "Where are you located?"
    @user_location = gets.chomp.capitalize
    puts "Cheking the weather at #{@user_location}...."
    puts "Your coordinates are #{get_location}."
    puts "it is currently #{get_temperature}°F."
    puts "Next hour: #{get_summary}."
    check_prep



  end


  private
  # Get the user’s latitude and longitude from the Google Maps API.
  def get_location
    gmaps_key = ENV.fetch("GMAPS_KEY")
    location_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{gmaps_key}"
    raw_location = HTTP.get(location_url)
    parsed_location = JSON.parse(raw_location)
    results = parsed_location.fetch("results")
    string_1 = results.at(0)
    geometry = string_1.fetch("geometry")
    location = geometry.fetch("location")
    latitude = location.fetch("lat")
    longitude = location.fetch("lng")

    return "#{latitude},#{longitude}"
  end

  # Display the current temperature and summary of the weather for the next hour.
  def get_temperature
    pirate_key = ENV.fetch("PIRATE_WEATHER_KEY")
    weather_url = "https://api.pirateweather.net/forecast/#{pirate_key}/#{get_location}"
    raw_weather = HTTP.get(weather_url)
    parsed_weather = JSON.parse(raw_weather)
    currently = parsed_weather.fetch("currently")
    temperature = currently.fetch("temperature")

    return temperature
  end

  def get_summary
    pirate_key = ENV.fetch("PIRATE_WEATHER_KEY")
    weather_url = "https://api.pirateweather.net/forecast/#{pirate_key}/#{get_location}"
    raw_weather = HTTP.get(weather_url)
    parsed_weather = JSON.parse(raw_weather)
    hourly = parsed_weather.fetch("hourly")
    summary = hourly.fetch("summary")

    return summary
  end

  def check_prep
    pirate_key = ENV.fetch("PIRATE_WEATHER_KEY")
    weather_url = "https://api.pirateweather.net/forecast/#{pirate_key}/#{get_location}"
    raw_weather = HTTP.get(weather_url)
    parsed_weather = JSON.parse(raw_weather)
    hourly = parsed_weather.fetch("hourly")
    data = hourly.fetch("data")
    twelve_hours_data = data[1..12]
    any_precipitation = false
    
    twelve_hours_data.each do |hour|
      precip_prob = hour.fetch("precipProbability")

      if precip_prob > 0.10
        any_precipitation = true

        precip_time = Time.at(hour.fetch("time"))

        seconds_from_now = precip_time - Time.now

        hours_from_now = seconds_from_now / 60 / 60

        puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
      end
    end
    if any_precipitation == true
      puts "You might want to carry an umbrella!"
    else
      puts "You probably won’t need an umbrella today."
    end
  end
end
