require 'debugger'
require 'yaml'

module Minesweeper
  class Tile
    attr_accessor :bombed, :flagged, :revealed, :neighbors, :row, :col, :neighbor_bomb_count

    def initialize(row, col, bombed = false)
      @bombed
      @flagged = false
      @revealed = false
      @row = row
      @col = col
      @neighbors = []
    end

    def bombed?
      @bombed
    end

    def flagged?
      @flagged
    end

    def revealed?
      @revealed
    end

    def reveal
      if revealed?
        return nil
      elsif flagged?
        return nil
      else
        @revealed = true
        @neighbor_bomb_count = set_neighbor_bomb_count

        if @neighbor_bomb_count == 0
          @neighbors.each do |neighbor|
            neighbor.reveal
          end
        end
      end

      nil
    end

    def to_s
      "String!"
    end

    def find_neighbors
      adj_pos = []

      (-1..1).each do |i|
        (-1..1).each do |j|
          adj_pos << [@row + i, @col + j]
        end
      end

      adj_pos.delete_if do |pos|
        pos.any?{ |coord| !coord.between?(0,8) } || pos == [@row, @col]
      end
    end

    def set_neighbor_bomb_count
      adjacent_bombs = 0

      @neighbors.each do |neighbor|
        adjacent_bombs += 1 if neighbor.bombed? == true
      end

      adjacent_bombs
    end

    def set_flag
      return nil if revealed?
      @flagged = (@flagged ? false : true)
    end

    def char_to_display
      # return "B" if bombed?
      return "F" if flagged?
      return "*" if !revealed?
      return "_" if neighbor_bomb_count == 0
      return neighbor_bomb_count.to_s if neighbor_bomb_count.to_i > 0
    end

  end

  class Board
    attr_accessor :board, :num_of_bombs

    def initialize(num_of_bombs = 10)
      @num_of_bombs = num_of_bombs
      @board = build_board
      set_neighbors
    end

    def to_s
      "Board"
    end

    def build_board
      board_array = Array.new(9) { Array.new }
      9.times{ |row| 9.times{ |col| board_array[row] << Tile.new(row, col) } }
      self.class.place_bombs(board_array, @num_of_bombs)
    end

    def set_neighbors
      @board.each do |row|
        row.each do |tile|
          neighbor_pos = tile.find_neighbors
          neighbor_pos.each do |pos|
            x, y = pos
            tile.neighbors << @board[x][y]
           end
        end
      end
    end

    def render
      current_board = translate_objects_to_symbols(@board)

      current_board.each{ |row| puts row.join('_|_') }

      return nil
    end

    def translate_objects_to_symbols(board)
      board.map do |row|
        row.map do |tile|
          tile.char_to_display
        end
      end
    end

    def self.place_bombs(board, num_of_bombs)
      bomb_pos = []

      until bomb_pos.size == num_of_bombs
        row = rand(0...board.size)
        col = rand(0...board.size)

        bomb_pos << [row, col] unless bomb_pos.include?([row, col])
      end

      bomb_pos.each do |position|
        row = position.first
        col = position.last

        board[row][col].bombed = true
      end

      board
    end

    def game_over?

      game_is_over = true

      @board.each do |row|
        row.each do |tile|
          if !tile.revealed? && !tile.bombed?
            game_is_over = false
          end
        end
      end

      game_is_over
    end

    def win?
      won = true

      @board.each do |row|
        row.each do |tile|
          if tile.revealed? && tile.bombed?
            won = false
          end
        end
      end

      won
    end

    def lose?
      lost = false

      @board.each do |row|
        row.each do |tile|
          lost = true if (tile.bombed? && tile.revealed?)
        end
      end

      lost
    end
  end

  class Game

    def initialize(board = Board.new)
      @board = board
    end

    def play
      puts "Play has started"
      @board.render

      until @board.game_over?
        action, pos = player_turn
        return if action == "q"

        execute_move(action, pos)

        @board.render
      end

      if @board.win?
        puts "You win!"
      else
        puts "You lose!"
      end

      @board.render
    end

    def player_turn
      puts "What would you like to do? (r, f, s, q)"
      action = gets.chomp
      unless action == "s" || action == "q"
        puts "Where would you like to do that? (x,y)"
        pos = gets.chomp.split(",")
      else
        pos = nil
      end

      return [action, pos]
    end

    def execute_move(action, pos)
      x, y = pos
      if action == "r"
        @board.board[x.to_i][y.to_i].reveal
      elsif action == "f"
        @board.board[x.to_i][y.to_i].set_flag
      elsif action == "s"
        save
      end
      nil
    end

    def save
      board_save_state = @board.to_yaml

      puts "What would you like to call your save game?"
      save_name = gets.chomp
      File.open("#{save_name}.ms", "w") do |line|
        line.write(board_save_state)
      end

      puts "Saved!"
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  unless ARGV.empty?
    # read file
    file_name = ARGV.shift
    contents = File.read(file_name)
    board = YAML::load(contents)

    Minesweeper::Game.new(board).play
  else
    Minesweeper::Game.new
  end

end