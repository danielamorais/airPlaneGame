debug = true
player = {x = 180, y = 550, speed = 150, img = nil}
canShoot = true
canShootTimerMax = 0.7
canShootTimer = canShootTimerMax
createenemyimerMax = 0.4
createenemyimer = createenemyimerMax
enemyImg = nil
bulletImg = nil
fireSound = nil
bullets = {}
enemies = {}
isAlive = true
score = 0
enemy = {x = 50, y = -10, img = nil}
enemyImg = enemy.img

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

function love.load(arg)
  player.img = love.graphics.newImage('assets/starship.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
  enemy.img = love.graphics.newImage('assets/kling.png')
  fireSound = love.audio.newSource("assets/fire.wav", "static")
end

function love.draw(dt)
  love.graphics.draw(player.img, player.x, player.y)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
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
    fireSound:play()
    newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)
    if bullet.y < 0 then --remove the bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for j, bullet in ipairs(bullets) do
    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
      table.remove(bullets, j)
      score = score + 1
      print("Game over")
    end
  end

end
