#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require_relative 'fruit'
require_relative 'player'
require_relative 'obstruction'
include Gosu
include Chingu

class Intro < GameState
  trait :timer
  
  def setup
    on_input([:space, :esc, :enter, :backspace, :gamepad_button_1, :return]) { switch_game_state(Main) }
    GameObject.create(:image => Image["splash.png"], :x => 0, :y => 0, :rotation_center => :top_left)
    @playtext = Chingu::Text.create("Press <return> to play", :x => 145, :y => 480, :size => 20, :color => Color::BLACK)
    @fader = GameObject.create(:image => Image["intro_fader.png"], :x => 0, :y => 0, :rotation_center => :top_left)
    between(1000,6000) { @fader.y -= 3 }.then {every(500, :name => :blink) { @playtext.visible? ? @playtext.hide! : @playtext.show! }}
    
    $window.caption = "Drowned"
   end
  
  def draw
    fill(Color::BLACK)
    super
  end

end


class Wait < GameState
  
  def setup
    on_input([:space, :esc, :enter, :backspace, :gamepad_button_1, :return]) { switch_game_state(Main) }
    GameObject.create(:image => Image["splash.png"], :x => 0, :y => 0, :rotation_center => :top_left)
    @playtext = Chingu::Text.create("Press <return> play", :x => 145, :y => 480, :size => 20, :color => Color::BLACK)
    every(500, :name => :blink) { @playtext.visible? ? @playtext.hide! : @playtext.show! }
    
    $window.caption = "Drowned"
   end
  
  def draw
    fill(Color::BLACK)
    super
  end

end


class Main < GameState
  #
  # This adds accessor 'viewport' to class and overrides draw() to use it.
  #
  trait :viewport
  trait :timer
  
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
    @score = 0
    every(200) {@score+=1 }
    
    #
    # Create 40 stars scattered around the map. This is now replaced by load_game_objects()
    # ## 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    #
    @parallax = Chingu::Parallax.create(:x => 0, :y => 0)
    @parallax << { :image => "sand.png", :repeat_x => true, :repeat_y => true}
    @score_text = Text.create("Score: #{@score}", :x => 10, :y => 10, :size=>20, :color => Color::BLACK)
    load_game_objects( :file => "map.yml")

    @player = Player.create(:x => 100, :y => 100)
   
  end

  def update    
    super

    # Droid can pick up starts
    @player.each_collision(Fruit) do |player, fruit|
      fruit.destroy
      Sound["fruit.wav"].play(0.5)
      @score+=10
    end
    @score_text.text = "Score: #{@score}"
     
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

class HighScoreState < GameState
  def setup
    on_input([:esc, :space, :backspace, :gamepad_button_1]) { switch_game_state(Wait) }
    Text.create("HIGH SCORES", :x => 200, :y => 10, :size => 40, :align => :center)
    create_text
  end
  
  def create_text
    Text.destroy_if { |text| text.size == 20 }
    
    #
    # Iterate through all high scores and create the visual represenation of it
    #
    $window.high_score_list.each_with_index do |high_score, index|
      y = index * 30 + 100
      Text.create(high_score[:name], :x => 200, :y => y, :size => 17)
      Text.create(high_score[:score], :x => 400, :y => y, :size => 17)
      Text.create(high_score[:text], :x => 600, :y => y, :size => 17)
    end
  end
end