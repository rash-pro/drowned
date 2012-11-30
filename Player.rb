#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

class Player < Chingu::GameObject
  trait :bounding_box, :debug => false
  traits :timer, :collision_detection , :timer
  attr_accessor :last_x, :last_y, :direction
  
  def setup
    #
    # This shows up the shortened version of input-maps, where each key calls a method of the very same name.
    # Use this by giving an array of symbols to self.input
    #
    self.input = {  [:holding_left, :holding_a] => :holding_left, 
                    [:holding_right, :holding_d] => :holding_right,
                    [:holding_up, :holding_w] => :holding_up,
                    [:holding_down, :holding_s] => :holding_down
                  }
    
    @animations = Chingu::Animation.new(:file => "player.png")
    @animations.frame_names = { :scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13 }
    
    # Start out by animation frames 0-5 (contained by @animations[:scan])
    @animation = @animations[:scan]
    @speed = 3
    @last_x, @last_y = @x, @y
    
    update
  end
    
  def holding_left
    move(-@speed, 0)
    @animation = @animations[:left]
  end

  def holding_right
    move(@speed, 0)
    @animation = @animations[:right]
  end

  def holding_up
    move(0, -@speed)
    @animation = @animations[:up]
  end

  def holding_down
    move(0, @speed)
    @animation = @animations[:down]
  end
  
  #
  # Revert player to last positions when:
  # - player is outside the viewport
  # - player is colliding with at least one object of class StoneWall
  #
  def move(x,y)
    @x += x
    @x = @last_x  if self.parent.viewport.outside_game_area?(self) || self.first_collision(Obstruction)

    @y += y
    @y = @last_y  if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)
  end
  
  # We don't need to call super() in update().
  # By default GameObject#update is empty since it doesn't contain any gamelogic to speak of.
  def update
    
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
    
    if @x == @last_x && @y == @last_y
      # droid stands still, use the scanning animation
      @animation = @animations[:scan]
    else
      # Save the direction to use with bullets when firing
      @direction = [@x - @last_x, @y - @last_y]
    end
    
    @last_x, @last_y = @x, @y
  end
end