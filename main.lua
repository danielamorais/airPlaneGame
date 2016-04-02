debug = true
player = {x = 180, y = 550, speed = 150, img = nil}
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

bulletImg = nil
bullets = {}

function love.load(arg)
  --loads the image and bullet to use inside love
  player.img = love.graphics.newImage('assets/plane.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
end

function love.draw(dt)
  love.graphics.draw(player.img, player.x, player.y)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
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
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)
    if bullet.y < 0 then --remove the bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end  
end
