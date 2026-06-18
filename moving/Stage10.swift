import SpriteKit

class Stage10: StageConfiguration {
    let timeLimit: TimeInterval = 10.0
    func setup(in scene: GameScene) {
        let midY = scene.frame.midY
        
        // 5つの障害物配置データ (y座標, 左開始か, 振幅, ω)
        let enemySettings: [(y: CGFloat, isLeft: Bool, amp: CGFloat, omega: Double)] = [
            (midY - 240, true,  60.0, 3.0), // 1: 左開始
            (midY - 120, false, 50.0, 2.5), // 2: 右開始
            (midY,       true,  70.0, 3.5), // 3: 左開始
            (midY + 120, false, 55.0, 2.8), // 4: 右開始
            (midY + 240, true,  65.0, 3.2)  // 5: 左開始
        ]
        
        for setting in enemySettings {
            scene.createSineWaveEnemy(
                yPos: setting.y,
                isStartingLeft: setting.isLeft,
                amplitude: setting.amp,
                omega: setting.omega
            )
        }
        
        // ゴール地点のコインを最上部に配置
        scene.createCoin(pos: CGPoint(x: scene.frame.midX, y: scene.frame.maxY - 100))
    }
}
