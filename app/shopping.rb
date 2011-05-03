=begin
  This routine used to solve the recruitment problem.
  Evironment: Ubuntu10.10/x86 with ruby 1.8.7.
  2011.05.03 v0.0.1 by Ruijian Cao 
=end

#display like "0.10 not 0.1"
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

#one item in shopping basket
class LineItem
  BASE_RATE=10.0/100
  IMPORT_RATE=5.0/100
  
  attr_accessor :amount, :name, :original, :basic_tr, :import_tr, :taxed_part
  
  def initialize(amount, name, original, basic_tr, import_tr)
    self.name, self.amount, self.original, self.basic_tr, self.import_tr=\
      name, amount, original, basic_tr, import_tr    
    self.taxed_part=round_up_half(original*(BASE_RATE*basic_tr+IMPORT_RATE*import_tr))
  end
    
  def total
    (original+taxed_part)*amount
  end
  
  def taxed_item
    puts "#{amount} #{name}: #{disp_dollar(total)}"
  end
  
end

#receipt details for these shopping baskets
class Order
  attr_accessor :items, :total_tax, :total_price
  
  def initialize
    self.items, self.total_tax, self.total_price=[], 0, 0    
  end
  
  def add_item(amount, name, original, basic_tr, import_tr)
    i=LineItem.new(amount, name, original, basic_tr, import_tr)
    items<<i
    self.total_tax+=i.taxed_part
    self.total_price+=i.total
    self
  end
  
  def output
    self.items.each{|i| i.taxed_item}
    puts "Sales Taxes: #{disp_dollar(total_tax)}"
    puts "Total: #{disp_dollar(total_price)}"
  end  
  
end

class App  
  def self.run
    #10% on all goods, except books, food, and medical products that are exempt.
    puts "Output1:"
    Order.new.add_item(1, 'book', 12.49, 0, 0)\
             .add_item(1, 'music CD', 14.99, 1, 0)\
             .add_item(1, 'chocolate bar', 0.85, 0, 0)\
         .output
    
    #all imported goods at a rate of 5%, with no exemptions.
    puts "\nOutput2"
    Order.new.add_item(1, 'imported box of chocolateds', 10.00, 0, 1)\
             .add_item(1, 'imported bottle of perfume', 47.50, 1, 1)\
         .output
         
    puts "\nOutput3"    
    Order.new.add_item(1, 'imported bottle of perfume', 27.99, 1, 1)\
             .add_item(1, 'bottle of perfume', 18.99, 1, 0)\
             .add_item(1, 'packet of headache pills', 9.75, 0, 0)\
             .add_item(1, 'box of imported chocolates', 11.25, 0, 1)\
         .output
  end
end

#run this only when invoking this file standalone!
App.run if __FILE__ == $0
