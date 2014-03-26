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
  puts "\e[34m***Welcome to the Place Of Sweets of 1990 for our sweet products.***\e[0m\n\n"
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
    puts "\e[32m\nGood-bye!\n\n\e[0m"
    exit
  else
    clear
    error
    welcome
  end
end

def main
  puts "\e[33m======= MAIN MENU ========\e[0m"
  choice = nil
  until choice == 'x'
    puts "Press 'p' for product menu"
    puts "      'c' for cashier menu"
    puts "      'd' for daily sales"
    puts "      'w' to got back to welcome menu."
    choice = gets.chomp
    case choice
    when 'p'
      clear
      product_menu
    when 'c'
      clear
      cashier_menu
    when 'd'
      daily_sales
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
  puts "\e[33m======= PRODUCT MENU ========\e[0m"
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
  puts "\e[32m'#{new_p.name}' was added with the super low price of #{new_p.price}!\e[0m"
end

def list_products
  clear
  puts "Here are all products in our inventory"
  puts " =============================================="
  puts " name                      price    qty"
  Product.all.each do |product|

    if product.inventories.where({in_stock: true}).count != 0
      puts "  #{product.name}:" + " "*(25-product.name.length) +
              "$#{product.price}" + " "*(8-product.price.to_s.length) +
              "#{product.inventories.where({in_stock: true}).count}"
    else
      puts "  #{product.name}:" + " "*(25-product.name.length) +
              "$#{product.price}" + " "*(8-product.price.to_s.length) +
              "\e[31msold out!\e[0m"
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
      puts "\e[32m#{product.name} has been updated with the new price of $#{product.price}\n\n\e[0m"
    end
  elsif new_name != "" && new_price != ""
    product.update({name: new_name, price: new_price.to_f})
    clear
    puts "\e[32m#{p_name} has been changed to #{product.name} and has been updated with the new price of $#{product.price}\n\n\e[0m"
  elsif new_name != "" && new_price == ""
    product.update({name: new_name})
    clear
    puts "\e[32m#{p_name} has been updated with the new name of #{product.name}\n\n\e[0m"
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
    clear
    puts "\e[32mQuantity updated to #{p_qty}\n\n\e[0m"
  elsif current_qty > p_qty
    (current_qty - p_qty).times do
      found_product = Inventory.where({product_id: p_id, in_stock: true}).first
      found_product.update({in_stock: false})
    end
    clear
    puts "\e[32mQuantity updated to #{p_qty}\n\n\e[0m"
  else
    clear
    puts "Nothing got changed!\n\n"
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
  puts "\e[33m======= CASHIER MENU ========\e[0m"
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
  puts "\e[32m'#{new_c.name}' was added with the super cool password of #{new_c.password}!\e[0m"
end

def list_cashiers
  clear
  puts "Here are all cashiers in the store"
  puts " ===================================="
  puts " name                pw"
  Cashier.all.each {|cashier| puts "  #{cashier.name}" + " "*(20-cashier.name.length) + "\e[2;37m#{cashier.password}\e[0m"}
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
      puts "\e[32m#{cashier.name} has been updated with the new password of #{cashier.password}\n\n\e[0m"
    end
  elsif new_name != "" && new_password != ""
    cashier.update({name: new_name, password: new_password})
    clear
    puts "\e[32m#{c_name} has been changed to #{cashier.name} and has been updated with the new password of #{cashier.password}\n\n\e[0m"
  elsif new_name != "" && new_password == ""
    cashier.update({name: new_name})
    clear
    puts "\e[32m#{c_name} has been updated with the new name of #{cashier.name}\n\n\e[0m"
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
    puts "\e[31m#{c_name} was fired ٩(͡๏̯͡๏)۶\n\e[0m"
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
    @cashier_name = Cashier.where({name: name, password: password}).first.name
    clear
    sales_menu
  else
    clear
    error
    welcome
  end
end

def sales_menu
  puts "\e[2;36m*You are logged in as #{@cashier_name}.\n\e[0;0m"
  puts "\e[33m============ New Sale ============\e[0m"
  puts "Press 's' to start a new transaction"
  puts "      'w' to go back to main menu"
  case gets.chomp
  when 's'
    clear
    one_sale
  when 'w'
    clear
    welcome
  else
    clear
    error
    sales_menu
  end
end


def one_sale
  choice = nil
  @total_sale = 0
  @cart = []
  until choice == 'e'
    puts "\e[2;36m*You are logged in as #{@cashier_name}.\n\e[0;0m"
    puts "==========================================="
    puts "Press 'a' to enter a new item"
    puts "      'e' to end transaction and get total"
    case gets.chomp
    when 'a'
      list_products
      puts "Enter item being sold"
      p_name = gets.chomp
      puts "Enter quantity"
      qty = gets.chomp.to_i
      if p_name != '' && qty != ''
        p = Product.where({name: p_name}).first
        if Inventory.where({product_id: p.id, in_stock: true}).count >= qty
          qty.times do
            Transaction.create({product_id: p.id, cashier_id: @cashier_id})
            @total_sale += p.price
            @cart << p
            found_product = Inventory.where({product_id: p.id, in_stock: true}).first
            found_product.update({in_stock: false})
          end
          clear
        else
          clear
          puts "Sorry we dont have enough"
          error
        end
      else
        clear
        error
      end
    when 'e'
      puts "\n\n\n========= Place Of Sweets ========="
      puts "Your cashier today was #{@cashier_name}"
      puts "==================================="
      @cart.each do |item|
        puts "  #{item.name}" + " "*(25-item.name.length) + "$#{'%.02f' % item.price}"
      end
      puts "==================================="
      puts "  Total is:                $#{'%.02f' % @total_sale}"
      puts "==================================="
      puts "\n\n\n(press enter to go back to sales menu)"
      gets.chomp
      clear
      sales_menu
    else
      clear
      error
      sales_menu
    end
  end

end

def daily_sales
  total_sales = 0
  puts "Enter date of purchase you would like to see the total sales in YYYY-MM-DD"
  date = gets.chomp
  puts "\n"
  Transaction.where(created_at: date.."#{date} 23:59:59").each do |sale|
    total_sales += sale.product.price
    puts "#{sale.product.name}" + " "*(25-sale.product.name.length) + "#{'%.02f' % sale.product.price}"
  end
  puts "==============================="
  puts "Total sales:           \e[32m$#{'%.02f' % total_sales}\e[0m\n\n"

end

# ~~~~OTHER~~~~

def clear
  system "clear && printf '\e[3j'"
end

def error
  clear
  puts "\n  \e[5;31m(╯°□°）╯︵ ┻━┻"
  puts "  Error!!!!\e[0;0m\n\n"
end

clear
welcome
