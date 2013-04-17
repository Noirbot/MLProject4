#!/usr/bin/env ruby
require 'optparse'

options = {
  "braidiness" => 5,
  "width" => 10,
  "height" => 10
}

optparse = OptionParser.new do |opts|
    opts.on('-r ROWS', '--height', 'maze\'s height') do |h|
        options['height'] = Integer(h) unless h.nil?
    end

    opts.on('-w WIDTH', '--width', 'maze\'s width') do |w|
        options['width'] = Integer(w) unless w.nil?
    end

    opts.on('-b BRAIDINESS', '--braidiness', 'maze\'s braidiness (how likely it is to have loops)') do |b|
        options['braidiness'] = Integer(b) unless b.nil?
    end

    opts.on('-h', '--help', 'Display this help message') do
        puts opts
        exit
    end

    opts.parse!
end

class Maze
  DIRECTIONS = [ [1, 0], [-1, 0], [0, 1], [0, -1] ]

  def initialize(width, height, braidiness)
    @width = width
    @height = height
    @start_x = rand(width)
    @start_y = 0
    @end_x = rand(width)
    @end_y = height - 1
    @braidiness = braidiness
    # Which walls do exist? Default to "true". Both arrays are
    # one element bigger than they need to be. For example, the
    # @vertical_walls[y][x] is true if there is a wall between
    # (x,y) and (x+1,y). The additional entry makes printing
    # easier.
    @vertical_walls = Array.new(height) { Array.new(width, true) }
    @horizontal_walls = Array.new(height) { Array.new(width, true) }
    # Path for the solved maze.
    @path = Array.new(height) { Array.new(width) }

    # "Hack" to print the exit.
    @horizontal_walls[@end_y][@end_x] = false

    reset_visiting_state

    # Generate the maze.
    generate

    # randomly add loops to the maze if asked for
    make_loops unless @braidiness < 1
  end

  # Print a nice ASCII maze.
  def print
    # Special handling: print the top line.
    line = '#'
    for x in (0...@width)
      line.concat(x == @start_x ? '   #' : '####')
    end
    puts line

    # For each cell, print the right and bottom wall, if it exists.
    for y in (0...@height)
      line = '#'
      for x in (0...@width)
    line.concat(@path[y][x] ? " o " : "   ")
    line.concat(@vertical_walls[y][x] ? '#' : " ")
      end
      puts line

      line = '#'
      for x in (0...@width)
    line.concat(@horizontal_walls[y][x] ? '####' : '   #')
      end
      puts line
    end
  end

  private

  # Reset the VISITED state of all cells.
  def reset_visiting_state
    @visited = Array.new(@height) { Array.new(@width) }
  end

  # Check whether the given coordinate is within the valid range.
  def coordinate_valid?(x, y)
    (x >= 0) && (y >= 0) && (x < @width) && (y < @height)
  end

  # Is the given coordinate valid and the cell not yet visited?
  def move_valid?(x, y)
    coordinate_valid?(x, y) && !@visited[y][x]
  end

  # Generate the maze.
  def generate
    generate_visit_cell @start_x, @start_y
    reset_visiting_state
  end

  # Depth-first maze generation.
  def generate_visit_cell(x, y)
    # Mark cell as visited.
    @visited[y][x] = true

    # Randomly get coordinates of surrounding cells (may be outside
    # of the maze range, will be sorted out later).
    coordinates = []
    for dir in DIRECTIONS.shuffle
      coordinates << [ x + dir[0], y + dir[1] ]
    end

    for new_x, new_y in coordinates
      next unless move_valid?(new_x, new_y)

      # Recurse if it was possible to connect the current
      # and the the cell (this recursion is the "depth-first"
      # part).
      connect_cells(x, y, new_x, new_y)
      generate_visit_cell new_x, new_y
    end
  end

  # Try to connect two cells. Returns whether it was valid to do so.
  def connect_cells(x1, y1, x2, y2)
    if x1 == x2
      # Cells must be above each other, remove a horizontal
      # wall.
      @horizontal_walls[ [y1, y2].min ][x1] = false
    else
      # Cells must be next to each other, remove a vertical
      # wall.
      @vertical_walls[y1][ [x1, x2].min ] = false
    end
  end

  def make_loops
    @vertical_walls.map! do |a|
      a.map! do |v|
        if Random.rand(10) < @braidiness and (v != a.first and v != a.last)
          v = false
        else
          v = v
        end
      end
    end

    @horizontal_walls.map! do |a|
      a.map! do |h|
        if Random.rand(10) < @braidiness and (h != a.first and h != a.last)
          h = false
        else
          h = h
        end
      end
    end
  end
end

# Demonstration:
maze = Maze.new options['width'], options['height'], options['braidiness']
maze.print
