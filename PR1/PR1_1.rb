# Л/B
# Завдання:

# Користувач вводить рядок тексту.

# Напишіть метод word_stats(text) який:

# підрахує кількість слів

# знайде найдовше слово

# підрахує кількість унікальних слів (без урахування регістру)

# Приклад:

# text = "Ruby is fun and ruby is powerful"
# # → 7 слів, найдовше: powerful, унікальних: 5

# ----------------------------------------------------START------------------------------------------------------------
# ruby .\PR1\PR1_1.rb
# ----------------------------------------------------START------------------------------------------------------------
def word_stats(text)
  puts
  puts "U entered : \n#{text}"
  words = Array.new(text.split(' '))
  i = 0
  longest = words[i]

  # words counter and longest word finder
  while words.length > i
    # puts words[i]
    if words[i].length > longest.length
      longest = words[i]
    end
    i += 1
  end

  #uniqueness check
  unique = 0
  i = 0
  seen = true

  while words.length > i

    j = 0
    seen = false

    while j < i
      if words[j].downcase == words[i].downcase
        seen = true
        break
      end
      j += 1
    end

    if seen == false
      unique += 1
    end

    i+=1
  end

  puts ("Words count: " + words.length.to_s + " words ")
  puts "Longest word: #{longest}"
  puts ("Number of unique words: " + unique.to_s)
  puts
end

print "Enter ur message: \n"
text = gets 
word_stats(text)

