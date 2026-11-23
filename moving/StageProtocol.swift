import SpriteKit

// すべてのステージファイルがこのプロトコルに従って実装されます
protocol StageConfiguration {
    var timeLimit: TimeInterval { get }
    func setup(in scene: GameScene)
}
