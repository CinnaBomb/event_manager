require 'csv'
require 'sunlight/congress'
require 'erb'
require 'time'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_phone_numbers(number)
	number.gsub!(/^\d/,'')
	if number.length == 10
		return number
	elsif number.length == 11 and number[0]==1
		return number[1..number.length]
	end
	return ""
end

def format_time (date_time)
	date_time = DateTime.strptime(date_time, "%m/%d/%Y %H:%M")
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  #My Solution
  reg_time = format_time(row[:regdate])
  hours << reg_time.hour
  days << reg_time.wday
#End of My Solution

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end


frequent_hour = hours.max_by{|i| hours.count(i)}
frequent_hour = Time.parse("#{frequent_hour}:00").strftime("%l %p")
frequent_day = days.max_by{|i| days.count(i)}
puts "Most frequent registration hour is #{frequent_hour}"
puts "Most frequent registration day of the week is #{Date::DAYNAMES[frequent_day]}"