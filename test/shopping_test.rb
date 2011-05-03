require 'test/unit'
require 'app/shopping'

def compare_floats(f1, f2)
  #convert to integer comparison to avoid float comparison rounding errors
  (f1*100).round==(f2*100).round
end

class TestOrder < Test::Unit::TestCase
  
  def test_round_up_half
    assert compare_floats(5.40, round_up_half(5.40))
    assert compare_floats(5.45, round_up_half(5.44))
    assert compare_floats(5.50, round_up_half(5.47))
  end
  
  def test_base_rate
    o=Order.new.add_item(1, 'book', 12.49, 0, 0)\
               .add_item(1, 'music CD', 14.99, 1, 0)\
               .add_item(1, 'chocolate bar', 0.85, 0, 0)
    assert compare_floats(12.49, o.items[0].total)
    assert compare_floats(16.49, o.items[1].total)
    assert compare_floats(0.85, o.items[2].total)
    assert compare_floats(1.50, o.total_tax)
    assert compare_floats(29.83, o.total_price)
  end
  
  def test_import_rate
    o=Order.new.add_item(1, 'imported box of chocolateds', 10.00, 0, 1)\
               .add_item(1, 'imported bottle of perfume', 47.50, 1, 1)
    assert compare_floats(10.50, o.items[0].total)
    assert compare_floats(54.65, o.items[1].total)
    assert compare_floats(7.65, o.total_tax)    
    assert compare_floats(65.15, o.total_price)
  end
  
  def test_hybrid_rate
    o=Order.new.add_item(1, 'imported bottle of perfume', 27.99, 1, 1)\
               .add_item(1, 'bottle of perfume', 18.99, 1, 0)\
               .add_item(1, 'packet of headache pills', 9.75, 0, 0)\
               .add_item(1, 'box of imported chocolates', 11.25, 0, 1)
    assert compare_floats(o.items[0].total, 32.19)
    assert compare_floats(o.items[1].total, 20.89)
    assert compare_floats(o.items[2].total, 9.75)
    assert compare_floats(o.items[3].total, 11.85)
    assert compare_floats(o.total_tax, 6.70)
    assert compare_floats(o.total_price, 74.68)
  end
end