import SpriteKit

class Stage4: StageConfiguration {
    let timeLimit: TimeInterval = 40.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        let width = scene.frame.width
        
        // 1. ピンクの追従者（画面最下部からスタート）
        scene.createFollowingEnemy(pos: CGPoint(x: scene.frame.minX + 50, y: scene.frame.minY + 50), speed: 1.2)
        
        // 2. 5つの固定壁の設定
        let wallH: CGFloat = 30
        let gapV: CGFloat = 38  // 円(60)は通れず、横棒(8)なら通れる高さ
        let passW: CGFloat = 180 // 横棒(120)が余裕を持って通れる幅
        let barW = width - passW
        
        // 縦の間隔を詰め、シビアな変身タイミングを要求
        let stepY: CGFloat = wallH + gapV + 10
        
        // ★ 全体的に上へ移動（startYを -250 から -100 へ）
        let startY = midY - 100
        
        // 1段目：右側に通路
        addStaticBar(scene: scene, x: scene.frame.minX + barW/2, y: startY, w: barW, h: wallH)
        
        // 2段目：左側に通路
        addStaticBar(scene: scene, x: scene.frame.maxX - barW/2, y: startY + stepY, w: barW, h: wallH)
        
        // 3段目：中央通路 ＋ 紫のコイン
        addStaticBar(scene: scene, x: scene.frame.minX + barW/4, y: startY + stepY * 2, w: barW/2, h: wallH)
        addStaticBar(scene: scene, x: scene.frame.maxX - barW/4, y: startY + stepY * 2, w: barW/2, h: wallH)
        scene.createCoin(pos: CGPoint(x: midX, y: startY + stepY * 2))
        
        // 4段目：右側に通路
        addStaticBar(scene: scene, x: scene.frame.minX + barW/2, y: startY + stepY * 3, w: barW, h: wallH)
        
        // 5段目：左側に通路（ゴールの直前）
        addStaticBar(scene: scene, x: scene.frame.maxX - barW/2, y: startY + stepY * 4, w: barW, h: wallH)
    }
    
    private func addStaticBar(scene: GameScene, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        let bar = SKShapeNode(rectOf: CGSize(width: w, height: h))
        bar.fillColor = .red; bar.position = CGPoint(x: x, y: y); bar.strokeColor = .white; bar.lineWidth = 1
        bar.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        bar.physicsBody?.isDynamic = false; bar.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        scene.addChild(bar)
    }
}
