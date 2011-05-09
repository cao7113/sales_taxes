=begin
  This routine used to solve the recruitment problem.
  Evironment: Ubuntu10.10/x86 with ruby 1.8.7.
  2011.05.09 refactor from shopping.rb for more Object-Oriented and
             easy to extend by Ruijian Cao. Main modification as follows:
             1. more abstract and OO, class hierarchy:
               Item (mix in Taxable(mix in BaseTax, ImportTax)
                 --can detail to Book, Chocolate
                 LineItem
               Order(include more line items)
             2 easy to extend, e.g. add a HeavyTax, just do:
               moudle HeavyTax
                 def heavytax
                   #implement me
                 end
               end
               and mix it into Taxable
             
=end

#=============Utility Functions
#display "0.10 not 0.1"
def disp_dollar(d)
  "%.2f" % d
end

#rounding rule: rounded up to the nearest 0.05, as 54.625-->54.65
def round_up_half(d)
  lp=d*1000%100
  if lp>50
    #0.10
    ((d*10).to_i*10+10)/100.0
  elsif lp>0
    #0.05
    ((d*10).to_i*10+5)/100.0
  else
    #0.00
    (d*100).to_i/100.0
  end
end

#===========Taxable module
module BaseTax
  #TODO maintain by hand?
  FREE_LIST=["book", "chocolate bar", "chocolateds", "chocolates", "headache pills"]
  BASE_RATE=10.0/100
  
  def base?
    FREE_LIST.each do |l|
      return 0 if name.include?(l)
    end
    1
  end
  
  def basetax
    BASE_RATE*price*base?
  end
end

module ImportTax
  IMPORT_KEYS=["imported"]
  IMPORT_RATE=5.0/100
  
  def import?
    IMPORT_KEYS.each do |k|
      return 1 if name.include?(k)
    end
    0
  end
  
  def importtax
    IMPORT_RATE*price*import?
  end
end

module Taxable
  
  include BaseTax
  include ImportTax
  
  def self.included(clazz)
    #TODO check preconditions such as name, price method
  end
  
  #caculate tax part using reflection
  def tax_part    
    taxes=self.class.included_modules.map(&:name).select{|n| n=~/.+Tax/}
    _tax=0.0
    taxes.each do |t|
      #?Where's the camlize method? FIXME
      tax_name=t.downcase
      tax_delta=send(tax_name)
      _tax+=tax_delta
    end
    round_up_half(_tax)
  end
  
  def tax_price
    price+tax_part
  end
  
  def tax_item
    puts "#{name} #{price} #{disp_dollar(tax_price)} "
  end
end

#===========Business Logic
class Item
  attr_accessor :name, :price
  
  include Taxable
  
  def initialize(name, price)
    self.name, self.price=name, price    
  end
end
#as subclass of Item, you can define detail items such as book, chocolate bar here


#one item in shopping basket
class LineItem<Item  
  
  def initialize(amount, name, price)
    super(name, price)
    @amount=amount
  end
  
  #1 book at 12.49
  def self.parse(item_str)    
    result=item_str.to_s.match(/^\s*(\d+)\s+(.*)\s+at\s+(\d+\.\d+)\s*/)
    raise "Invalid input [#{item_str}]" if result.nil? or result.size<3
    new(result[1].to_i, result[2], result[3].to_f)
  end
  
  def total_price
    tax_price*@amount
  end
  
  def line_item
    puts "#{@amount} #{name}(#{price}): #{disp_dollar(total_price)}"
  end
  
end

#receipt details for these shopping baskets
class Order
  attr_accessor :items, :total_tax, :total_price
  
  def initialize
    self.items, self.total_tax, self.total_price=[], 0, 0    
  end
  
  def load_item(item_str)
    i=LineItem.parse(item_str)
    items<<i
    self.total_tax+=i.tax_part
    self.total_price+=i.total_price
  end
  
  def load_items(items_str)
    raise "Invalid items!" if items_str.nil?
    items_str.split("\n").each{ |i|  load_item(i) }
    self
  end
  
  def output
    items.each{|i| i.line_item}
    puts "Sales Taxes: #{disp_dollar(total_tax)}"
    puts "Total: #{disp_dollar(total_price)}"
  end  
  
end

class App  
  def self.run    
    input1=<<-INPUT1
      1 book at 12.49
      1 music CD at 14.99
      1 chocolate bar at 0.85
    INPUT1
    puts "Output1:"
    Order.new.load_items(input1).output
    
    input2=<<-INPUT2
      1 imported box of chocolateds at 10.00
      1 imported bottle of perfume at 47.50
    INPUT2
    puts "\nOutput2"
    Order.new.load_items(input2).output

    input3=<<-INPUT3
      1 imported bottle of perfume at 27.99
      1 bottle of perfume at 18.99
      1 packet of headache pills at 9.75
      1 box of imported chocolates at 11.25
    INPUT3
    puts "\nOutput3"    
    Order.new.load_items(input3).output
  end
end

#run this only when invoking this file standalone!
App.run if __FILE__ == $0
