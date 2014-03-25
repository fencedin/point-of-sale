require 'active_record'
require 'pry'

require './lib/product'

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def welcome
  puts "***Welcome to the Place Of Sweets of 1990 for our sweet products.***\n\n"
  main
end

def main
  puts "======= MAIN MENU ========"
  choice = nil
  until choice == 'x'
    puts "Press 'p' for product menu"
    # puts "      'l' to list all products"
    # puts "      'd' to mark a task as done."
    puts "      'x' to exit."
    choice = gets.chomp
    case choice
    when 'p'
      clear
      product_menu
    # when 'l'
    #   list_products
    when 'x'
      clear
      puts "\nGood-bye!\n\n"
      exit
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
  clear
  puts "'#{new_p.name}' was added with the super low price of #{new_p.price}!"
end

def list_products
  clear
  puts "Here are all products in our inventory"
  puts " ===================================="
  Product.all.each {|product| puts "  #{product.name}: $#{product.price}"}
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
