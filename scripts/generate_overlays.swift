import Cocoa

struct CaptionItem {
    let start: Double
    let end: Double
    let text: String
    let highlight: String?
}

struct VideoConfig {
    let id: String
    let badgeText: String
    let badgeColor: NSColor
    let hookTitle: String
    let ctaText: String
    let captions: [CaptionItem]
}

func hexColor(_ hex: UInt32, alpha: CGFloat = 1.0) -> NSColor {
    return NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255.0,
        green: CGFloat((hex >> 8) & 0xff) / 255.0,
        blue: CGFloat(hex & 0xff) / 255.0,
        alpha: alpha
    )
}

func renderPNG(to path: String, drawBlock: (CGContext) -> Void) {
    let width: CGFloat = 1080
    let height: CGFloat = 1920
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    
    guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Failed to create CGContext")
        return
    }
    
    let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.current = graphicsContext
    
    drawBlock(context)
    
    if let cgImage = context.makeImage() {
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            try? pngData.write(to: URL(fileURLWithPath: path))
        }
    }
}

func drawHookCard(badge: String, badgeColor: NSColor, title: String, context: CGContext) {
    // Card Background Box at Top (Action-Safe Area)
    let cardRect = NSRect(x: 60, y: 1370, width: 960, height: 320)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 32, yRadius: 32)
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -10), blur: 28, color: NSColor.black.withAlphaComponent(0.9).cgColor)
    hexColor(0x0E1118, alpha: 0.94).setFill()
    cardPath.fill()
    context.restoreGState()
    
    // Glowing Border
    hexColor(0xFFDE59, alpha: 0.9).setStroke()
    cardPath.lineWidth = 4.5
    cardPath.stroke()
    
    // Badge pill
    let badgeFont = NSFont(name: "Arial-BoldMT", size: 30) ?? NSFont.boldSystemFont(ofSize: 30)
    let badgeAttrs: [NSAttributedString.Key: Any] = [
        .font: badgeFont,
        .foregroundColor: NSColor.white
    ]
    let badgeSize = (badge as NSString).size(withAttributes: badgeAttrs)
    let pillRect = NSRect(x: 95, y: 1615, width: badgeSize.width + 40, height: 50)
    let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: 25, yRadius: 25)
    badgeColor.setFill()
    pillPath.fill()
    (badge as NSString).draw(at: NSPoint(x: pillRect.origin.x + 20, y: pillRect.origin.y + 9), withAttributes: badgeAttrs)
    
    // Title Text (with plenty of breathing room)
    let titleFont = NSFont(name: "Arial-Black", size: 42) ?? NSFont.boldSystemFont(ofSize: 42)
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineSpacing = 8
    
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: titleFont,
        .foregroundColor: NSColor.white,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.5,
        .paragraphStyle: style
    ]
    
    let textRect = NSRect(x: 80, y: 1400, width: 920, height: 195)
    (title as NSString).draw(in: textRect, withAttributes: titleAttrs)
}

func drawCTA(text: String, context: CGContext) {
    let ctaRect = NSRect(x: 80, y: 380, width: 920, height: 130)
    let ctaPath = NSBezierPath(roundedRect: ctaRect, xRadius: 32, yRadius: 32)
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -8), blur: 24, color: NSColor.black.withAlphaComponent(0.92).cgColor)
    hexColor(0xFE2C55, alpha: 0.96).setFill() // TikTok Red
    ctaPath.fill()
    context.restoreGState()
    
    hexColor(0xFFFFFF, alpha: 0.95).setStroke()
    ctaPath.lineWidth = 4.5
    ctaPath.stroke()
    
    let font = NSFont(name: "Arial-Black", size: 38) ?? NSFont.boldSystemFont(ofSize: 38)
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .paragraphStyle: style
    ]
    let textY = ctaRect.origin.y + (ctaRect.height - 48) / 2
    (text as NSString).draw(in: NSRect(x: 90, y: textY, width: 900, height: 55), withAttributes: attrs)
}

