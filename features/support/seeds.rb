puts "Loading seeds ..."
model_new_string = nil
headers = nil
File.open(File.dirname(__FILE__) + '/seeds.txt') do |file|
  while line = file.gets
    line.strip!
    if line.empty?
      model_new_string = nil
      headers = nil
    elsif (r = line.match(/^Model: (.+)$/))
      if eval("#{r[1]}.count") == 0
        model_new_string = "#{r[1]}.new"
        puts model_new_string
      end
    else
      next unless model_new_string
      unless headers
        headers = line.split('|').map{|txt| txt.strip }
      else
        model = eval(model_new_string)
        datas = line.split('|').map{|txt| txt.strip }
        datas.each_with_index do |d, col|
          model.send(headers[col] + '=', d.empty? ? nil : d)
        end
        model.save!
      end
    end
  end
end
