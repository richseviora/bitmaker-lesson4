=begin
Robotic rovers will operated in a N by N grid (width east to west, height south to north).
Each rover will face a cardinal direction (North, East, West, South).

Each rover will accept the commands:
"L" - Turn left 90 degrees.
"R" - Turn right 90 degrees.
"M" - Move ahead one grid unit.

Input File
First Line "X Y" defines grid size.
N Pairs of two lines defining each rover location and orientation, and its instructions:
  First Line "X Y D" where X and Y represent location (as integers) and D represents cardinal direction.
  Second line matching regex "[LRM]+" where these are rover instructions.

Output Results
One line for each rover in the form "X Y D" where X and Y represent location and D represents cardinal direction.

=end

# Constant declarations.

VERBOSE = FALSE
DIRECTIONS = {:north => "N", :west => "W", :east => "E", :south => "S"}
COMPASS = [:north, :east, :south, :west]

# Implementing Directions as a separate class as its a separate entity, conceptually.
class Direction

  #Returns the direction as a symbol.
  def self.to_symbol(direction='N')
    puts "Asking for Symbol for Direction #{direction}" if VERBOSE
    return DIRECTIONS.key(direction)
  end
  #Returns the direction as a string.
  def self.to_string(direction=:north)
    puts "Asking for String for Direction #{direction}" if VERBOSE
    return DIRECTIONS[direction]
  end

  #Returns the outcome when an object is turning in a given direction, from a given cardinal direction.
  def self.turn_from_direction(direction, turnLeft=TRUE)
    # Find Direction in Compass
    puts "Turning: Left?:#{turnLeft} Direction:#{direction}" if VERBOSE
    index = COMPASS.index(direction)
    if index.nil?
      raise "Invalid Direction Provided."
    end
    newIndex = turnLeft ? index - 1 : index + 1
    newIndex %= 4
    COMPASS[newIndex]
  end

  # Defines what the outcome of a move is if the user moves from a direction.
  def self.move_from_direction(location_x, location_y, facing_direction)
    case facing_direction
      when :north
        return [location_x, location_y + 1]
      when :south
        return [location_x, location_y - 1]
      when :east
        return [location_x + 1, location_y]
      when :west
        return [location_x - 1, location_y]
    end
  end
end

class Rover
  attr_accessor :instructions

  def initialize(x = 0, y = 0, cardinal_direction='N')
    puts "Initializing with Inputs X: #{x} Y:#{y}, Direction:#{cardinal_direction}" if VERBOSE
    @location_x = x
    @location_y = y
    @facing_direction = Direction.to_symbol(cardinal_direction)
  end

  # Instructs the rover to process all its instructions.
  def process_instructions
    instructions.each do |instruction|
      handle_instruction(instruction)
    end
  end

  # Handles the instruction, asking the Directions class for their new location.
  def handle_instruction(input)
    case input
      when 'M'
        @location_x, @location_y = Direction.move_from_direction(@location_x, @location_y, @facing_direction)
      when 'L'
        @facing_direction = Direction.turn_from_direction(@facing_direction, TRUE)
      when 'R'
        @facing_direction = Direction.turn_from_direction(@facing_direction, FALSE)
    end
  end

  # Prints the current state of the rover.
  def print_state
    puts "#{@location_x} #{@location_y} #{Direction.to_string(@facing_direction)}"
  end

end

class Mission_Control
  attr_reader :plateau_size
  attr_reader :rovers
  def initialize(filename)
    if filename.nil?
      raise "Filename Required"
    end
    @rovers = []
    @filename = filename
    read_file
    execute_rover_commands
    report_final_state
  end

  # Reports the Final State of the Rovers
  def report_final_state
    @rovers.each do |rover|
      rover.print_state
    end
  end

  # Executes the Rover Commands
  def execute_rover_commands
    @rovers.each do |rover|
      puts "Starting Instructions for #{rovers.index(rover)}" if VERBOSE
      rover.process_instructions
    end
  end

  # Reads the file and passes the data to the methods responsible for handling their inputs.
  def read_file
    puts "Starting to Read File" if VERBOSE
    input_file = File.new(@filename)
    assign_plateau_size(input_file.readline)
    until input_file.eof?
      deploy_rover(input_file.readline, input_file.readline)
    end
  end

  # Defines the plateau size based on input.
  def assign_plateau_size(input)
    puts "Assign_Plateau_Size: #{input}" if VERBOSE
    if !input.is_a?(String)
      raise "Non String Input"
    end
    input_array = input.split()
    puts "Assign_Plateau_Size : Input_Array #{input_array}" if VERBOSE
    @plateau_size = [input_array[0].to_i,input_array[1].to_i]
  end

  # Deploys the rover based on the input provided.
  def deploy_rover(location_input, instructions_input)
    if VERBOSE
      puts "Deploying Rover"
      puts "Location Input: #{location_input}"
      puts "Location Input: #{instructions_input}"
    end
    location_input_array = location_input.split()
    new_rover = Rover.new(location_input_array[0].to_i,location_input_array[1].to_i,location_input_array[2])
    new_rover.instructions = instructions_input.chars
    @rovers << new_rover
  end
end

explorer = Mission_Control.new('exercise4-2input.txt')