func drawCaption(text: String, highlight: String?, context: CGContext) {
    let words = text.components(separatedBy: " ")
    let baseFont = NSFont(name: "Arial-Black", size: 48) ?? NSFont.boldSystemFont(ofSize: 48)
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    
    let attrStr = NSMutableAttributedString()
    for (idx, w) in words.enumerated() {
        let isHighlighted = (highlight != nil && w.lowercased().contains(highlight!.lowercased()))
        let color = isHighlighted ? hexColor(0xFFDE59) : NSColor.white
        
        let wordAttrs: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: color,
            .strokeColor: NSColor.black,
            .strokeWidth: -4.5,
            .paragraphStyle: style
        ]
        attrStr.append(NSAttributedString(string: (idx > 0 ? " " : "") + w, attributes: wordAttrs))
    }
    
    let boxWidth: CGFloat = 980
    let boxHeight: CGFloat = 140
    let boxX = (1080 - boxWidth) / 2
    let boxY: CGFloat = 220
    
    let bgRect = NSRect(x: boxX, y: boxY, width: boxWidth, height: boxHeight)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 24, yRadius: 24)
    hexColor(0x000000, alpha: 0.70).setFill()
    bgPath.fill()
    
    let textRect = NSRect(x: boxX + 20, y: boxY + (boxHeight - 70) / 2, width: boxWidth - 40, height: 80)
    attrStr.draw(in: textRect)
}

