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