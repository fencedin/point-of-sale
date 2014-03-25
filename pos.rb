require 'active_record'
require 'pry'

require './lib/product'
require './lib/cashier'
require './lib/transaction'
require './lib/inventory'

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def welcome
  puts "***Welcome to the Place Of Sweets of 1990 for our sweet products.***\n\n"
  puts "Press 'm' to go to store menu"
  puts "      'e' for employee login"
  puts "      'x' to exit"
  case gets.chomp
  when 'm'
    clear
    main
  when 'e'
    clear
    employee_log_in
  when 'x'
    clear
    puts "\nGood-bye!\n\n"
    exit
  else
    clear
    error
    welcome
  end
end

def main
  puts "======= MAIN MENU ========"
  #list inventory
#list tranactions - sold items

  choice = nil
  until choice == 'x'
    puts "Press 'p' for product menu"
    puts "      'c' for cashier menu"
    # puts "      'd' to mark a task as done."
    puts "      'w' to got back to welcome menu."
    choice = gets.chomp
    case choice
    when 'p'
      clear
      product_menu
    when 'c'
      clear
      cashier_menu
    when 'w'
      clear
      welcome
    else
      error
    end
  end
end

# ~~~~PRODUCT~~~~

def product_menu
  puts "======= PRODUCT MENU ========"
    choice = nil
  until choice == 'm'
    puts "Press 'a' to add a product"
    puts "      'l' to list all products"
    puts "      'e' to edit product"
    puts "      'd' to delete product"
    puts "      'q' to update quantity"
    puts "      'm' to go back to main menu"
    choice = gets.chomp
    case choice
    when 'a'
      add_product
    when 'l'
      list_products
    when 'e'
      edit_product
    when 'd'
      delete_product
    when 'q'
      edit_product_qty
    when 'm'
      clear
      main
    else
      error
    end
  end
end

def add_product
  puts "Enter product name:"
  p_name = gets.chomp
  puts "\nEnter price:"
  p_price = gets.chomp.to_f
  new_p = Product.create({name: p_name, price: p_price})
  puts "How many of #{p_name} do we have in stock"
  qty = gets.chomp.to_i

  qty.times do
    Inventory.create({product_id: new_p.id, in_stock: true})
  end

  clear
  puts "'#{new_p.name}' was added with the super low price of #{new_p.price}!"
end

def list_products
  clear
  puts "Here are all products in our inventory"
  puts " ===================================="
  Product.all.each do |product|

    if product.inventories.where({in_stock: true}).count != 0
      puts "  #{product.name}: $#{product.price} qty: #{product.inventories.where({in_stock: true}).count}"
    else
      puts "  #{product.name}: $#{product.price} qty: sold out!"
    end
  end
    puts " ===================================="
end

def edit_product
  list_products
  puts "Select product name you would like to edit"
  p_name = gets.chomp
  puts "Enter new product name or hit enter to keep the current name"
  new_name = gets.chomp
  puts "Enter new price or hit enter to keep the current price"
  new_price = gets.chomp
  product = Product.where({name: p_name}).first
  if new_name == ""
    if new_price == ""
      clear
      puts "Nothing gets changed!!!!!"
    else
      product.update({price: new_price.to_f})
      clear
      puts "#{product.name} has been updated with the new price of $#{product.price}\n\n"
    end
  elsif new_name != "" && new_price != ""
    product.update({name: new_name, price: new_price.to_f})
    clear
    puts "#{p_name} has been changed to #{product.name} and has been updated with the new price of $#{product.price}\n\n"
  elsif new_name != "" && new_price == ""
    product.update({name: new_name})
    clear
    puts "#{p_name} has been updated with the new name of #{product.name}\n\n"
  else
    clear
    error
  end
end

def edit_product_qty
  list_products
  puts "Select product you would like to update quantity of"
  p_name = gets.chomp
  puts "Enter quantity"
  p_qty = gets.chomp.to_i
  p_id = Product.where(name: p_name).first.id

  current_qty = Inventory.where({product_id: p_id, in_stock: true}).count

  if current_qty < p_qty
    (p_qty - current_qty).times do
      Inventory.create({product_id: p_id, in_stock: true})
    end

  elsif current_qty > p_qty
    (current_qty - p_qty).times do
      found_product = Inventory.where({product_id: p_id, in_stock: true}).first
      found_product.update({in_stock: false})
    end

  else
    puts "Nothing got changed!"
  end