// DEFINISI 5 KONTEN MARKETING VIDEO
let videoConfigs: [VideoConfig] = [
    VideoConfig(
        id: "video_01",
        badgeText: "🔥 OUTFIT VIRAL 2026",
        badgeColor: hexColor(0xFE2C55),
        hookTitle: "JANGAN SALAH PILIH!\nINI WARNA CORDUROY PALING GANTENG!",
        ctaText: "👉 KLIK KERANJANG KUNING SEKARANG!",
        captions: [
            CaptionItem(start: 0.0, end: 5.0, text: "Kalian wajib tahu jaket corduroy ini!", highlight: "corduroy"),
            CaptionItem(start: 5.0, end: 10.0, text: "Warna dark brown ini bener-bener mewah!", highlight: "dark brown"),
            CaptionItem(start: 10.0, end: 15.5, text: "Tekstur corduroy tebal dan timbul rapi", highlight: "tebal"),
            CaptionItem(start: 15.5, end: 21.0, text: "Cuttingan drop shoulder bikin badan tegap", highlight: "tegap"),
            CaptionItem(start: 21.0, end: 25.5, text: "Dipakai harian nyaman nggak bikin gerah", highlight: "nyaman"),
            CaptionItem(start: 25.5, end: 30.0, text: "Checkout di keranjang kuning sekarang!", highlight: "checkout")
        ]
    ),
    VideoConfig(
        id: "video_02",
        badgeText: "⭐ OUTFIT FORMULA",
        badgeColor: hexColor(0x25F4EE),
        hookTitle: "COMBO MAUT INI WAJIB PUNYA\nMINIMAL SATU DI LEMARI KAMU!",
        ctaText: "🏷️ KLAIM DISKON LIVE DI ETALASE 1!",
        captions: [
            CaptionItem(start: 0.0, end: 5.0, text: "Ini combo paling aman tapi paling ganteng!", highlight: "ganteng"),
            CaptionItem(start: 5.0, end: 10.5, text: "Jaket corduroy hitam dipadu kaos putih pocket", highlight: "hitam"),
            CaptionItem(start: 10.5, end: 16.0, text: "Warna hitamnya pekat, kancingnya kokoh banget", highlight: "kokoh"),
            CaptionItem(start: 16.0, end: 21.5, text: "Saku depan multifungsi muat dompet dan hp", highlight: "multifungsi"),
            CaptionItem(start: 21.5, end: 26.0, text: "Cocok buat nongkrong, ngedate, atau kuliah", highlight: "nongkrong"),
            CaptionItem(start: 26.0, end: 30.0, text: "Klaim diskon live di etalase satu sekarang!", highlight: "etalase")
        ]
    ),
    VideoConfig(
        id: "video_03",
        badgeText: "🔍 QUALITY CHECK 10/10",
        badgeColor: hexColor(0xF59E0B),
        hookTitle: "JANGAN DULU BELI!\nSEBELUM LIHAT DETAIL JAHITAN INI!",
        ctaText: "⚡ STOK TERBATAS - AMBIL SEKARANG!",
        captions: [
            CaptionItem(start: 0.0, end: 5.0, text: "Coba perhatiin detail jahitannya serapi ini!", highlight: "detail"),
            CaptionItem(start: 5.0, end: 10.5, text: "Bahan corduroy tebal tapi tetap lemas adem", highlight: "adem"),
            CaptionItem(start: 10.5, end: 16.0, text: "Kancing metalik kuat nggak gampang copot", highlight: "kuat"),
            CaptionItem(start: 16.0, end: 21.5, text: "Jahitan double stitch di bahu dan lengan", highlight: "double stitch"),
            CaptionItem(start: 21.5, end: 26.0, text: "Kualitas distro premium harga terjangkau", highlight: "premium"),
            CaptionItem(start: 26.0, end: 30.0, text: "Jangan sampai kehabisan size favorit kamu!", highlight: "kehabisan")
        ]
    ),
    VideoConfig(
        id: "video_04",
        badgeText: "👀 BATTLE WARNA VIRAL",
        badgeColor: hexColor(0xEC4899),
        hookTitle: "PILIH MAROON ATAU HITAM?\nKALIAN LEBIH COCOK YANG MANA?",
        ctaText: "💬 TULIS DI KOMENTAR TIM MANA!",
        captions: [
            CaptionItem(start: 0.0, end: 5.0, text: "Banyak yang bingung mau maroon atau hitam", highlight: "maroon"),
            CaptionItem(start: 5.0, end: 10.5, text: "Warna maroon bikin kulit keliatan lebih cerah", highlight: "cerah"),
            CaptionItem(start: 10.5, end: 16.0, text: "Cuttingan slim fit modern tapi tetep leluasa", highlight: "slim fit"),
            CaptionItem(start: 16.0, end: 21.5, text: "Sedangkan hitam wajib punya buat look formal", highlight: "formal"),
            CaptionItem(start: 21.5, end: 26.0, text: "Dua-duanya sama-sama keren buat mix match", highlight: "keren"),
            CaptionItem(start: 26.0, end: 30.0, text: "Tulis di kolom komentar kalian tim mana!", highlight: "komentar")
        ]
    ),
    VideoConfig(
        id: "video_05",
        badgeText: "📏 SIZING & FIT GUIDE",
        badgeColor: hexColor(0x10B981),
        hookTitle: "TB 172 BB 65 PAKAI SIZE APA?\nINI HASIL TRY-ON NYATA DI MODEL!",
        ctaText: "📌 PANDUAN SIZE LENGKAP DI BIO!",
        captions: [
            CaptionItem(start: 0.0, end: 5.0, text: "Buat yang ragu milih size, tonton ini!", highlight: "size"),
            CaptionItem(start: 5.0, end: 10.5, text: "Tinggi 172 berat 65 pas banget pakai size L", highlight: "size L"),
            CaptionItem(start: 10.5, end: 16.0, text: "Panjang jaket pas di pinggang rapi banget", highlight: "rapi"),
            CaptionItem(start: 16.0, end: 21.5, text: "Bahu nyaman nggak ketarik saat motoran", highlight: "nyaman"),
            CaptionItem(start: 21.5, end: 26.0, text: "Dipadu jeans dan topi auto keliatan macho", highlight: "macho"),
            CaptionItem(start: 26.0, end: 30.0, text: "Cek panduan ukuran lengkap di keranjang!", highlight: "panduan ukuran")
        ]
    )
]

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/overlays"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true, attributes: nil)

for cfg in videoConfigs {
    let vidDir = "\(outDir)/\(cfg.id)"
    try? FileManager.default.createDirectory(atPath: vidDir, withIntermediateDirectories: true, attributes: nil)
    
    // 1. Hook card
    renderPNG(to: "\(vidDir)/hook.png") { ctx in
        drawHookCard(badge: cfg.badgeText, badgeColor: cfg.badgeColor, title: cfg.hookTitle, context: ctx)
    }
    
    // 2. CTA banner
    renderPNG(to: "\(vidDir)/cta.png") { ctx in
        drawCTA(text: cfg.ctaText, context: ctx)
    }
    
    // 3. Captions
    for (i, cap) in cfg.captions.enumerated() {
        renderPNG(to: "\(vidDir)/cap_\(i).png") { ctx in
            drawCaption(text: cap.text, highlight: cap.highlight, context: ctx)
        }
    }
    print("Generated all overlays for \(cfg.id)")
}
