#!/usr/bin/ruby

require 'json'

class Orders

    # Call method used to parse sample data `data.json` for demonstration purposes
    def call
        json_data = get_json_data(ARGV[0])
        processOrders!(json_data['orders'].map { |order| order['orderId'] })
    end

    def processOrders!(order_ids)
        
        # Logs if products have already been reordered, to prevent additional reorders
        on_reorder = []

        # ASSUMPTION: this data would already exist somewhere, I've used the `data.json` to simulate it for this scenario.
        products_and_orders = get_json_data(ARGV[0])
        products = products_and_orders['products']
        orders = products_and_orders['orders']
       
        order_ids.each { |id| 
            current_order = orders.detect { |order| order['orderId'] == id }
                if is_fillable?(products, current_order)
                    current_order['items'].each { |item| 
                        item_to_update = products.detect { |product| product['productId'] == item['productId'] }                
                        item_to_update['quantityOnHand'] = item_to_update['quantityOnHand'] - item['quantity']
                    }
                    current_order['status'] = 'Fulfilled'
                    puts "Order #{current_order['orderId']} has been fulfilled"
                    reorder(products, on_reorder) 
                else 
                    reorder(products, on_reorder)
                    current_order['status'] = 'Unfillable'
                    puts "Order #{current_order['orderId']} could not be fulfilled" 
                end
        }         
        puts "Products at the end of the code: #{products}"
        orders.each { |order| puts order }       
    end

    # Checks if the order can be filled
    def is_fillable?(products, order)
        order['items'].each { |item| 
            item_to_update = products.detect { |product| product['productId'] == item['productId'] }   
            return false if item_to_update['quantityOnHand'] - item['quantity'] < 0 }
        true
    end

    # Stub method to immitate a re-order
    # Checks if any of the products need to be reorder, and if so, places a reorder
    # TODO: Should I make this more efficient? Currently it's checks all products and wont scale well.
    def reorder(products, on_reorder)
        products.each { |product| 
            if product['quantityOnHand'] <= product['reorderThreshold'] && on_reorder.none?(product)
                puts "Refill: Ordered #{product['reorderAmount']} stock for product: #{product['productId']}. Lead time is #{product['deliveryLeadTime']} days"
                on_reorder << product
            end
        }
    end

    # Get data from external JSON file
    # ASSUMPTION: Any JSON file could be passed containg Orders, not just the provided `data.json`
    def get_json_data(arg)
        if File.extname(arg) == '.json'
            file = File.read(arg) 
            data = JSON.parse(file)  
        else
            raise 'Please check file and type: JSON files only'
        end
    end

end

# Call and run program
run = Orders.new
run.call