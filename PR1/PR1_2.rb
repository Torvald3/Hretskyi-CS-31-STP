# ---------
# Гра: Вгадай число

# Умова:

# Комп'ютер загадує число від 1 до 100.

# Користувач вводить припущення.

# Програма підказує: «більше», «менше», або «вгадано» — поки не вгадає.

# Розширення:

# Рахуйте кількість спроб

# Додайте метод play_game для запуску гри

# ----------------------------------------------------START------------------------------------------------------------
# ruby .\PR1\PR1_2.rb
# ----------------------------------------------------START------------------------------------------------------------

def game
  puts "============================="
  win = false
  tries = 0
  secret_number = rand(1..100) #inclusive with two dots(1-100), non-inclusive three dots(1-99)
  while win == false
    puts "----------------"
    puts "Enter ur guess:"
    guess = gets.to_i
    if guess > secret_number
      puts "\nTry going lower"
      tries += 1
    elsif guess < secret_number
      puts "\nTry going higher"
      tries += 1
    elsif guess == secret_number 
      puts "\n\n\nCONGRATS, U GUESSED RIGHT!!!"
      puts "Right number was " + secret_number.to_s
      puts "Number of tries: #{tries}" 
      puts "\n\n\n"
      break
    end
  end
end

def play_game(start)
  if start == "start"
    game
  end
end

input = ""

while input != "exit"
  puts "To start game say \"Start\""
  puts "To exit game say \"Exit\""
  input = gets.downcase.chomp
  play_game(input)
end