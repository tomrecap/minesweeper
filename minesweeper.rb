require 'debugger'

module Minesweeper
  class Tile
    attr_accessor :bombed, :flagged, :revealed

    def initialize(row, col, bombed = false)
      @bombed
      @flagged = false
      @revealed = false
      @row = row
      @col = col
    end

    def bombed?
      return true if @bombed
      false
    end

    def flagged?
      return true if @flagged
      false
    end

    def revealed?
      return true if @revealed
      false
    end

    def reveal
      if revealed?
        # error, you can't reveal it twice
      elsif bombed?
        # game ends, you lose
      elsif flagged?
        # you can't reveal it until you unflag it
      else
        # reveal the tile
        # set revealed to true, so it gets
        # displayed next time we render the board

        # calculate neighbor bomb count
        @revealed = true
        @neighbor_bomb_count = set_neighbor_bomb_count
        if @neighbor_bomb_count == 0
          reveal(neighbors)
        end
      end
    end

    def neighbors
      adj_pos = []

      (-1..1).each do |i|
        (-1..1).each do |j|
          adj_pos << [@row + i, @col + j]
        end
      end

      adj_pos.delete_if do |pos|
        pos.any?{ |coord| coord < 0 } || pos == [@row, @col]
      end
    end

    def set_neighbor_bomb_count
      adjacent_bombs = 0

      neighbors.each do |neighbor_pos|
        row, col = neighbor_pos
        neighbor_tile = (board object).board[row][col]
        if neighbor_tile.bombed? == true
          adjacent_bombs += 1
        end
      end

      adjacent_bombs
    end
  end

  class Board
    attr_accessor :board, :num_of_bombs

    def initialize(num_of_bombs = 3)
      @num_of_bombs = num_of_bombs
      @board = build_board
    end

    def build_board
      board = Array.new(9) { Array.new }
      9.times{ |row| 9.times{ |col| board[row] << Tile.new(row, col) } }
      self.class.place_bombs(board, @num_of_bombs)
    end

    def render
      current_board = translate_objects_to_symbols(@board)

      current_board.each{ |row| p row }
    end

    def translate_objects_to_symbols(board)
      board.map do |row|
        row.map do |tile|
          char_to_display(tile)
        end
      end
    end

    def char_to_display(tile)
      # return "B" if tile.bombed?
      return "F" if tile.flagged?
      return "*" if !tile.revealed?
      return "_" if tile.neighbor_bomb_count == 0
      return tile.neighbor_bomb_count.to_s if tile.neighbor_bomb_count > 0
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

  end

end