end

def delete_product
  list_products
  puts "Select product by name you would like to delete"
  p_name = gets.chomp

  if product = Product.where({name: p_name}).first
    product.destroy
    clear
    puts "#{p_name} was not popular enough ٩(͡๏̯͡๏)۶\n\n"
  else
    clear
    error
  end
end

# ~~~~CASHIER~~~~

def cashier_menu
  puts "======= CASHIER MENU ========"
    choice = nil
  until choice == 'm'
    puts "Press 'a' to add a cashier"
    puts "      'l' to list all cashiers"
    puts "      'e' to edit cashier"
    puts "      'd' to delete cashier"
    puts "      'm' to go back to main menu"
    choice = gets.chomp
    case choice
    when 'a'
      add_cashier
    when 'l'
      list_cashiers
    when 'e'
      edit_cashier
    when 'd'
      delete_cashier
    when 'm'
      clear
      main
    else
      error
    end
  end
end

def add_cashier
  puts "Enter cashier name:"
  c_name = gets.chomp
  puts "\nEnter Password:"
  c_password = gets.chomp
  new_c = Cashier.create({name: c_name, password: c_password})
  clear
  puts "'#{new_c.name}' was added with the super cool password of #{new_c.password}!"
end

def list_cashiers
  clear
  puts "Here are all cashiers in the store"
  puts " ===================================="
  Cashier.all.each {|cashier| puts "  #{cashier.name} pw: #{cashier.password}"}
  puts " ===================================="
end

def edit_cashier
  list_cashiers
  puts "Select cashier name you would like to edit"
  c_name = gets.chomp
  puts "Enter new cashier name or hit enter to keep the current name"
  new_name = gets.chomp
  puts "Enter new password or hit enter to keep the current password"
  new_password = gets.chomp
  cashier = Cashier.where({name: c_name}).first
  if new_name == ""
    if new_password == ""
      clear
      puts "Nothing gets changed!!!!!"
    else
      cashier.update({password: new_password})
      clear
      puts "#{cashier.name} has been updated with the new password of #{cashier.password}\n\n"
    end
  elsif new_name != "" && new_password != ""
    cashier.update({name: new_name, password: new_password})
    clear
    puts "#{c_name} has been changed to #{cashier.name} and has been updated with the new password of #{cashier.password}\n\n"
  elsif new_name != "" && new_password == ""
    cashier.update({name: new_name})
    clear
    puts "#{c_name} has been updated with the new name of #{cashier.name}\n\n"
  else
    clear
    error
  end
end

def delete_cashier
  list_cashiers
  puts "Select cashier by name you would like to delete"
  c_name = gets.chomp

  if cashier = Cashier.where({name: c_name}).first
    cashier.destroy
    clear
    puts "#{c_name} was fired ٩(͡๏̯͡๏)۶\n\n"
  else
    clear
    error
  end
end

#~~~~SALES~~~~~~~

def employee_log_in
  puts "Who are you?"
  name = gets.chomp
  puts "Password?"
  password = gets.chomp
  if Cashier.where({name: name, password: password}).first
    @cashier_id = Cashier.where({name: name, password: password}).first.id
    sales
  else
    clear
    error
    welcome
  end
end

def sales
  choice = nil
  until choice == 'w'
    puts " Press 'a' to add new transaction"
    puts "       'w' to go back to main menu"

    case gets.chomp
    when 'a'
      list_products
      puts "Enter item being sold"
      p_name = gets.chomp
      puts "Enter quantity"
      qty = gets.chomp.to_i
      p_id = Product.where({name: p_name}).first.id

      if Inventory.where({product_id: p_id, in_stock: true}).count >= qty
        qty.times do
          Transaction.create({product_id: p_id, cashier_id: @cashier_id})

          found_product = Inventory.where({product_id: p_id, in_stock: true}).first
          found_product.update({in_stock: false})
        end
        clear
        sales
      else
        clear
        puts "Sorry we dont have enough"
        error
      end

    when 'w'
      clear
      welcome
    else
      clear
      error
      sales
    end
  end

end


# ~~~~OTHER~~~~

def clear
  system "clear && printf '\e[3j'"
end

def error
  clear
  puts "\e[5;31m(╯°□°）╯︵ ┻━┻"
  puts "Error!!!!\e[0;0m\n\n"
end

clear
welcome
