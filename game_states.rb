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
    on_input([:space, :enter, :backspace, :gamepad_button_1, :return]) { switch_game_state(Main) }
    self.input = { esc: :exit }
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
  trait :timer

  def setup
    on_input([:space, :enter, :backspace, :gamepad_button_1, :return]) { switch_game_state(Main) }
    self.input = { esc: :exit }
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

    self.input = { e: :edit }

    Sound["fruit.wav"] # cache sound by accessing it once

    self.viewport.lag = 0                           # 0 = no lag, 0.99 = a lot of lag.
    self.viewport.game_area = [0, 0, 500, 100000]    # Viewport restrictions, full "game world/map/area"
    @score = 0
    @lavatimer = 0
    every(600) { @lavatimer += 1 }
    every(300) { @score+=1 }
    every(600) { @lava.y += 1 + @lavatimer }

    #
    # Create 40 stars scattered around the map. This is now replaced by load_game_objects()
    # ## 40.times { |nr| Star.create(:x => rand * self.viewport.x_max, :y => rand * self.viewport.y_max) }
    #
    @parallaxes = []
    tmp = Chingu::Parallax.create(:x => 0, :y => 0)
    tmp << { :image => "sand.png", :repeat_x => true, :repeat_y => true, damping: 10}
    @parallaxes << tmp

    @lava = Chingu::Parallax.create(:x => 250, :y => -360)
    @lava << { :image => "lava.png", zorder: 900 }


    @score_text = Text.create("Score: #{@score}", :x => self.viewport.x + 10, :y => self.viewport.y + 10, :size=>30, :color => Color::BLACK, zorder: 1000)
    load_game_objects( :file => "map.yml")

    @player = Player.create(:x => 100, :y => 100)

  end
  def edit
    #
    # Manually specify classes in editor
    #
    # state = GameStates::Edit.new(:file => "example19_game_objects.yml", :classes => [Star, StoneWall])

    #
    # Let Edit automatically detect available GameObjects (this includes Text etc)
    #
    # state = GameStates::Edit.new(:file => "example19_game_objects.yml")

    #
    # Let Edit decide what game objects to paint with + file to save to.
    # With this you can use a clean: self.input = { :e => GameStates::Edit }
    #
    state = GameStates::Edit

    #
    # This will show game objects classes except Droid-instances in the toolbar
    #
    # state = GameStates::Edit.new(:except => Droid)
    #

    push_game_state(state)
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
    # @score_text.x = self.viewport.x + 10
    # @score_text.y = self.viewport.y + 10

    # Destroy game objects that travels outside the viewport
    # game_objects.destroy_if { |game_object| self.viewport.outside_game_area?(game_object) }

    #
    # Align viewport with the droid in the middle.
    # This will make droid will be in the center of the screen all the time...
    # ...except when hitting outer borders and viewport x_min/max & y_min/max kicks in.
    #
    self.viewport.center_around(@player)
    @parallaxes.each do | p |
      p.camera_x = self.viewport.x
      p.camera_y = self.viewport.y
    end
    @score_text.x = self.viewport.x + 10
    @score_text.y = self.viewport.y + 10

    if (@player.y) <= (@lava.y + 360)
      switch_game_state(HighScoreState)
    end

    $window.caption = "Drowned"
  end
end

class HighScoreState < GameState
  def setup
    on_input([:esc, :space, :backspace, :gamepad_button_1]) { switch_game_state(Wait) }


    @title = PulsatingText.create("HIGH SCORES", :x => $window.width/2, :y => 50, :size => 70)

    #
    # Load a list from disk, defaults to "high_score_list.yml"
    # Argument :size forces list to this size
    #
    @high_score_list = HighScoreList.load(:size => 10)

    #
    # Add some new high scores to the list. :name and :score are required but you can put whatever.
    # They will mix with the old scores, automatic default sorting on :score
    #

    create_text
  end

  def add
    data = {:name => "NEW", :score => @high_score_list.high_scores.first[:score] + 10, :text => "from example13.rb"}
    position = @high_score_list.add(data)
    puts "Got position: #{position.to_s}"
    create_text
  end

  def create_text
    Text.destroy_if { |text| text.size == 20}

    #
    # Iterate through all high scores and create the visual represenation of it
    #
    @high_score_list.each_with_index do |high_score, index|
      y = index * 25 + 100
      Text.create(high_score[:name], :x => 200, :y => y, :size => 20)
      Text.create(high_score[:score], :x => 400, :y => y, :size => 20)
    end
  end
end

#
# colorful pulsating text...
#
class PulsatingText < Text
  traits :timer, :effect

  def initialize(text, options = {})
    super(text, options)

    options = text  if text.is_a? Hash
    @pulse = options[:pulse] || false
    self.rotation_center(:center_center)
    every(20) { create_pulse }   if @pulse == false
  end

  def create_pulse
    pulse = PulsatingText.create(@text, :x => @x, :y => @y, :height => @height, :pulse => true, :image => @image, :zorder => @zorder+1)
    colors = [Color::RED, Color::GREEN, Color::BLUE]
    pulse.color = colors[rand(colors.size)].dup
    pulse.mode = :additive
    pulse.alpha -= 150
    pulse.scale_rate = 0.002
    pulse.fade_rate = -3 + rand(2)
    pulse.rotation_rate = rand(2)==0 ? 0.05 : -0.05
  end

  def update
    destroy if self.alpha == 0
  end

end
