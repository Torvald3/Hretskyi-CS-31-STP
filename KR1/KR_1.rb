# 1) bag.rb
# Колекція Bag з Enumerable: each + size, а також median і frequencies.

class Bag
  include Enumerable

def initialize(items = []) 
    @items = items.dup
  end

  def <<(x)                    
    @items << x                
    self                       
  end

  def each(&b)                 
    @items.each(&b) 
  end

  def size
    @items.size                
  end


  def frequencies
    grouped = group_by { |v| v }

    pairs = grouped.map do |k, arr|
      [k, arr.size]
    end

    pairs.to_h
  end

  def median
    return nil if @items.empty?

    s   = @items.sort
    len = s.length
    mid = len / 2

    if len.odd?
      s[mid]
    else
      (s[mid - 1] + s[mid]) / 2.0
    end
  end
end

# Приклад:
bag = Bag.new([3,1,2,2,5])
bag.size              #=> 5
bag.frequencies       #=> {3=>1, 1=>1, 2=>2, 5=>1}
bag.median            #=> 2
bag.select { _1 > 2 } #=> [3,5]

puts "size: #{bag.size}"
p    bag.frequencies
puts "median: #{bag.median}"
p    bag.select { |x| x > 2 }   