require "yaml"

class Hangman

  def initialize
    @secret_letters = generate_word.split("")
    @guessed_letters = blank_slots
    @wrong_letters = []
    @guesses_left = 8
    @out_of_guesses = false
  end

  def generate_word
    dictionary = File.new("dictionary.txt","r")
    random_word = dictionary.read.split.sample
    unless (5..12) === random_word.length then random_word = generate_word end
    random_word
  end

  def blank_slots
    arr = []
    (@secret_letters.length).times { arr << "_" }
    arr
  end

  def save_game
    Dir.mkdir("saves") unless Dir.exist?("saves")

    File.open("saves/save_file.txt", "w") { |f| f.write(YAML::dump(self)) }
    puts "\n   Game state saved!"
  end


  def load(filename)
    puts "Loading..."
    puts File.read(filename).inspect
    from_json(File.read(filename))
  end

  def start
    puts "\n   Welcome to Hangman.\n"
    puts "   The word has #{@secret_letters.length.to_s} letters. Good luck!\n"
    #For debugging purposes:
    #puts "   Word is: #{@secret_letters.join}\n"

    until  @out_of_guesses || @secret_letters == @guessed_letters
      puts "\n   #{@guessed_letters.join}\n"

      puts "\n   Does not contain: #{@wrong_letters.join(" ")}"
      puts "   Enter a letter, or 'save' to save:"
      guess = gets.chomp.downcase

      if guess == "save" then
        save_game
      elsif @secret_letters.any? { |letter| letter == guess  }
        @secret_letters.each_with_index do |letter,index|
          @guessed_letters[index] = guess if letter == guess
        end
        puts "\n   There are #{@secret_letters.count(guess)} #{guess}'s.'"
      else
        @guesses_left -= 1
        @out_of_guesses = true if @guesses_left < 1
        puts "\n   No #{guess}'s. You have #{@guesses_left} guesses left."
        @wrong_letters << guess
      end

    end

    puts "\n   You got it!" unless @out_of_guesses

    puts "\n   The word was #{@secret_letters.join}."
    puts "\n   Play again? (y/n)"
    answer = gets.chomp
    if answer == "y" then
      initialize
      start
    else
      puts "\n   See you around."
    end

  end

end

def saved_game?
  if File.file?("saves/save_file.txt") then
    puts "\n   Load previous game state? (y/n)"
    load_game = gets.chomp
    if load_game == "y"
      save_file = File.open("saves/save_file.txt","r")
      game_state = YAML::load(save_file)
    else
      game_state = Hangman.new
    end
  else
    game_state = Hangman.new
  end
  game_state
end

game = saved_game?
game.start
