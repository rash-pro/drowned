#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require_relative 'fruit'
require_relative 'player'
require_relative 'obstruction'
include Gosu
include Chingu

class Game < Chingu::Window 
  def initialize()
    super(500,600,false)    
    @bgmusic = Song["come-together.ogg"]
    @bgmusic.play
    #switch_game_state(SplashScreen.new)
  end
  
  def setup
    retrofy
    self.factor = 1.2
    #switch_game_state(SplashScreen.new)
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
    
    self.input = { escape: :exit } 

    Sound["fruit.wav"] # cache sound by accessing it once
    
    self.viewport.lag = 0                           # 0 = no lag, 0.99 = a lot of lag.
    self.viewport.game_area = [0, 0, 500, 10000]    # Viewport restrictions, full "game world/map/area"
    
    #
    # Create 40 stars scattered around the map. This is now replaced by load_game_objects()
    # ## 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    #
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0)
    @parallax << { :image => "sand.png", :repeat_x => true, :repeat_y => true}
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


Game.new.show