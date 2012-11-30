#!/usr/bin/env ruby
require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

class Obstruction < GameObject
  trait :bounding_box, :debug => false
  trait :collision_detection
  
  def setup
    @image = Image["rock.png"]
    self.factor = 1
  end
end