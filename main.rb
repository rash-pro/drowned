#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
require_relative 'game_states'
include Gosu
include Chingu

class Game < Chingu::Window 
  def initialize()
    super(500,600,false)    
    @bgmusic = Song["theme.ogg"]
    @bgmusic.play
  end
  
  def setup
    retrofy
    self.factor = 1.2
    push_game_state(Intro)
    #switch_game_state(Main)

  end    
end

Game.new.show