=begin
  This routine used to solve the recruitment problem.
  Evironment: Ubuntu10.10/x86 with ruby 1.8.7.
  2011.05.03 v0.0.1 created by Ruijian Cao 
  2011.05.03 v0.0.2 modified input way by Ruijian Cao
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
  
  def self.parse(item_str, type=nil)
    result=item_str.match(/^(\d+)\s+(.*)\s+at\s+(\d+\.\d+)\s*/)
    raise "Invalid input #{item_str}" if result.size<3
    base_tr=['books', "food", "medical products"].member?(type.to_s) ? 0 : 1
    name=result[2]
    import_tr=name.to_s.include?('imported') ? 1 : 0
    new(result[1].to_i, result[2], result[3].to_f, base_tr, import_tr)
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
        
  def load_item(item_str, type)
    i=LineItem.parse(item_str, type)
    items<<i
    self.total_tax+=i.taxed_part
    self.total_price+=i.total
    self
  end
  
  def load_items(items_str)
    raise "Invalid items!" if items_str.nil?
    items1=items_str.split("\n")
    items1.each do |i|
      i1=i.split(",")
      load_item(i1[0].to_s.strip, i1[1].to_s.strip)
    end
    self
  end
  
  def output
    items.each{|i| i.taxed_item}
    puts "Sales Taxes: #{disp_dollar(total_tax)}"
    puts "Total: #{disp_dollar(total_price)}"
  end  
  
end

class App  
  def self.run    
    input1=<<-INPUT1
      1 book at 12.49, books
      1 music CD at 14.99
      1 chocolate bar at 0.85, food
    INPUT1
    puts "Output1:"
    Order.new.load_items(input1).output
    
    input2=<<-INPUT2
      1 imported box of chocolateds at 10.00, food
      1 imported bottle of perfume at 47.50
    INPUT2
    puts "\nOutput2"
    Order.new.load_items(input2).output

    input3=<<-INPUT3
      1 imported bottle of perfume at 27.99
      1 bottle of perfume at 18.99
      1 packet of headache pills at 9.75, medical products
      1 box of imported chocolates at 11.25, food
    INPUT3
    puts "\nOutput3"    
    Order.new.load_items(input3).output
  end
end

#run this only when invoking this file standalone!
App.run if __FILE__ == $0
