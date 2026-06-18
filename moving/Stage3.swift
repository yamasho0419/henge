import SpriteKit

class Stage3: StageConfiguration {
    let timeLimit: TimeInterval = 15.0
    func setup(in scene: GameScene) {
        let midX = scene.frame.midX
        let midY = scene.frame.midY
        let width = scene.frame.width
        
        // 敵の幅(80)を考慮した、画面端ギリギリまでの振幅
        let maxRange = (width - 80) / 2
        
        // 下段（2つ）：中央で一瞬だけ隙間ができる「ハサミ」のような動き
        scene.createMovingEnemy(yPos: midY - 220, duration: 2.0, range: maxRange)
        scene.createMovingEnemy(yPos: midY - 180, duration: 2.2, range: -maxRange) // マイナスで左からスタート
        
        // 中段（1つ）：真ん中を横断する「門番」
        scene.createMovingEnemy(yPos: midY, duration: 1.5, range: maxRange)
        scene.createCoin(pos: CGPoint(x: midX, y: midY)) // コインは真ん中に
        
        // 上段（2つ）：高速スイープ。ここを抜けるには「横棒」への変身が不可欠
        scene.createMovingEnemy(yPos: midY + 180, duration: 0.8, range: maxRange)
        scene.createMovingEnemy(yPos: midY + 220, duration: 1.0, range: -maxRange)
    }
}
