require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'
require_relative 'fuel'

class SectorFive < Gosu::Window
  WIDTH = 1920
  HEIGHT = 1080
  ENEMY_FREQUENCY = 0.08
  FUEL_FREQUENCY = 0.0015
  red_screen = Gosu::Color::RED
  game_timer = 0

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
    @background = Gosu::Image.new('SPRITES/bg2.png', tileable: true)
    @score = 0
    @lives = 3
    @game_music = Gosu::Song.new('background-music.mp3')
    @game_music.play(true)
    @rs_display = false
    @red_screen = Gosu::Color::RED
    @black_colour = Gosu::Color::BLACK
    @lives1 = Gosu::Image.new('SPRITES/lives1.png', tileable: true)
    @lives2 = Gosu::Image.new('SPRITES/lives2.png', tileable: true)
    @lives3 = Gosu::Image.new('SPRITES/lives3.png', tileable: true)
    @font = Gosu::Font.new(100)
    @font_lost = Gosu::Font.new(200)
    @fuels = []
  end

  def update

    # Checks if end-game conditions have been met
    if @lives == 0 or @player.get_fuel <= 0
      sleep(3)
      close!
    end

    # Takes player input
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)

    # Moves the player and decreases fuel
    @player.decrease_fuel
    @player.move

    # Adds enemies and fuels
    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @fuels.push Fuel.new(self) if rand < FUEL_FREQUENCY

    # Moves enemies, bullets and fuel
    @enemies.each {|enemy| enemy.move}
    @bullets.each {|bullet| bullet.move}
    @fuels.each {|fuel| fuel.move}

    # Checking if enemies have been hit by the bullet
    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu::distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @score += 500
        end
      end
    end

    # Checks if the player collided with an enemy
    @enemies.dup.each do |enemy|
      distance = Gosu::distance(@player.x, @player.y, enemy.x, enemy.y)
      if distance < enemy.radius + @player.radius
        @enemies.delete enemy
        @explosions.push Explosion.new(self, enemy.x, enemy.y)
        @rs_display = true
        @lives -= 1
        @score += 500
      end
    end

    # Checks if the player collected the fuel
    @fuels.dup.each do |fuel|
      distance = Gosu::distance(@player.x, @player.y, fuel.x, fuel.y)
      if distance < fuel.radius + @player.radius
        @player.reset_fuel
        @fuels.delete fuel
      end
    end

    # Ends explosion effect
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.getfinished()
    end

    # Removing either destroyed enemies or collided enemies
    @enemies.dup.each do |enemy|
      if enemy.y > HEIGHT + enemy.radius
        @enemies.delete enemy
      end
    end

    # removes bullets that exit the screen or hit an enemy
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
  end

  # Fires a bullet upon pressing spacebar
  def button_down(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end
  end

  def draw
    # Displays lives and score
    @lives1.draw(25, 50, 2) if @lives == 1
    @lives2.draw(25, 50, 2) if @lives == 2
    @lives3.draw(25, 50, 2) if @lives == 3
    @font.draw("SCORE: #{@score}", 1200, 50, 2)

    # Display player, background, enemies bullets, explosions, fuels
    @player.draw
    @background.draw(0, 0, -1)
    @enemies.each {|enemy| enemy.draw}
    @bullets.each {|bullet| bullet.draw}
    @explosions.each {|explosion| explosion.draw}
    @fuels.each {|fuel| fuel.draw}

    # Fuel bar display
    draw_quad(20, 1000, @black_colour, 220, 1000, @black_colour, 20, 1025, @black_colour, 220, 1025, @black_colour)
    draw_quad(20, 1000, @red_screen, 2*@player.get_fuel+20, 1000, @red_screen, 20, 1025, @red_screen, 2*@player.get_fuel+20, 1025, @red_screen)

    # Game Over Message
    @font_lost.draw("YOU LOST!", 450, 500, 2) if @lives == 0 or @player.get_fuel <= 0

    # Red splash screen upon player getting hit
    if @rs_display and @lives != 0
      draw_quad(0, 0, @red_screen, 1920, 0, @red_screen, 1920, 1080, @red_screen, 0, 1080, @red_screen)
    end
    @rs_display = false
  end
end

# Run
wind = SectorFive.new
wind.show
