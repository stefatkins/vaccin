require 'net/http'
require 'json'
require 'date'
require 'whirly'

def get_availabilities(url:)
  Net::HTTP.get_response(URI.parse(url))
end

def notify(title:, message:)
  system("osascript -e \'display notification \"#{message}\" with title \"#{title}\"\'")
end

def notify_appointment_available(start_date:, slot:)
  notify(
    title: 'Rendez vous disponible',
    message: "Un rendez-vous pour le vaccin est disponible le #{start_date} à #{slot}"
  )
  system("say 'Un rendez-vous est disponible le #{start_date} à #{slot}'")
end

print "URL doctolib : "
url = gets

Whirly.start spinner: "clock", color: true, status: "Recherche une disponibilité pour le vaccin" do
  loop do
    res = get_availabilities(url:  url)
    if res
      availabilities = JSON.parse(res.body)["availabilities"]
      availabilities.each do |availability|
        if availability["slots"].size > 0
          start_at = availability["slots"][0]["start_date"] || availability["slots"][0]
          parsed_datetime = DateTime.parse(start_at)
          slot_date = parsed_datetime.strftime('%d/%m/%Y')
          slot_time = parsed_datetime.strftime('%H:%M')
          notify_appointment_available(start_date: slot_date, slot: slot_time)
          return
        end
      end
    end
    sleep 2
    rescue URI::InvalidURIError
      puts "URL invalide"
      return
  end
end
