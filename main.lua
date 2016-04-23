player = { x = 200, y = 550, speed = 150, img = nil, redAlertSound = nil, fireSound = nil }
enemy = { x = 200, y = 10, speed = 200, img = nil, redAlertSound = nil, fireSound = nil }
score = { klingon = 0, federation = 0 }

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
dotImg = nil

backgroundSound = nil
explosionSound = nil
introSound = nil
musicSeconds = 0
introSeconds = 0
beepSound = nil
redAlertSeconds = 0

dotIsUp = true
background = nil
federationLogo = nil
isAlive = true
playing = false

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function setPosition(xPosition, xSpeed, dt, position)
    if position == 'r' then xPosition = xPosition + (xSpeed * dt) end
    if position == 'l' then xPosition = xPosition - (xSpeed * dt) end
    if xPosition > 418 then xPosition = 418 end
    if xPosition < 6 then xPosition = 6 end
    return xPosition
end

function love.load(arg)
    love.audio.setVolume(1.0)
    player.img = love.graphics.newImage('assets/starship.png')
    bulletImg = love.graphics.newImage('assets/bullet.png')
    enemyBulletImg = love.graphics.newImage('assets/enemyBullet.png')
    enemy.img = love.graphics.newImage('assets/kling.png')
    background = love.graphics.newImage('assets/stars.jpg')
    federationLogo = love.graphics.newImage('assets/federationLogo.png')
    dotImg = love.graphics.newImage('assets/dot.png')

    player.redAlertSound = love.audio.newSource('assets/ussAlert.wav', 'static')
    enemy.redAlertSound = love.audio.newSource('assets/klingonAlert.wav', 'static')
    beepSound = love.audio.newSource('assets/beep.wav', 'static')
    player.fireSound = love.audio.newSource('assets/fire.wav', 'static')
    enemy.fireSound = love.audio.newSource('assets/klingon.wav', 'static')
    explosionSound = love.audio.newSource('assets/explosion.wav', 'static')
    backgroundSound = love.audio.newSource('assets/background.wav', 'stream')
    introSound = love.audio.newSource('assets/intro.wav', 'stream')

    love.graphics.setFont(love.graphics.newFont('assets/federation.ttf', 35))
end

function love.draw(dt)
    if playing then
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
            love.graphics.setFont(love.graphics.newFont('assets/federation.ttf', 60))
            love.graphics.print("GAME OVER", love.graphics:getWidth() / 2 - 100, love.graphics:getHeight() / 2 - 180)
            love.graphics.print("Press 'R' to restart", love.graphics:getWidth() / 2 - 180, love.graphics:getHeight() / 2 - 90)
            if love.keyboard.isDown('r') then
                isAlive = true
                love.graphics.setFont(love.graphics.newFont('assets/federation.ttf', 35))
                score = { klingon = 0, federation = 0 }
            end
        end
    else
        love.graphics.setFont(love.graphics.newFont('assets/federation.ttf', 50))
        love.graphics.draw(federationLogo, 100, 180, 0, 0.5, 0.5)
        if dotIsUp then
            love.graphics.draw(dotImg, 115, 410, 0, 0.4, 0.4)
        else
            love.graphics.draw(dotImg, 115, 460, 0, 0.4, 0.4)
        end
        love.graphics.print("START GAME", 145, 390)
        love.graphics.print("CREDITS", 145, 440)
    end
end

function love.keypressed(key)
    if key == "return" and dotIsUp then
        beepSound:play()
        playing = true
    end
    if key == "down" then
        dotIsUp = false
        beepSound:play()
    end
    if key == "up" then
        dotIsUp = true
        beepSound:play()
    end
    if key == "escape" then love.event.quit() end
end

function love.update(dt)
    love.audio.play(introSound)
    introSeconds = introSeconds + dt
    musicSeconds = musicSeconds + dt
    if musicSeconds > 10 and playing then
        love.audio.rewind(backgroundSound)
        love.audio.play(backgroundSound)
        musicSeconds = 0
    end
    if introSeconds > 38 and playing == false then
        love.audio.rewind(introSound)
        love.audio.play(introSound)
        introSeconds = 0
    end

    if playing then
        love.audio.stop(introSound)
        love.graphics.setFont(love.graphics.newFont('assets/federation.ttf', 35))

        if score.klingon == 4 then player.redAlertSound:play() end
        if score.federation == 4 then enemy.redAlertSound:play() end

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
        if canShootTimer < 0 then canShoot = true
        end
        enemyCanShootTimer = enemyCanShootTimer - (1 * dt)
        if enemyCanShootTimer < 0 then enemyCanShoot = true
        end

        if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
            player.fireSound:play()
            newBullet = { x = player.x + (player.img:getWidth() / 2), y = player.y, img = bulletImg }
            table.insert(bullets, newBullet)
            canShoot = false
            canShootTimer = canShootTimerMax
        end

        if love.keyboard.isDown('up', 'w') and enemyCanShoot then
            enemy.fireSound:play()
            newEnemyBullet = { x = enemy.x + (enemy.img:getWidth() / 2), y = enemy.y, img = enemyBulletImg }
            table.insert(enemyBullets, newEnemyBullet)
            enemyCanShoot = false
            enemyCanShootTimer = enemyCanShootTimerMax
        end

        for i, bullet in ipairs(bullets) do
            bullet.y = bullet.y - (250 * dt)
            --remove the bullets when they pass off the screen
            if bullet.y < 0 then table.remove(bullets, i)
            end
        end

        for i, enemyBullet in ipairs(enemyBullets) do
            enemyBullet.y = enemyBullet.y + (250 * dt)
            --remove the bullets when they pass off the screen
            if enemyBullet.y > 750 then table.remove(enemyBullets, i)
            end
        end

        for i, bullet in ipairs(bullets) do
            if checkCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                explosionSound:play()
                table.remove(bullets, i)
                score.federation = score.federation + 1
                if score.federation == 4 then
                    enemy.redAlertSound:play()
                end
                if score.federation > 4 then isAlive = false end
            end
        end

        for i, enemyBullet in ipairs(enemyBullets) do
            if checkCollision(player.x, player.y, player.img:getWidth(), player.img:getHeight(), enemyBullet.x, enemyBullet.y, enemyBullet.img:getWidth(), enemyBullet.img:getHeight()) then
                explosionSound:play()
                table.remove(enemyBullets, i)
                score.klingon = score.klingon + 1
                if score.klingon > 4 then isAlive = false end
            end
        end
    end
end
