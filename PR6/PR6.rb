# Створіть лямбду sum3 = ->(a,b,c){ a+b+c } і продемонструйте власну функцію curry3(proc_or_lambda), що дозволяє часткове застосування по одному аргументу. 
# Вимоги: підтримка викликів типу curry3(sum3).call(1).call(2).call(3) та curry3(sum3).call(1,2).call(3).

# -----
# cur = curry3(sum3)

# cur.call(1).call(2).call(3)     #=> 6
# cur.call(1, 2).call(3)          #=> 6
# cur.call(1).call(2, 3)          #=> 6
# cur.call()                      #=> повертає callable, що чекає 3 аргументи
# cur.call(1, 2, 3)               #=> 6
# cur.call(1, 2, 3, 4)            #=> ArgumentError (забагато)

# f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
# cF = curry3(f)
# cF.call('A').call('B', 'C')     #=> "A-B-C"

#-------------------------------------------------------------------------------------------------
# лямбда на 3 аргументи
sum3 = ->(a, b, c) { a + b + c } #лямбда, яка приймає рівно 3 аргументи a, b, c і повертає їх суму.

def curry3(proc_or_lambda)
  raise ArgumentError, "очікувався callable" unless proc_or_lambda.respond_to?(:call)

  builder = nil
  builder = ->(collected) {
    ->(*args) { #повертаємо внутрішню лямбду, що приймає довільну кількість аргументів args при кожному .call(...).
      all = collected + args
      raise ArgumentError, "забагато" if all.length > 3
      if all.length == 3
        proc_or_lambda.call(*all)
      else
        builder.call(all)  # повертаємо новий callable, що чекає решту аргументів
      end
    }
  }

  builder.call([])
end

# ---- приклади з умови----
cur = curry3(sum3)

p cur.call(1).call(2).call(3)      #=> 6
p cur.call(1, 2).call(3)           #=> 6
p cur.call(1).call(2, 3)           #=> 6
p cur.call()                       #=> #<Proc:...> (callable, що чекає 3 аргументи)
p cur.call(1, 2, 3)                #=> 6
begin
  cur.call(1, 2, 3, 4)             #=> ArgumentError (забагато)
rescue ArgumentError => e
  puts e.message
end

f  = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
p cF.call('A').call('B', 'C')      #=> "A-B-C"
