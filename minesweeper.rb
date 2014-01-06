module Minesweeper
  class Tile
    attr_accessor :bombed, :flagged, :revealed

    def initialize(bombed = false)
      @bombed
      @flagged = false
      @revealed = false
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
        @neighbor_bomb_count = neighbor_bomb_count
      end
    end

    def neighbors

    end

    def neighbor_bomb_count

    end
  end

  class Board
    attr_accessor :board

    def initialize
      @board = Array.new(9) { Array.new }
      9.times{ |i| 9.times{ @board[i] << Tile.new } }
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
      return "F" if tile.flagged?
      return "*" if !tile.revealed?
      return "_" if tile.neighbor_bomb_count == 0
      return tile.neighbor_bomb_count.to_s if tile.neighbor_bomb_count > 0
    end


  end

end