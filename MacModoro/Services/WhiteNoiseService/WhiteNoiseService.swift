import AVFoundation
import Foundation

enum WhiteNoiseType: String, CaseIterable, Identifiable {
    case none = "없음"
    case rain = "빗소리"
    case cafe = "카페"
    case fire = "모닥불"
    case ocean = "파도"
    case forest = "숲"
    case fan = "선풍기"

    var id: String { rawValue }

    var frequency: Double {
        switch self {
        case .none: return 0
        case .rain: return 800
        case .cafe: return 600
        case .fire: return 400
        case .ocean: return 300
        case .forest: return 1200
        case .fan: return 500
        }
    }

    var secondaryFrequency: Double {
        switch self {
        case .none: return 0
        case .rain: return 2000
        case .cafe: return 1500
        case .fire: return 200
        case .ocean: return 150
        case .forest: return 3000
        case .fan: return 1000
        }
    }
}

final class WhiteNoiseService: ObservableObject {
    static let shared = WhiteNoiseService()

    @Published var currentNoise: WhiteNoiseType = .none
    @Published var volume: Float = 0.5

    private var audioEngine: AVAudioEngine?
    private var noiseNode: AVAudioSourceNode?

    private var phase1: Double = 0
    private var phase2: Double = 0

    private init() {}

    func play(_ type: WhiteNoiseType) {
        stop()
        guard type != .none else {
            currentNoise = .none
            return
        }

        currentNoise = type

        let engine = AVAudioEngine()
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        let freq1 = type.frequency
        let freq2 = type.secondaryFrequency

        phase1 = 0
        phase2 = 0

        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let vol = Double(self.volume)

            for frame in 0..<Int(frameCount) {
                // 두 개의 사인파를 합성 + 랜덤 노이즈로 자연스러운 소리 생성
                let noise = Double.random(in: -0.3...0.3)
                let sin1 = sin(self.phase1 * 2.0 * .pi) * 0.2
                let sin2 = sin(self.phase2 * 2.0 * .pi) * 0.15
                let sample = Float((sin1 + sin2 + noise) * vol * 0.3)

                for buffer in bufferList {
                    let buf = buffer.mData?.assumingMemoryBound(to: Float.self)
                    buf?[frame] = sample
                }

                self.phase1 += freq1 / sampleRate
                self.phase2 += freq2 / sampleRate
                if self.phase1 > 1 { self.phase1 -= 1 }
                if self.phase2 > 1 { self.phase2 -= 1 }
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: mainMixer, format: format)

        do {
            try engine.start()
            audioEngine = engine
            noiseNode = sourceNode
        } catch {
            print("WhiteNoise failed: \(error)")
        }
    }

    func stop() {
        audioEngine?.stop()
        if let node = noiseNode {
            audioEngine?.detach(node)
        }
        audioEngine = nil
        noiseNode = nil
        currentNoise = .none
    }

    func setVolume(_ vol: Float) {
        volume = max(0, min(1, vol))
    }
}
