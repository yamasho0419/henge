import SpriteKit

// MARK: - 型・定数定義
enum PlayerShape { case circle, horizontal, vertical }
struct PhysicsCategory {
    static let none: UInt32 = 0; static let ball: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10; static let goal: UInt32 = 0b100
    static let coin: UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - プロパティ
    var stageNumber: Int = 1
    private let maxStage = 10
    private var isCleared = false, isGameOver = false, isCoinCollected = false
    
    // プレイヤー（巨大化・極端変形設定）
    private var ball: SKShapeNode?
    private var currentShape: PlayerShape = .circle
    private var ballRadius: CGFloat = 30.0 // 直径60px
    private let moveSpeed: CGFloat = 380.0 // 一定速度
    
    // 移動フラグ
    private var isMovingUp = false, isMovingDown = false, isMovingLeft = false, isMovingRight = false
    
    var timeLeft: TimeInterval = 30.0 // 初期値（setupObstaclesで各ステージの値に上書きされます）
    private var timerLabel: SKLabelNode?
    private var followers: [SKNode] = [] // 追従敵のリスト
    
    // MARK: - ライフサイクル
    override func didMove(to view: SKView) {
        self.view?.isMultipleTouchEnabled = true
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
        setupGoal()
        setupBall()
        
        // ★ 障害物の配置と同時に、ステージ個別の制限時間が timeLeft にセットされる
        setupObstacles()
        
        setupDPad()
        setupChangeButton()
        // ★ setupObstacles()の後に呼ばないと、初期ラベルに正しい時間が反映されません
        setupTimerLabel()
        setupMenuButton()
    }
    
    // MARK: - ステージ構築を助ける補助関数群
    func createStaticWall(yPos: CGFloat, gapX: CGFloat) {
        let wallWidth = (frame.width - gapX) / 2; let wallSize = CGSize(width: wallWidth, height: 30)
        for i in [-1, 1] {
            let wall = SKShapeNode(rectOf: wallSize); wall.fillColor = .red
            wall.position = CGPoint(x: frame.midX + (wallWidth / 2 + gapX / 2) * CGFloat(i), y: yPos)
            wall.physicsBody = SKPhysicsBody(rectangleOf: wallSize); wall.physicsBody?.isDynamic = false; wall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle; addChild(wall)
        }
    }

    func createCenterWall(yPos: CGFloat, width: CGFloat) {
        let size = CGSize(width: width, height: 30)
        let wall = SKShapeNode(rectOf: size); wall.fillColor = .red; wall.position = CGPoint(x: frame.midX, y: yPos)
        wall.physicsBody = SKPhysicsBody(rectangleOf: size); wall.physicsBody?.isDynamic = false; wall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle; addChild(wall)
    }
    
    func createMovingEnemy(yPos: CGFloat, duration: TimeInterval, range: CGFloat) {
        let size = CGSize(width: 80, height: 25)
        let enemy = SKShapeNode(rectOf: size)
        enemy.fillColor = .red
        enemy.position = CGPoint(x: frame.midX, y: yPos)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: size)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(enemy)
        
        let toRight = SKAction.moveBy(x: range, y: 0, duration: duration)
        let toLeft = SKAction.moveBy(x: -range * 2, y: 0, duration: duration * 2)
        let backToCenter = SKAction.moveBy(x: range, y: 0, duration: duration)
        
