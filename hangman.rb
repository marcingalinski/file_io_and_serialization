class Game
	def initialize
		@word = find_word.split('')
		@guessed = Array.new(@word.size, '_')
		@tried = []
		@won = false
		@lost = false

		play
	end

	def play
		greet
		make_turn until @won || @lost
		give_result
	end

	private

	def greet
		puts "Let's play hangman!"
	end

	def find_word
		dictionary = make_dictionary
		dictionary[rand(0...dictionary.size)].chomp.downcase
	end

	def make_dictionary
		File.open('5desk.txt', 'r') do |file| 
			file.readlines.select { |line| (5..12).include? line.size }
		end
	end

	def make_turn
		guess = take_guess
		check guess
		check_status
	end

	def take_guess
		give_hint
		clean_input
	end

	def give_hint
		puts @guessed.join(' ')
		print "You tried: #{@tried.join(', ')}. " unless @tried.empty?
		puts "Guess now!"
	end

	def clean_input
		gets.chomp.downcase
	end

	def check guess
		@word.include?(guess) ? update_guessed(guess) : update_tried(guess)
	end

	def update_guessed guess
		@word.each_with_index do |letter, index|
			@guessed[index] = guess if letter == guess
		end
	end

	def update_tried guess
		@tried.push(guess).sort!.uniq!
	end

	def check_status
		@won = true if @guessed == @word
		@lost = true if @tried.size >= 7
	end

	def give_result
		puts "The word is '#{@word}'. You won!" if @won
		puts "You lost! The word was '#{@word}'." if @lost
	end
end

Game.new