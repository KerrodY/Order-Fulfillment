#!/usr/bin/ruby

require 'json'

class Orders

  # Call method used to parse sample data `data.json` and pass only order ids as required
  def call
    json_data = get_json_data(ARGV[0])
    order_ids = json_data['orders'].map { |order| order['orderId'] }
    processOrders!(order_ids)
  end

  # Process orders by their order id
  def processOrders!(order_ids)
    # Used to log if products have already been reordered, to prevent additional reorders
    on_reorder = []

    # ASSUMPTION: this data would already exist somewhere, I've used the `data.json` to simulate it for this scenario.
    products_and_orders = get_json_data(ARGV[0])
    products = products_and_orders['products']
    orders = products_and_orders['orders']

    # ASSUMPTION: All Order Ids will have corresponding orders and products in the system.
    order_ids.each { |id|
      current_order = orders.detect { |order| order['orderId'] == id }
      if is_fillable?(products, current_order)
        current_order['items'].each { |item|
          item_to_update = products.detect { |product| product['productId'] == item['productId'] }
          item_to_update['quantityOnHand'] = item_to_update['quantityOnHand'] - item['quantity']
        }
        current_order['status'] = 'Fulfilled'
        puts "Order #{current_order['orderId']} has been fulfilled"
        check_for_reorder(products, current_order, on_reorder)
      else
        check_for_reorder(products, current_order, on_reorder)
        current_order['status'] = 'Unfillable'
      end
    }
    # ASSUMPTION: This should return ALL potential orders which are unfilled, not just the current orders
    unfillable_orders = orders.map { |order| order['orderId'] if order['status'] == 'Unfillable' }.compact
    puts "Unfillable Order Ids: #{unfillable_orders}"
  end

  # Checks if the order can be filled
  def is_fillable?(products, order)
    order['items'].each { |item|
      item_to_update = products.detect { |product| product['productId'] == item['productId'] }
      return false if item_to_update['quantityOnHand'] - item['quantity'] < 0 }
    true
  end

  # STUB method to imitate a re-order
  # Checks if any of the products in the current order need to be reorder,
  # and if so, places a reorder
  def check_for_reorder(products, order, on_reorder)
    order['items'].each { |item|
      prod = products.detect { |product| product['productId'] == item['productId'] }
      if prod['quantityOnHand'] <= prod['reorderThreshold'] && on_reorder.none?(prod)
        puts "Refill: Ordered #{prod['reorderAmount']} stock for product: #{prod['productId']}. Lead time is #{prod['deliveryLeadTime']} days"
        on_reorder << prod
      end
    }
  end

  # Get data from external JSON file
  # ASSUMPTION: Any JSON file could be passed containing Orders, not just the provided `data.json`
  def get_json_data(arg)
    if File.extname(arg) == '.json'
      file = File.read(arg)
      JSON.parse(file)
    else
      raise 'Please check file and type: JSON files only'
    end
  end

end

# Call and run program
run = Orders.new
run.call