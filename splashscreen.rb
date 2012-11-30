#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

class SplashScreen < Chingu::GameState
  def update
  # game logic here
end

def draw
  # screen manipulation here
end

# Called when we enter the game state
def setup
  self.input = { :escape => :close, :return => :load } # exits example on Escape
  Chingu::GameObject.create(:x => 200, :y => 100, :image => Image["spaceship.png"])
  Chingu::Text.create("Press <return> to load game", :y => 100)
end

# Called when we leave the current game state
def finalize
  push_game_state(Main)   # switch to game state "Menu"
end