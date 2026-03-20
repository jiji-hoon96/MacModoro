import Foundation

struct BackgroundPack: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var category: BackgroundCategory
    var previewURL: URL
    var downloadURL: URL
    var fileSizeMB: Double

    var localURL: URL {
        AssetManager.shared.backgroundDirectory.appendingPathComponent("\(id).jpg")
    }
}

enum BackgroundCategory: String, Codable, CaseIterable, Identifiable {
    case urban = "도시"
    case nature = "자연"
    case interior = "실내"
    case sky = "하늘"

    var id: String { rawValue }
}

struct BackgroundCatalog {
    static let curated: [BackgroundPack] = [
        // Urban / City
        BackgroundPack(
            id: "potsdamer_platz",
            name: "Potsdamer Platz (Berlin)",
            category: .urban,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/potsdamer_platz.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/potsdamer_platz.jpg")!,
            fileSizeMB: 0.8
        ),
        BackgroundPack(
            id: "urban_street_01",
            name: "Urban Street",
            category: .urban,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/urban_street_01.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/urban_street_01.jpg")!,
            fileSizeMB: 0.7
        ),
        BackgroundPack(
            id: "shanghai_bund",
            name: "Shanghai Bund",
            category: .urban,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/shanghai_bund.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/shanghai_bund.jpg")!,
            fileSizeMB: 0.9
        ),
        BackgroundPack(
            id: "st_peters_square_night",
            name: "St. Peter's Square Night",
            category: .urban,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/st_peters_square_night.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/st_peters_square_night.jpg")!,
            fileSizeMB: 0.6
        ),
        // Nature
        BackgroundPack(
            id: "rosendal_plains",
            name: "Rosendal Plains",
            category: .nature,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/rosendal_plains_2.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/rosendal_plains_2.jpg")!,
            fileSizeMB: 0.5
        ),
        BackgroundPack(
            id: "autumn_park",
            name: "Autumn Park",
            category: .nature,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/autumn_park.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/autumn_park.jpg")!,
            fileSizeMB: 0.6
        ),
        BackgroundPack(
            id: "syferfontein_0d_clear",
            name: "Clear Field",
            category: .nature,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/syferfontein_0d_clear_puresky.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/syferfontein_0d_clear_puresky.jpg")!,
            fileSizeMB: 0.4
        ),
        // Interior
        BackgroundPack(
            id: "medieval_cafe",
            name: "Medieval Cafe",
            category: .interior,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/medieval_cafe_1.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/medieval_cafe_1.jpg")!,
            fileSizeMB: 0.7
        ),
        BackgroundPack(
            id: "studio_small_09",
            name: "Studio Small",
            category: .interior,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/studio_small_09.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/studio_small_09.jpg")!,
            fileSizeMB: 0.3
        ),
        // Sky
        BackgroundPack(
            id: "kloofendal_48d_partly_cloudy",
            name: "Partly Cloudy Sky",
            category: .sky,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/kloofendal_48d_partly_cloudy_puresky.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/kloofendal_48d_partly_cloudy_puresky.jpg")!,
            fileSizeMB: 0.3
        ),
        BackgroundPack(
            id: "sunset_in_the_chalk_quarry",
            name: "Sunset Quarry",
            category: .sky,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/sunset_in_the_chalk_quarry.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/sunset_in_the_chalk_quarry.jpg")!,
            fileSizeMB: 0.4
        ),
        BackgroundPack(
            id: "kiara_1_dawn",
            name: "Dawn Sky",
            category: .sky,
            previewURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/kiara_1_dawn.jpg")!,
            downloadURL: URL(string: "https://dl.polyhaven.org/file/ph-assets/HDRIs/extra/Tonemapped%20JPG/kiara_1_dawn.jpg")!,
            fileSizeMB: 0.3
        ),
    ]

    static func packs(for category: BackgroundCategory) -> [BackgroundPack] {
        curated.filter { $0.category == category }
    }
}
