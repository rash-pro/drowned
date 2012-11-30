#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu

class Game < Chingu::Window
  def initialize
    super(800,600,false)              # leave it blank and it will be 800,600,non fullscreen
    self.input = { :escape => :exit } # exits example on Escape
    
    @bgmusic = Song["come-together.ogg"]
    @bgmusic.play
    @player = Player.create(:x => 200, :y => 200, :image => Image["player.png"])
    @player.input = { :holding_left => :move_left, :holding_right => :move_right, 
                      :holding_up => :move_up, :holding_down => :move_down }
    Fruit.create(:x => 200, :y => 300)
  end
  
  def update
    super
    self.caption = "FPS: #{self.fps}"
  end
end

class Player < Chingu::GameObject  
  def move_left;  @x -= 3; end
  def move_right; @x += 3; end
  def move_up;    @y -= 3; end
  def move_down;  @y += 3; end
end

class Fruit < Chingu::GameObject
  trait :bounding_circle, :debug => false
  trait :collision_detection
  
  def setup    
    @animation = Chingu::Animation.new(:file => "watermelon.png", :size => 32)
    @image = @animation.next
    #self.rotation_center = :center
    
    #
    # A cached bounding circle will not adapt to changes in size, but it will follow objects X / Y
    # Same is true for "cache_bounding_box"
    #
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end
end

Game.new.show