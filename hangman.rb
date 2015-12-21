require 'yaml'

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

	def self.load
		begin
			game = File.open('save.yaml', 'r') { |file| YAML::load file }
			game.ended ? self.new : game.play
		rescue
			puts "No game has been saved yet!"
			game = self.new
		end	
	end

	def ended
		@won || @lost
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
		save
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
		begin
			gets.chomp.downcase.match(/[a-z]/)[0]
		rescue
			puts "Please input a letter!"
			retry
		end
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

	def save
		serialized = YAML::dump self
		File.open('save.yaml', 'w') { |file| file.write serialized }
	end

	def give_result
		puts "The word is '#{@word}'. You won!" if @won
		puts "You lost! The word was '#{@word}'." if @lost
	end
end

puts "Press 'l' and Enter, if you'd like to load previous game."
puts "Press Enter to start new game"
input = gets.chomp
input == 'l' ? Game.load : Game.new