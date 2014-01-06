module Minesweeper
  class Tile
    attr_accessor :bombed, :flagged, :revealed

    def initialize

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

    end

    def neighbors

    end

    def neighbor_bomb_count

    end
  end

end