player = {x = 200, y = 550, speed = 150, img = nil}
enemy = {x = 200, y = 10, speed = 200, img = nil}

canShoot = true
canShootTimerMax = 0.7
canShootTimer = canShootTimerMax

enemyCanShoot = true
enemyCanShootTimerMax = 0.7
enemyCanShootTimer = enemyCanShootTimerMax

bulletImg = nil
bullets = {}
enemyBulletImg = nil
enemyBullets = {}

fireSound = nil
enemyFireSound = nil
backgroundSound = nil
explosionSound = nil

background = nil
isAlive = true
score = {klingon = 0, federation = 0}

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

function setPosition(xPosition, xSpeed, dt, position)
   if position == 'r' then
        xPosition = xPosition + (xSpeed * dt)  
   end     
   if position == 'l' then       
        xPosition = xPosition - (xSpeed * dt)    
   end     
   if xPosition > 418 then
        xPosition = 418
   end
   if xPosition < 6 then
        xPosition = 6
   end
   return xPosition       
end 

function love.enter()
      backgroundSound = love.audio.newSource('assets/background.wav', 'stream')    
      love.audio.play(backgroundSound)
end


function love.load(arg)
  player.img = love.graphics.newImage('assets/starship.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
  enemyBulletImg = love.graphics.newImage('assets/enemyBullet.png')
  enemy.img = love.graphics.newImage('assets/kling.png')
  background = love.graphics.newImage('assets/stars.jpg')
  fireSound = love.audio.newSource('assets/fire.wav', 'static')
  enemyFireSound = love.audio.newSource('assets/klingon.wav', 'static')
  explosionSound = love.audio.newSource('assets/explosion.wav', 'static')
  love.graphics.setFont(love.graphics.newFont('assets/federation.ttf' , 35))
end

function love.draw(dt)
  love.graphics.draw(background, 0, 0)
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemyBullet in ipairs(enemyBullets) do
    love.graphics.draw(enemyBullet.img, enemyBullet.x, enemyBullet.y)
  end

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
    love.graphics.print("POINTS:" .. score.federation .. " X " .. score.klingon, 50, 25)
  else
    love.graphics.setFont(love.graphics.newFont('assets/federation.ttf' , 60))    
    love.graphics.print("GAME OVER", love.graphics:getWidth()/2-100, love.graphics:getHeight()/2-180)
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-180, love.graphics:getHeight()/2-90)
    if love.keyboard.isDown('r') then
        isAlive = true
        love.graphics.setFont(love.graphics.newFont('assets/federation.ttf' , 35))   
        score = {klingon = 0, federation = 0} 
    end
  end
end

function love.update(dt)
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left') then
        player.x = setPosition(player.x, player.speed, dt, 'l')
  elseif love.keyboard.isDown('right') then
        player.x = setPosition(player.x, player.speed, dt, 'r') 
  end
  
  if love.keyboard.isDown('a') then
     enemy.x = setPosition(enemy.x, enemy.speed, dt, 'l')
  elseif love.keyboard.isDown('d') then
     enemy.x = setPosition(enemy.x, enemy.speed, dt, 'r') 
  end

  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  enemyCanShootTimer = enemyCanShootTimer - (1 * dt)
  if enemyCanShootTimer < 0 then
    enemyCanShoot = true
  end

  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
    --Create some bullets
    fireSound:play()
    newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  if love.keyboard.isDown('up', 'w') and enemyCanShoot then
    enemyFireSound:play()
    newEnemyBullet = {x = enemy.x + (enemy.img:getWidth()/2), y = enemy.y, img = enemyBulletImg}
    table.insert(enemyBullets, newEnemyBullet)
    enemyCanShoot = false
    enemyCanShootTimer = enemyCanShootTimerMax
  end

  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)
    if bullet.y < 0 then --remove the bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  for i, enemyBullet in ipairs(enemyBullets) do
    enemyBullet.y = enemyBullet.y + (250 * dt)
    --print(enemyBullet.y)
    if enemyBullet.y > 750 then --remove the bullets when they pass off the screen
      table.remove(enemyBullets, i)
    end
  end

  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, bullet in ipairs(bullets) do
    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
      table.remove(bullets, i)
      score.federation = score.federation + 1
      if score.federation > 4 then
        isAlive = false
      end  
    end
  end

  for i, enemyBullet in ipairs(enemyBullets) do
    if CheckCollision(player.x, player.y, player.img:getWidth(), player.img:getHeight(), enemyBullet.x, enemyBullet.y, enemyBullet.img:getWidth(), enemyBullet.img:getHeight()) then
      table.remove(enemyBullets, i)
      score.klingon = score.klingon + 1
      if score.klingon > 4 then
        isAlive = false
      end 
    end
  end

end
