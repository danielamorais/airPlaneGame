debug = true
player = {x = 180, y = 550, speed = 150, img = nil}
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
enemyImg = nil
bulletImg = nil
fireSound = nil
bullets = {}
enemies = {}
isAlive = true
score = 0

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

function love.load(arg)
  --loads the image and bullet to use inside love
  player.img = love.graphics.newImage('assets/starship.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
  enemyImg = love.graphics.newImage('assets/kling.png')
  fireSound = love.audio.newSource("assets/fire.wav", "static")
end

function love.draw(dt)
  love.graphics.draw(player.img, player.x, player.y)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  --Draw enemies
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end

  if isAline then
    love.graphics.draw(player.img, player.x, player.y)
  else
    --love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
end

function love.update(dt)
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left', 'a') then
    player.x = player.x - (player.speed * dt)
  elseif love.keyboard.isDown('right', 'd') then
    player.x = player.x + (player.speed * dt)
  end

  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
    --Create some bullets
    newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
    table.insert(bullets, newBullet)
    fireSound:play()
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)
    if bullet.y < 0 then --remove the bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  --Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax
    --Create an enemy
    randomNumber = math.random(10, love.graphics.getWidth() - 10)
    newEnemy = {x = randomNumber, y = -10, img = enemyImg}
    table.insert(enemies, newEnemy)
  end

  --Update the positions of enemies
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (200 * dt)

    --Remove enemies when they pass off the screen
    if enemy.y > 850 then
      table.remove(enemies, i)
    end
  end

  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        score = score + 1
      end
    end

    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
    and isAlive then
      table.remove(enemies, i)
      isAlive = false
      -- remove all our bullets and enemies from screen
      bullets = {}
      enemies = {}
      -- reset timers
      canShootTimer = canShootTimerMax
      createEnemyTimer = createEnemyTimerMax
      -- move player back to default position
      player.x = 180
      player.y = 550
      -- reset our game state
      score = 0
      isAlive = true
    end
  end

end
