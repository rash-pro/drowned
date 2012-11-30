#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require_relative 'fruit'
require_relative 'player'
include Gosu
include Chingu

class Game < Chingu::Window 
  def initialize()
    super(500,600,false)    
    @bgmusic = Song["come-together.ogg"]
    @bgmusic.play
  end
  
  def setup
    retrofy
    self.factor = 3
    switch_game_state(Main.new)
  end    
end

class Main < GameState
  #
  # This adds accessor 'viewport' to class and overrides draw() to use it.
  #
  trait :viewport
  
  #
  # We create our 3 different game objects in this order: 
  # 1) map 2) stars 3) player
  # Since we don't give any zorders Chingu automatically increments zorder between each object created, putting player on top
  #
  def initialize(options = {})
    super
    
    self.input = { :escape => :exit } 

    Sound["fruit.wav"] # cache sound by accessing it once
    
    self.viewport.lag = 0                           # 0 = no lag, 0.99 = a lot of lag.
    self.viewport.game_area = [0, 0, 500, 10000]    # Viewport restrictions, full "game world/map/area"
    
    #
    # Create 40 stars scattered around the map. This is now replaced by load_game_objects()
    # ## 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    #
    load_game_objects( :file => "map.yml")
    
    @player = Player.create(:x => 100, :y => 100)    
  end

  def update    
    super

    # Droid can pick up starts
    @player.each_collision(Fruit) do |player, fruit|
      fruit.destroy
      Sound["fruit.wav"].play(0.5)
    end
     
    # Destroy game objects that travels outside the viewport
    game_objects.destroy_if { |game_object| self.viewport.outside_game_area?(game_object) }
    
    #
    # Align viewport with the droid in the middle.
    # This will make droid will be in the center of the screen all the time...
    # ...except when hitting outer borders and viewport x_min/max & y_min/max kicks in.
    #
    self.viewport.center_around(@player)
        
    $window.caption = "Drowned"
  end
end

# class Droid < Chingu::GameObject
#   trait :bounding_box, :debug => false
#   traits :timer, :collision_detection , :timer
#   attr_accessor :last_x, :last_y, :direction
  
#   def setup
#     #
#     # This shows up the shortened version of input-maps, where each key calls a method of the very same name.
#     # Use this by giving an array of symbols to self.input
#     #
#     self.input = {  [:holding_left, :holding_a] => :holding_left, 
#                     [:holding_right, :holding_d] => :holding_right,
#                     [:holding_up, :holding_w] => :holding_up,
#                     [:holding_down, :holding_s] => :holding_down,
#                     :space => :fire
#                   }
    
#     # Load the full animation from tile-file media/droid.bmp
#     @animations = Chingu::Animation.new(:file => "droid_11x15.bmp")
#     @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
#     # Start out by animation frames 0-5 (contained by @animations[:scan])
#     @animation = @animations[:scan]
#     @speed = 3
#     @last_x, @last_y = @x, @y
    
#     update
#   end
    
#   def holding_left
#     move(-@speed, 0)
#     @animation = @animations[:left]
#   end

#   def holding_right
#     move(@speed, 0)
#     @animation = @animations[:right]
#   end

#   def holding_up
#     move(0, -@speed)
#     @animation = @animations[:up]
#   end

#   def holding_down
#     move(0, @speed)
#     @animation = @animations[:down]
#   end

#   def fire
#     Bullet.create(:x => self.x, :y => self.y, :velocity => @direction)
#   end
  
#   #
#   # Revert player to last positions when:
#   # - player is outside the viewport
#   # - player is colliding with at least one object of class StoneWall
#   #
#   def move(x,y)
#     @x += x
#     @x = @last_x  if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)

#     @y += y
#     @y = @last_y  if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)
#   end
  
#   # We don't need to call super() in update().
#   # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
#   def update
    
#     # Move the animation forward by fetching the next frame and putting it into @image
#     # @image is drawn by default by GameObject#draw
#     @image = @animation.next
    
#     if @x == @last_x && @y == @last_y
#       # droid stands still, use the scanning animation
#       @animation = @animations[:scan]
#     else
#       # Save the direction to use with bullets when firing
#       @direction = [@x - @last_x, @y - @last_y]
#     end
    
#     @last_x, @last_y = @x, @y
#   end
# end


class StoneWall < GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection
  
  def setup
    @image = Image["stone_wall.bmp"]
    self.factor = 1
  end
end

class Bullet < GameObject
  traits :bounding_circle, :collision_detection, :velocity, :timer
  
  def setup
    @image = Image["fire_bullet.png"]
    self.factor = 1
    self.velocity_x *= 2
    self.velocity_y *= 2
  end
  
  def die
    self.velocity = [0,0]   
    between(0,50) { self.factor += 0.3; self.alpha -= 10; }.then { destroy }
  end
end
Game.new.show