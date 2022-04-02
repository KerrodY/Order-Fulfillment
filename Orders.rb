#!/usr/bin/ruby

require 'json'

class Orders

    def processOrders()
        json_data = get_data(ARGV[0])


    end

    # Get data from external JSON file
    # ASSUMPTION: Any JSON file can be passed, not just the provided `data.json`
    def get_data(arg)
        if File.extname(arg) == '.json'
            file = File.read(arg) 
            data = JSON.parse(file)
            puts data
        else
            raise 'Please check file type: JSON files only'
        end
    end

end

# Call and run program
run = Orders.new
run.processOrders