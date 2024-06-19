#!C:\Ruby32-x64\bin\ruby.exe

# создание един. объекта подключения.
require 'mysql2'
client = Mysql2::Client.new(
	:host     => '127.0.0.1',
	:username => 'root',
	:password => '',
	:database => 'observatory_db',
	:encoding => 'utf8'
	)

# главная функция для показа строк, работает всегда.
def viewSelect(client)
	results = client.query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN('sector', 'events');")
	puts '<tr>'
	results.each do |row|
	  puts '<td>'+row['Field'].to_s+'</td>'
	end
	puts '</tr>'

	results = client.query("CALL joinTwoTables(sector, events)")
	results.each do |row|
	  puts '<tr><td>'+row['id'].to_s+'</td><td>'+row['type']+'</td><td>'+row['accuracy']+'</td><td>'+row['amount']+'</td><td>'+row['time'].to_s+'</td><td>'+row['date'].to_s+'</td><td>'+row['coordinates'].to_s+'</td><td>'+row['luminous_intensity'].to_s+'</td><td>'+row['foreign_objects']+'</td><td>'+row['sky_objects']+'</td><td>'+row['notes'].to_s+'</td></tr>'
	end
end

# подпись.
def viewVer(client)
	results = client.query("SELECT VERSION() AS ver")
	results.each do |row|
	  puts row['ver']
	end
end

# чтение шаблона и отображение на экране.
puts "Content-type: text/html\n\n"
File.readlines('select.html').each do |line|

	s = String.new(line)
	s.gsub!(/[^0-9A-Za-z @]/, '')

	if s != "@tr" && s != "@ver"
		puts(line)
	end
	if s == "@tr"
		viewSelect(client)
	end
	if s == "@ver"
		viewVer(client)
	end
end