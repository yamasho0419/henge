import SpriteKit

// すべてのステージファイルがこのプロトコルに従って実装されます
protocol StageConfiguration {
    var timeLimit: TimeInterval { get } // ★ ここを追加
    func setup(in scene: GameScene)
}
