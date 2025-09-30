# Написати програму на рубі, яка приймає на вхід 
# "пиріг з родзинками" 
# cake = 
# ........ 
# ..o..... 
# ...o.... 
# ........ 
# // o це родзинки 
# Нам потрібно рівно розрізати пиріг на n маленьких 
# прямокутних шматочків так, щоб у кожному маленькому 
# пирізі була 1 родзинка. n не є 
# аргументом, ця кількість родзинок усередині торта 
# cake = 
# ........ 
# ..o..... 
# ...o.... 
# ........
# Результат ось такий масив 
# [ 
# ........ 
# ..o..... 
# , 
# ...o.... 
# ........ 
# ] 
# Кількість родзинок завжди більше 1 та менше 10. 
# Якщо рішень кілька, виберіть те, що має найбільшу 
# ширину першого елемента масиву. Поступово розрізати 
# на n частин, що означає однакову площу. Але їхня форма 
# може бути різною. Кожен шматок торта має бути прямокутним.
# ----------------------------------------------------------------------------------------------------------------------------------------

def cut_cake(cake_str)
  lines = cake_str.strip.split("\n") # strip from spaces. split by \n
  rows  = lines.size #size of rows
  cols  = lines.first.size #size only of first col(assume that all cols are the same)
  raisins = []
  lines.each_with_index do |row, r| # |string(row), int(r)|
    #transform row to array<String>
    #=> ch - String(1 character), int(c - index of a column)
    row.chars.each_with_index { |ch, c| raisins << [r, c] if ch == 'o' } #if 'o' add array of [r,c](coord) to the end of raisins
                                                                         #([[0,1],[0,3],[2,4],[4,5]])
    # << is like concatination???
  end
  n = raisins.size
  raise "Must have 2..9 raisins" unless (2..9).include?(n) #include? - checks if in diapason 
  # SAME AS:
  # if !(2..9).include?(n)
  #   raise "Must have 2..9 raisins"
  # end

  total = rows * cols
  raise "Impossible: total area #{total} is not divisible by #{n}" unless total % n == 0
  area = total / n

  # All (h, w) with h*w = area
  dims = [] #dimensions
  (1..area).each do |h|
    next unless area % h == 0
    w = area / h
    dims << [h, w]
  end

  # Candidates for every raisin: [r0, c0, h, w]
  # rects_for=> {
  #   [rr, cc] => [ [r0, c0, h, w], [r0, c0, h, w], ... ],
  #   [rr, cc] => [ ... ],
  #   ...
  # }
  rects_for = {}
  raisins.each do |(rr, cc)| #coordinates of raisin [r,c]
    candidates = []
    dims.each do |h, w|
      # Перебираємо всі можливі top-left так, щоб (rr,cc) всередині
      r0_min = [0, rr - (h - 1)].max
      r0_max = [rr, rows - h].min
      c0_min = [0, cc - (w - 1)].max
      c0_max = [cc, cols - w].min
      (r0_min..r0_max).each do |r0|
        (c0_min..c0_max).each do |c0|
          # Check if there only one raisin
          cnt = 0
          other = false
          #check block cells
          (r0...(r0 + h)).each do |r| #exclude!
            (c0...(c0 + w)).each do |c| #exclude!
              if lines[r][c] == 'o'
                cnt += 1
                other = other || (r != rr || c != cc)
                break if cnt > 1
              end
            end
            break if cnt > 1
          end
          next unless cnt == 1 && !other
          candidates << [r0, c0, h, w]
        end
      end
    end
    rects_for[[rr, cc]] = candidates
  end

  # sorting top-bottom, left-right
  raisins.sort!

  used = Array.new(rows) { Array.new(cols, false) } # boolean array
  answer = []

  # For first raisin prioritize width(by exercise demand), then - sort without priority
  # def sort_candidates(rects, prioritize_width: false)
  #   if prioritize_width
  #     rects.sort_by { |r0, c0, h, w| [-w, r0, c0, h] } # first key w, so prioritizes sorting first of all bu width. -w reverses defauls ascending to descending
  #   else
  #     rects.sort_by { |r0, c0, h, w| [r0, c0, h, w] }
  #   end
  # end

  # For first raisin prioritize width(by exercise demand), then - sort without priority
  sort_candidates = ->(rects, prioritize_width: false) do
    if prioritize_width
      rects.sort_by { |r0, c0, h, w| [-w, r0, c0, h] } # first key w, so prioritizes sorting first of all bu width. -w reverses defauls ascending to descending
    else
      rects.sort_by { |r0, c0, h, w| [ r0, c0, h, w] }
    end
  end

  mark = lambda do |r0, c0, h, w, val|
    (r0...(r0 + h)).each do |r|
      (c0...(c0 + w)).each do |c| #going through every row, through every column 
        used[r][c] = val # to declare value on place
      end
    end
  end

  can_place = lambda do |r0, c0, h, w| #can place value on array?
    (r0...(r0 + h)).each do |r|
      (c0...(c0 + w)).each do |c|
        return false if used[r][c]
      end
    end
    true
  end

  solved = false
  best_solution = nil

  # backtrack
  rec = nil
  rec = lambda do |idx, chosen| #idx - index of sorted raisins; chosen - one of [r0, c0, h, w]
    if idx == raisins.length # checked every raisin
    
      best_solution = chosen.dup #makes copy of chose array
      solved = true
      return best_solution
    end

    rr, cc = raisins[idx]
    cand = rects_for[[rr, cc]]
    return nil if cand.empty?

    cand = sort_candidates.call(cand, prioritize_width: idx == 0)

    cand.each do |r0, c0, h, w|
      next unless can_place.call(r0, c0, h, w)
      mark.call(r0, c0, h, w, true)
      chosen << [r0, c0, h, w]
      res = rec.call(idx + 1, chosen)
      return res if res 
      chosen.pop
      mark.call(r0, c0, h, w, false)
    end
    nil
  end

  res = rec.call(0, []) # starting backtrack
  return [] unless res

  # output top-bottom, left-right
  res.sort_by! { |r0, c0, h, w| [r0, c0] }
  pieces = res.map do |r0, c0, h, w|
    lines[r0...(r0 + h)]
      .map { |ln| ln[c0...(c0 + w)] }
      .join("\n")
  end
  pieces
end



# ====================================================CODE START=========================================================================
# --- Приклад ---

# cake = <<~CAKE
#   ........ 
#   ..o..... 
#   ...o.... 
#   ........
# CAKE

# cake = <<~CAKE
#   .....oo. 
#   ...o.... 
#   o..o.... 
#   ...o....
# CAKE

cake = <<~CAKE
  .o.o....
  ........
  ....o...
  ........
  .....o..
  ........
CAKE

result = cut_cake(cake)
puts "["
puts result.map { |s| "  #{s.gsub("\n", "\n  ")}" }.join("\n,\n") # add two spaces in front of the piece; inside the piece, replace every newline \n with \n  
puts "]"

# ruby .\PR2\PR2_1.rb 