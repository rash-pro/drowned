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

Game.new.show