        let fullLoop = SKAction.sequence([toRight, toLeft, backToCenter])
        enemy.run(SKAction.repeatForever(fullLoop))
    }
    
    func createFollowingEnemy(pos: CGPoint, speed: CGFloat) {
        let enemy = SKShapeNode(circleOfRadius: 15)
        enemy.fillColor = .systemPink
        enemy.strokeColor = .white
        enemy.position = pos
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(enemy)
        followers.append(enemy)
    }

    func createClockObstacle(pos: CGPoint, length: CGFloat, speed: TimeInterval) {
        let pivot = SKNode(); pivot.position = pos; addChild(pivot)
        let arm = SKShapeNode(rectOf: CGSize(width: length, height: 10)); arm.fillColor = .red; arm.position = CGPoint(x: length/2 + 20, y: 0)
        arm.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: length, height: 10)); arm.physicsBody?.isDynamic = false; arm.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        pivot.addChild(arm); pivot.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi * 2.0), duration: speed)))
    }
    
    func createCoin(pos: CGPoint) {
        let coin = SKShapeNode(circleOfRadius: 15); coin.fillColor = .yellow; coin.strokeColor = .orange; coin.lineWidth = 2; coin.position = pos; coin.name = "coin"
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0); coin.run(SKAction.repeatForever(rotate))
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 15); coin.physicsBody?.isDynamic = false; coin.physicsBody?.categoryBitMask = PhysicsCategory.coin; addChild(coin)
    }

    func createOrbitingObstacle(center: CGPoint, radius: CGFloat, size: CGSize, duration: TimeInterval) {
        let pivotNode = SKNode()
        pivotNode.position = center
        addChild(pivotNode)
        
        let obstacle = SKShapeNode(rectOf: size)
        obstacle.fillColor = .red
        obstacle.strokeColor = .white
        obstacle.position = CGPoint(x: radius, y: 0)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        
        pivotNode.addChild(obstacle)
        
        let rotateAction = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: duration)
        pivotNode.run(SKAction.repeatForever(rotateAction))
    }

    func createPulsingWall(yPos: CGFloat, baseGap: CGFloat, amplitude: CGFloat, speed: TimeInterval) {
        let wallHeight: CGFloat = 30
        let leftWall = SKShapeNode(rectOf: CGSize(width: frame.width, height: wallHeight))
        let rightWall = SKShapeNode(rectOf: CGSize(width: frame.width, height: wallHeight))
        
        leftWall.fillColor = .red; rightWall.fillColor = .red
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: wallHeight))
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: wallHeight))
        leftWall.physicsBody?.isDynamic = false; rightWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        
        addChild(leftWall); addChild(rightWall)
        
        let pulse = SKAction.customAction(withDuration: speed) { node, elapsedTime in
            let t = CGFloat(elapsedTime / CGFloat(speed))
            let currentGap = baseGap + amplitude * sin(t * .pi * 2)
            leftWall.position = CGPoint(x: self.frame.midX - self.frame.width/2 - currentGap/2, y: yPos)
            rightWall.position = CGPoint(x: self.frame.midX + self.frame.width/2 + currentGap/2, y: yPos)
        }
        
        self.run(SKAction.repeatForever(pulse))
    }
    
    func createVerticalMovingEnemy(pos: CGPoint, duration: TimeInterval, range: CGFloat) {
        let size = CGSize(width: 30, height: 250)
        let enemy = SKShapeNode(rectOf: size)
        enemy.fillColor = .red
        enemy.position = pos
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: size)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(enemy)
        
        let moveUp = SKAction.moveBy(x: 0, y: range, duration: duration)
        let moveDown = SKAction.moveBy(x: 0, y: -range * 2, duration: duration * 2)
        let backToStart = SKAction.moveBy(x: 0, y: range, duration: duration)
        
        let sequence = SKAction.sequence([moveUp, moveDown, backToStart])
        enemy.run(SKAction.repeatForever(sequence))
    }
    
    func createQuadrantObstacle(pos: CGPoint, radius: CGFloat, speed: TimeInterval, startAngle: CGFloat, clockwise: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addArc(withCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
        path.close()
        
        let sector = SKShapeNode(path: path.cgPath)
        sector.fillColor = .red
        sector.strokeColor = .white
        sector.lineWidth = 2
        sector.position = pos
        sector.zRotation = startAngle
        
        sector.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        sector.physicsBody?.isDynamic = false
        sector.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(sector)
        
        let rotation = SKAction.rotate(byAngle: clockwise ? -.pi * 2 : .pi * 2, duration: speed)
        sector.run(SKAction.repeatForever(rotation))
    }
    
    func createLowClearanceTunnel(yPos: CGFloat, gapY: CGFloat) {
        let wallWidth = frame.width
        let wallHeight: CGFloat = 60.0
        let wallSize = CGSize(width: wallWidth, height: wallHeight)
        
        for i in [-1, 1] {
            let wall = SKShapeNode(rectOf: wallSize)
            wall.fillColor = .red
            wall.strokeColor = .white
            wall.lineWidth = 1
            
            let offset = (wallHeight / 2) + (gapY / 2)
            wall.position = CGPoint(x: frame.midX, y: yPos + (offset * CGFloat(i)))
            
            wall.physicsBody = SKPhysicsBody(rectangleOf: wallSize)
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            addChild(wall)
        }
    }
    
    func createCrankGate(yPos: CGFloat, gapY: CGFloat) {
        let thickness: CGFloat = 30.0
        let hWidth = frame.width * 0.6
        
        let topWall = SKShapeNode(rectOf: CGSize(width: hWidth, height: thickness))
        topWall.position = CGPoint(x: frame.minX + hWidth/2, y: yPos + gapY)
        
        let bottomWall = SKShapeNode(rectOf: CGSize(width: hWidth, height: thickness))
        bottomWall.position = CGPoint(x: frame.maxX - hWidth/2, y: yPos - gapY)
        
        [topWall, bottomWall].forEach { wall in
            wall.fillColor = .red
            wall.strokeColor = .white
            wall.lineWidth = 2
            wall.physicsBody = SKPhysicsBody(rectangleOf: wall.frame.size)
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            addChild(wall)
        }
    }
    
    func createSineWaveEnemy(pos: CGPoint, hRange: CGFloat, vAmplitude: CGFloat, period: TimeInterval) {
        let enemy = SKShapeNode(circleOfRadius: 20)
        enemy.fillColor = .red
        enemy.strokeColor = .white
        enemy.position = pos
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(enemy)
        
        let moveRight = SKAction.moveBy(x: hRange, y: 0, duration: period)
        let moveLeft = SKAction.moveBy(x: -hRange * 2, y: 0, duration: period * 2)
        let moveBack = SKAction.moveBy(x: hRange, y: 0, duration: period)
        let hSequence = SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft, moveBack]))
        
        let sineAction = SKAction.customAction(withDuration: period * 4) { node, elapsedTime in
            let fraction = elapsedTime / (period * 4)
            let yOffset = vAmplitude * sin(fraction * .pi * 4)
            node.position.y = pos.y + yOffset
        }
        
        enemy.run(hSequence)
        enemy.run(SKAction.repeatForever(sineAction))
    }

    func createSineWaveEnemy(yPos: CGFloat, isStartingLeft: Bool, amplitude: CGFloat, omega: Double) {
        let radius: CGFloat = 20
        let enemy = SKShapeNode(circleOfRadius: radius)
        enemy.fillColor = .red
        enemy.strokeColor = .white
        
        let margin: CGFloat = 40
        let leftX = frame.minX + margin
        let rightX = frame.maxX - margin
        
        let startX = isStartingLeft ? leftX : rightX
        let targetX = isStartingLeft ? rightX : leftX
        enemy.position = CGPoint(x: startX, y: yPos)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        addChild(enemy)
        
        let moveToTarget = SKAction.moveTo(x: targetX, duration: 2.5)
        let moveToStart = SKAction.moveTo(x: startX, duration: 2.5)
        let horizontalSequence = SKAction.sequence([moveToTarget, moveToStart])
        enemy.run(SKAction.repeatForever(horizontalSequence))
        
        let sineAction = SKAction.customAction(withDuration: 10.0) { node, elapsedTime in
            let t = Double(elapsedTime)
            let yOffset = CGFloat(sin(omega * t)) * amplitude
            node.position.y = yPos + yOffset
        }
        enemy.run(SKAction.repeatForever(sineAction))
    }

    // MARK: - 更新・衝突処理
    override func update(_ currentTime: TimeInterval) {
        if isCleared || isGameOver { return }
        timeLeft -= 0.016; timerLabel?.text = String(format: "TIME: %.1f", timeLeft)
        if timeLeft <= 0 { triggerGameOver() }
        guard let b = ball else { return }; let dt = CGFloat(0.016)
        if isMovingUp { b.position.y += moveSpeed * dt }; if isMovingDown { b.position.y -= moveSpeed * dt }
        if isMovingLeft { b.position.x -= moveSpeed * dt }; if isMovingRight { b.position.x += moveSpeed * dt }
        let hW = b.frame.width / 2, hH = b.frame.height / 2
        b.position.x = max(frame.minX + hW, min(frame.maxX - hW, b.position.x)); b.position.y = max(frame.minY + hH, min(frame.maxY - hH, b.position.y))
        
        for f in followers {
            let dx = b.position.x - f.position.x, dy = b.position.y - f.position.y, angle = atan2(dy, dx)
            f.position.x += cos(angle) * 1.2; f.position.y += sin(angle) * 1.2
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (PhysicsCategory.ball | PhysicsCategory.coin) {
            let coin = (contact.bodyA.categoryBitMask == PhysicsCategory.coin) ? contact.bodyA.node : contact.bodyB.node
            coin?.removeFromParent(); isCoinCollected = true; return
        }
        if mask == (PhysicsCategory.ball | PhysicsCategory.obstacle) { if !isCleared && !isGameOver { triggerMiss() } }
        else if mask == (PhysicsCategory.ball | PhysicsCategory.goal) { if !isCleared && !isGameOver { gameClear() } }
    }

    // MARK: - UI・設定・状態管理
    private func gameClear() {
        isCleared = true; resetFlags()
        UserDefaults.standard.set(true, forKey: "stage_cleared_\(stageNumber)")
        if isCoinCollected { UserDefaults.standard.set(true, forKey: "stage_coin_cleared_\(stageNumber)") }
        UserDefaults.standard.synchronize()
        
        let l = SKLabelNode(text: "STAGE \(stageNumber) CLEAR!"); l.position = CGPoint(x: frame.midX, y: frame.midY); l.zPosition = 300; addChild(l)
        
        let wait = SKAction.wait(forDuration: 1.2); let next = SKAction.run { [weak self] in guard let self = self else { return }; if self.stageNumber < self.maxStage { let n = GameScene(size: self.size); n.stageNumber = self.stageNumber + 1; self.view?.presentScene(n, transition: SKTransition.push(with: .left, duration: 0.4)) } else { self.returnToSelectScene() } }
        self.run(SKAction.sequence([wait, next]))
    }
    
    private func setupDPad() { let bP = CGPoint(x: frame.minX + 110, y: frame.minY + 100), m: CGFloat = 65.0; createMoveBtn(name: "up", pos: CGPoint(x: bP.x, y: bP.y + m)); createMoveBtn(name: "down", pos: CGPoint(x: bP.x, y: bP.y - m)); createMoveBtn(name: "left", pos: CGPoint(x: bP.x - m, y: bP.y)); createMoveBtn(name: "right", pos: CGPoint(x: bP.x + m, y: bP.y)) }
    private func createMoveBtn(name: String, pos: CGPoint) { let btn = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 10); btn.fillColor = .gray; btn.alpha = 0.4; btn.position = pos; btn.name = name; btn.zPosition = 100; addChild(btn) }
    private func setupChangeButton() { let btn = SKShapeNode(rectOf: CGSize(width: 90, height: 90), cornerRadius: 45); btn.fillColor = .orange; btn.alpha = 0.6; btn.position = CGPoint(x: frame.maxX - 100, y: frame.minY + 100); btn.name = "change"; btn.zPosition = 100; let l = SKLabelNode(text: "change"); l.fontSize = 18; l.fontName = "Arial-BoldMT"; l.verticalAlignmentMode = .center; l.name = "change"; btn.addChild(l); addChild(btn) }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { updateMovement(with: event); for t in touches { let loc = t.location(in: self); if nodes(at: loc).contains(where: { $0.name == "change" }) { cycleShape() }; if nodes(at: loc).contains(where: { $0.name == "menu" }) { returnToSelectScene() } } }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { updateMovement(with: event) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { updateMovement(with: event) }
    private func updateMovement(with event: UIEvent?) { var u = false, d = false, l = false, r = false; if let touches = event?.allTouches { for t in touches { if t.phase != .ended && t.phase != .cancelled { let loc = t.location(in: self); for n in nodes(at: loc) { if n.name == "up" { u = true }; if n.name == "down" { d = true }; if n.name == "left" { l = true }; if n.name == "right" { r = true } } } } }; isMovingUp = u; isMovingDown = d; isMovingLeft = l; isMovingRight = r }
    
    private func setupBall() { updatePlayerShape() }
    func updatePlayerShape() { let oldPos = ball?.position ?? CGPoint(x: frame.midX, y: frame.minY + 120); ball?.removeFromParent(); switch currentShape { case .circle: ball = SKShapeNode(circleOfRadius: ballRadius); case .horizontal: ball = SKShapeNode(rectOf: CGSize(width: 120, height: 8), cornerRadius: 2); case .vertical: ball = SKShapeNode(rectOf: CGSize(width: 8, height: 120), cornerRadius: 2) }; guard let b = ball else { return }; b.position = oldPos; b.fillColor = (currentShape == .circle) ? .cyan : (currentShape == .horizontal ? .orange : .magenta); b.strokeColor = .white; let pb = SKPhysicsBody(polygonFrom: b.path!); pb.isDynamic = true; pb.allowsRotation = false; pb.friction = 0.0; pb.restitution = 0.0; pb.categoryBitMask = PhysicsCategory.ball; pb.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.goal | PhysicsCategory.coin; pb.collisionBitMask = PhysicsCategory.obstacle; b.physicsBody = pb; addChild(b) }
    
    private func setupTimerLabel() { timerLabel = SKLabelNode(fontNamed: "Arial-BoldMT"); guard let l = timerLabel else { return }; l.fontSize = 28; l.fontColor = .yellow; l.position = CGPoint(x: frame.midX, y: frame.maxY - 110); l.zPosition = 150; l.text = String(format: "TIME: %.1f", timeLeft); addChild(l) }
    private func setupMenuButton() { let btn = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 8); btn.fillColor = .darkGray; btn.strokeColor = .white; btn.position = CGPoint(x: frame.minX + 70, y: frame.maxY - 60); btn.name = "menu"; btn.zPosition = 200; let l = SKLabelNode(text: "MENU"); l.fontSize = 18; l.verticalAlignmentMode = .center; l.name = "menu"; btn.addChild(l); addChild(btn) }
    private func setupGoal() { let goalSize = CGSize(width: frame.width, height: 60); let goal = SKShapeNode(rectOf: goalSize); goal.fillColor = .green; goal.alpha = 0.5; goal.position = CGPoint(x: frame.midX, y: frame.maxY - 30); goal.physicsBody = SKPhysicsBody(rectangleOf: goalSize); goal.physicsBody?.isDynamic = false; goal.physicsBody?.categoryBitMask = PhysicsCategory.goal; addChild(goal) }
    
    private func setupObstacles() {
        // 存在するステージを配列としてまとめる
        let stages: [Int: StageConfiguration] = [
            1: Stage1(),
            2: Stage2(), 3: Stage3(), 4: Stage4(), 5: Stage5(),
            6: Stage6(), 7: Stage7(), 8: Stage8(), 9: Stage9(), 10: Stage10()
            
        ]
        
        if let s = stages[stageNumber] {
            self.timeLeft = s.timeLimit // プロトコルに定義された制限時間を反映
            s.setup(in: self)
        } else {
            self.timeLeft = 30.0 // 未実装ステージが呼ばれた場合の安全策
        }
    }
    
    private func triggerMiss() { isGameOver = true; resetFlags(); let l = SKLabelNode(text: "MISS!"); l.fontSize = 80; l.fontColor = .red; l.position = CGPoint(x: frame.midX, y: frame.midY); l.zPosition = 300; addChild(l); restartCurrentStage() }
    private func triggerGameOver() { isGameOver = true; resetFlags(); let l = SKLabelNode(text: "TIME UP!"); l.fontColor = .red; l.fontSize = 60; l.position = CGPoint(x: frame.midX, y: frame.midY); l.zPosition = 300; addChild(l); restartCurrentStage() }
    private func restartCurrentStage() { let w = SKAction.wait(forDuration: 0.5); let r = SKAction.run { [weak self] in guard let self = self else { return }; let s = GameScene(size: self.size); s.stageNumber = self.stageNumber; s.scaleMode = self.scaleMode; self.view?.presentScene(s, transition: SKTransition.crossFade(withDuration: 0.2)) }; self.run(SKAction.sequence([w, r])) }
    private func returnToSelectScene() { let s = StageSelectScene(size: self.size); s.scaleMode = .resizeFill; self.view?.presentScene(s, transition: SKTransition.doorsCloseHorizontal(withDuration: 0.8)) }
    private func cycleShape() { switch currentShape { case .circle: currentShape = .horizontal; case .horizontal: currentShape = .vertical; case .vertical: currentShape = .circle }; updatePlayerShape(); ball?.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.05), SKAction.scale(to: 1.0, duration: 0.05)])) }
    private func resetFlags() { isMovingUp = false; isMovingDown = false; isMovingLeft = false; isMovingRight = false; followers = [] }
}
