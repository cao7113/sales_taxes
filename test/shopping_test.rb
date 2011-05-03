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
    o=Order.new.load_items(<<-INPUT1
                            1 book at 12.49, books
                            1 music CD at 14.99
                            1 chocolate bar at 0.85, food
                          INPUT1
                          )
    assert compare_floats(12.49, o.items[0].total)
    assert compare_floats(16.49, o.items[1].total)
    assert compare_floats(0.85, o.items[2].total)
    assert compare_floats(1.50, o.total_tax)
    assert compare_floats(29.83, o.total_price)
  end
  
  def test_import_rate
    o=Order.new.load_items(<<-INPUT2
                              1 imported box of chocolateds at 10.00, food
                              1 imported bottle of perfume at 47.50
                            INPUT2
                           )
    assert compare_floats(10.50, o.items[0].total)
    assert compare_floats(54.65, o.items[1].total)
    assert compare_floats(7.65, o.total_tax)    
    assert compare_floats(65.15, o.total_price)
  end
  
  def test_hybrid_rate
    o=Order.new.load_items(<<-INPUT3
                              1 imported bottle of perfume at 27.99
                              1 bottle of perfume at 18.99
                              1 packet of headache pills at 9.75, medical products
                              1 box of imported chocolates at 11.25, food
                            INPUT3
                          )
    assert compare_floats(32.19, o.items[0].total)
    assert compare_floats(20.89, o.items[1].total)
    assert compare_floats(9.75, o.items[2].total)
    assert compare_floats(11.85, o.items[3].total)
    assert compare_floats(6.70, o.total_tax)
    assert compare_floats(74.68, o.total_price)
  end
end