#!/usr/bin/env ruby

require 'rubygems' rescue nil
$LOAD_PATH.unshift File.join(File.expand_path(__FILE__), "..", "..", "lib")
require 'chingu'
include Gosu
include Chingu

class Fruit < Chingu::GameObject
  trait :bounding_circle, :debug => false
  trait :collision_detection
<<<<<<< HEAD
=======
    
>>>>>>> 162e777b7c05473fc2b646dec013bc2d42ccf782
  def setup
    num = rand(1..3)
    case num
    when 1 
      fruta = "watermelon.png" 
    when 2
      fruta = "pineapple.png"
    when 3
      fruta = "grapes.png"
    end
    self.factor = 0.8    
<<<<<<< HEAD
    @animation = Chingu::Animation.new(file: "watermelon.png", :size => 32)
=======
    @animation = Chingu::Animation.new(:file => fruta, :size => 32)
>>>>>>> 162e777b7c05473fc2b646dec013bc2d42ccf782
    @image = @animation.next

    # A cached bounding circle will not adapt to changes in size, but it will follow objects X / Y
    # Same is true for "cache_bounding_box"
    cache_bounding_circle
  end
  
  def update
    # Move the animation forward by fetching the next frame and putting it into @image
    # @image is drawn by default by GameObject#draw
    @image = @animation.next
  end
end