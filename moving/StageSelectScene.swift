import SpriteKit

class StageSelectScene: SKScene {
    
    // MARK: - プロパティ
    private let totalStages = 10
    private var isConfirmingReset = false
    
    // UIパーツの参照
    private var resetTriggerBtn: SKNode?
    private var confirmGroupNode: SKNode?
    
    // MARK: - ライフサイクル
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupTitle()
        setupStageButtons()
        setupResetUI()
        
        // クリア状況に応じたメッセージ表示のチェック
        checkProgressAndShowMessages()
        
        setupCopyright()
        setupPrivacyPolicy() // ★ 追加：プライバシーポリシーの設定呼び出し
    }
    
    // MARK: - メッセージ表示ロジック
    private func checkProgressAndShowMessages() {
        var clearCount = 0
        var coinClearCount = 0
        
        // 全ステージの状態を確認
        for i in 1...totalStages {
            if UserDefaults.standard.bool(forKey: "stage_cleared_\(i)") {
                clearCount += 1
            }
            if UserDefaults.standard.bool(forKey: "stage_coin_cleared_\(i)") {
                coinClearCount += 1
            }
        }
        
        // 1. 全ステージ通常クリア以上の場合
        if clearCount == totalStages {
            let congratsLabel = SKLabelNode(text: "congulatulation")
            congratsLabel.fontName = "Arial-BoldMT"
            congratsLabel.fontSize = 32
            congratsLabel.fontColor = .white
            congratsLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 160)
            congratsLabel.zPosition = 150
            
            // ふわふわ動くアクション
            let scaleEffect = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.6),
                SKAction.scale(to: 0.9, duration: 0.6)
            ]))
            congratsLabel.run(scaleEffect)
            addChild(congratsLabel)
            
            // 2. さらに全ステージでコインを取得している場合
            if coinClearCount == totalStages {
                let thanksLabel = SKLabelNode(text: "Thank you")
                thanksLabel.fontName = "Arial-BoldMT"
                thanksLabel.fontSize = 40
                thanksLabel.fontColor = .systemYellow // ゴールドクリアに合わせて黄色
                // congulatulation の少し下に配置
                thanksLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 220)
                thanksLabel.zPosition = 150
                
                // キラキラ光るようなフェードアクション
                let fadeEffect = SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: 0.8),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.8)
                ]))
                thanksLabel.run(fadeEffect)
                addChild(thanksLabel)
            }
        }
    }
    
    // MARK: - UI構築
    private func setupTitle() {
        let title = SKLabelNode(text: "STAGE SELECT")
        title.fontName = "Arial-BoldMT"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(title)
    }
    
    private func setupStageButtons() {
        let columns = 5
        let spacing: CGFloat = 70
        let startX = frame.midX - spacing * 2
        let startY = frame.midY + 50
        
        for i in 1...totalStages {
            let row = (i - 1) / columns
            let col = (i - 1) % columns
            
            let isCleared = UserDefaults.standard.bool(forKey: "stage_cleared_\(i)")
            let isCoinCleared = UserDefaults.standard.bool(forKey: "stage_coin_cleared_\(i)")
            
            let button = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 10)
            button.position = CGPoint(x: startX + CGFloat(col) * spacing, y: startY - CGFloat(row) * spacing)
            button.name = "stage_\(i)"
            button.strokeColor = .white
            button.lineWidth = 2
            
            // 色判定
            if isCoinCleared {
                button.fillColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // ゴールド
            } else if isCleared {
                button.fillColor = .systemGreen // 通常
            } else {
                button.fillColor = .darkGray // 未クリア
            }
            
            let label = SKLabelNode(text: "\(i)")
            label.fontName = "Arial-BoldMT"; label.fontSize = 20; label.verticalAlignmentMode = .center; label.name = "stage_\(i)"
            button.addChild(label)
            addChild(button)
        }
    }
    
    private func setupResetUI() {
        let resetRoot = SKNode()
        resetRoot.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(resetRoot)
        
        let trigger = SKShapeNode(rectOf: CGSize(width: 200, height: 45), cornerRadius: 22)
        trigger.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        trigger.strokeColor = .lightGray
        trigger.name = "reset_trigger"
        
        let label = SKLabelNode(text: "CLEAR DATA")
        label.fontName = "Arial-BoldMT"; label.fontSize = 16; label.verticalAlignmentMode = .center; label.name = "reset_trigger"
        trigger.addChild(label)
        resetRoot.addChild(trigger)
        self.resetTriggerBtn = trigger
        
        let confirmGroup = SKNode()
        confirmGroup.isHidden = true
        resetRoot.addChild(confirmGroup)
        self.confirmGroupNode = confirmGroup
        
        let yesBtn = SKShapeNode(rectOf: CGSize(width: 140, height: 45), cornerRadius: 10)
        yesBtn.fillColor = .systemRed; yesBtn.position = CGPoint(x: -80, y: 0); yesBtn.name = "reset_yes"
        let yesLabel = SKLabelNode(text: "YES, RESET")
        yesLabel.fontName = "Arial-BoldMT"; yesLabel.fontSize = 14; yesLabel.verticalAlignmentMode = .center; yesLabel.name = "reset_yes"
        yesBtn.addChild(yesLabel)
        confirmGroup.addChild(yesBtn)
        
        let noBtn = SKShapeNode(rectOf: CGSize(width: 100, height: 45), cornerRadius: 10)
        noBtn.fillColor = .gray; noBtn.position = CGPoint(x: 80, y: 0); noBtn.name = "reset_no"
        let noLabel = SKLabelNode(text: "CANCEL")
        noLabel.fontName = "Arial-BoldMT"; noLabel.fontSize = 14; noLabel.verticalAlignmentMode = .center; noLabel.name = "reset_no"
        noBtn.addChild(noLabel)
        confirmGroup.addChild(noBtn)
    }
    
    // MARK: - クレジット＆プライバシー表記
    private func setupCopyright() {
        let copyrightLabel = SKLabelNode(text: "© 2026 [Yamasina Sho]")
        copyrightLabel.fontName = "ArialMT"
        copyrightLabel.fontSize = 12
        copyrightLabel.fontColor = .gray
        copyrightLabel.alpha = 0.7
        
        // 基準点を右下に設定
        copyrightLabel.horizontalAlignmentMode = .right
        copyrightLabel.verticalAlignmentMode = .bottom
        copyrightLabel.position = CGPoint(x: frame.maxX - 20, y: frame.minY + 20)
        copyrightLabel.zPosition = 500
        addChild(copyrightLabel)
    }
    
    // ★ 追加：プライバシーポリシーのUI設定
    private func setupPrivacyPolicy() {
        let privacyLabel = SKLabelNode(text: "Privacy Policy")
        privacyLabel.fontName = "Arial-BoldMT"
        privacyLabel.fontSize = 12
        privacyLabel.fontColor = .systemBlue // リンクっぽく青色に
        privacyLabel.name = "privacy_policy"
        
        // 基準点を左下に設定
        privacyLabel.horizontalAlignmentMode = .left
        privacyLabel.verticalAlignmentMode = .bottom
        privacyLabel.position = CGPoint(x: frame.minX + 20, y: frame.minY + 20)
        privacyLabel.zPosition = 500
        
        addChild(privacyLabel)
    }
    
    // MARK: - タッチ・遷移
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            guard let n = node.name else { continue }
            if n.hasPrefix("stage_") && !isConfirmingReset {
                if let stageNum = Int(n.replacingOccurrences(of: "stage_", with: "")) {
                    goToGame(stage: stageNum)
                }
                return
            }
            switch n {
            case "reset_trigger": toggleConfirmMode(true)
            case "reset_yes": executeReset()
            case "reset_no": toggleConfirmMode(false)
            case "privacy_policy": openPrivacyPolicy() // ★ 追加：タップ時の処理
            default: break
            }
        }
    }
    
    // ★ 追加：URLを開く処理
    private func openPrivacyPolicy() {
        // ▼ ここに作成したURLを貼り付けてください！
        let urlString = "https://docs.google.com/document/d/1F5A7NQznoniJdhoBDwJEixMzsqBc2E_6XEJY7cGss1Q/edit?usp=sharing"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func toggleConfirmMode(_ confirm: Bool) {
        isConfirmingReset = confirm
        resetTriggerBtn?.isHidden = confirm
        confirmGroupNode?.isHidden = !confirm
        let alphaValue: CGFloat = confirm ? 0.3 : 1.0
        children.forEach { if $0.name?.hasPrefix("stage_") == true { $0.alpha = alphaValue } }
    }
    
    private func executeReset() {
        for i in 1...totalStages {
            UserDefaults.standard.removeObject(forKey: "stage_cleared_\(i)")
            UserDefaults.standard.removeObject(forKey: "stage_coin_cleared_\(i)")
        }
        UserDefaults.standard.synchronize()
        view?.presentScene(StageSelectScene(size: size), transition: SKTransition.crossFade(withDuration: 0.5))
    }
    
    private func goToGame(stage: Int) {
        let gameScene = GameScene(size: size); gameScene.stageNumber = stage; gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: SKTransition.doorway(withDuration: 0.8))
    }
}
