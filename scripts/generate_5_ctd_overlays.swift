import Cocoa

let width: CGFloat = 1080
let height: CGFloat = 1920

let baseDir = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/ctd_batch_5"
let logoPath = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/brand/Logo Broguy Panjang.png"

func renderExactPNG(to path: String, drawBlock: (CGContext) -> Void) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let context = CGContext(
        data: nil,
        width: Int(width),
        height: Int(height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else { return }

    let gContext = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.current = gContext

    drawBlock(context)

    if let cgImage = context.makeImage() {
        let rep = NSBitmapImageRep(cgImage: cgImage)
        if let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: path))
        }
    }
}

let orangeColor = NSColor(red: 1.0, green: 0.40, blue: 0.0, alpha: 1.0) // #FF6600
let darkCharcoal = NSColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
let mutedGrey = NSColor(red: 0.38, green: 0.43, blue: 0.50, alpha: 1.0)
let lightGrey = NSColor(red: 0.55, green: 0.60, blue: 0.66, alpha: 1.0)

struct ClipMeta {
    let id: String
    let badgeText: String
    let headlineParts: [(text: String, isHighlight: Bool)]
    let subheadline: String
    let ctaText: String
}

let clips: [ClipMeta] = [
    ClipMeta(
        id: "clip_01",
        badgeText: "Fashion Info",
        headlineParts: [
            ("OM DEDDY KAGET: '", false),
            ("BRAND LOKAL DARI KUNINGAN, ", true),
            ("TAPI ", false),
            ("BAHANNYA BAGUS BANGET!'", true)
        ],
        subheadline: "Review Jujur Brand Lokal Pilihan Om Deddy di Close The Door",
        ctaText: "🛒 DUKUNG BRAND LOKAL • CEK KERANJANG KUNING SEKARANG!"
    ),
    ClipMeta(
        id: "clip_02",
        badgeText: "Fashion Info",
        headlineParts: [
            ("OM DEDDY: '", false),
            ("SERIUSAN HARGA 70 RIBUAN? ", true),
            ("MURAH TAPI ", false),
            ("BAHANNYA BAGUS BANGET!'", true)
        ],
        subheadline: "Kualitas Kaos Distro Mewah dengan Harga Super Terjangkau",
        ctaText: "🛒 KLAIM VOUCHER DISKON DI KERANJANG KUNING SEKARANG!"
    ),
    ClipMeta(
        id: "clip_03",
        badgeText: "Rekomendasi",
        headlineParts: [
            ("OM DEDDY: '", false),
            ("GUA AMBIL SATU BUAT GUA PAKE! ", true),
            ("BUAT 70 RIBU INI ", false),
            ("LUAR BIASA!'", true)
        ],
        subheadline: "Kaos Pria yang Bikin Om Deddy Langsung Mau Pake Sendiri",
        ctaText: "🛒 AMANKAN SIZE KAMU DI KERANJANG KUNING SEKARANG!"
    ),
    ClipMeta(
        id: "clip_04",
        badgeText: "Review Jujur",
        headlineParts: [
            ("'", false),
            ("DIKASIH LOGO BRAND MEWAH GUCCI, ORANG JUGA PERCAYA! ", true),
            ("SAKING ", false),
            ("BAGUSNYA BAHAN INI!'", true)
        ],
        subheadline: "Kualitas Kain Standar Internasional Tanpa Harga Jutaan",
        ctaText: "🛒 DAPATKAN KUALITAS MEWAH DI KERANJANG KUNING!"
    ),
    ClipMeta(
        id: "clip_05",
        badgeText: "Rekomendasi",
        headlineParts: [
            ("OM DEDDY: '", false),
            ("GUA GAK BOHONG, ", true),
            ("KETIKA DIPEGANG ", false),
            ("BAHANNYA ENAK BANGET!'", true)
        ],
        subheadline: "Rekomendasi Nyata Tekstur Bahan Lembut & Adem Seharian",
        ctaText: "🛒 BUKTIKAN SENDIRI DI KERANJANG KUNING SEKARANG!"
    )
]

for meta in clips {
    let clipDir = "\(baseDir)/\(meta.id)"
    try? FileManager.default.createDirectory(atPath: clipDir, withIntermediateDirectories: true, attributes: nil)

    // 1. Hook Card
    renderExactPNG(to: "\(clipDir)/hook_card.png") { ctx in
        let cPara = NSMutableParagraphStyle()
        cPara.alignment = .center

        // Official White Logo
        if let logoImage = NSImage(contentsOfFile: logoPath) {
            let targetLogoW: CGFloat = 260
            let targetLogoH: CGFloat = targetLogoW * (209.0 / 828.0)
            let logoX: CGFloat = 70
            let logoY: CGFloat = 1765
            logoImage.draw(in: NSRect(x: logoX, y: logoY, width: targetLogoW, height: targetLogoH))
        }

        // Top Right Badge
        let badgeW: CGFloat = 220
        let badgeH: CGFloat = 56
        let badgeX: CGFloat = width - badgeW - 70
        let badgeY: CGFloat = 1768
        let badgePath = NSBezierPath(roundedRect: NSRect(x: badgeX, y: badgeY, width: badgeW, height: badgeH), xRadius: 28, yRadius: 28)
        orangeColor.setFill()
        badgePath.fill()

        let bAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: NSColor.white,
            .paragraphStyle: cPara
        ]
        let bText = NSAttributedString(string: meta.badgeText, attributes: bAttrs)
        bText.draw(in: NSRect(x: badgeX, y: badgeY + 12, width: badgeW, height: 35))

        // Lower Third Floating White Card
        let cardW: CGFloat = 960
        let cardH: CGFloat = 470
        let cardX: CGFloat = 60
        let cardY: CGFloat = 300
        let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 32, color: NSColor(white: 0, alpha: 0.40).cgColor)

        let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 42, yRadius: 42)

        // Triangle pointer
        let ptrX: CGFloat = cardX + cardW - 220
        let ptrY: CGFloat = cardY + cardH
        let pointerPath = NSBezierPath()
        pointerPath.move(to: NSPoint(x: ptrX, y: ptrY))
        pointerPath.line(to: NSPoint(x: ptrX + 35, y: ptrY + 36))
        pointerPath.line(to: NSPoint(x: ptrX + 70, y: ptrY))
        pointerPath.close()

        NSColor.white.setFill()
        cardPath.fill()
        pointerPath.fill()
        ctx.restoreGState()

        NSColor(white: 0.90, alpha: 1.0).setStroke()
        cardPath.lineWidth = 1.5
        cardPath.stroke()

        // Brand Pill: BROGUY.ID
        let pillW: CGFloat = 190
        let pillH: CGFloat = 46
        let pillX: CGFloat = cardX + 50
        let pillY: CGFloat = cardY + cardH - 75
        let pillPath = NSBezierPath(roundedRect: NSRect(x: pillX, y: pillY, width: pillW, height: pillH), xRadius: 23, yRadius: 23)
        orangeColor.setFill()
        pillPath.fill()

        let pillAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 22),
            .foregroundColor: NSColor.white,
            .paragraphStyle: cPara
        ]
        let pillText = NSAttributedString(string: "BROGUY.ID", attributes: pillAttrs)
        pillText.draw(in: NSRect(x: pillX, y: pillY + 10, width: pillW, height: 30))

        // Headline Quotes
        let headPara = NSMutableParagraphStyle()
        headPara.lineSpacing = 6
        headPara.alignment = .left

        let regularHeadFont = NSFont(name: "Georgia-Bold", size: 36) ?? NSFont.boldSystemFont(ofSize: 36)
        let headlineM = NSMutableAttributedString()

        for part in meta.headlineParts {
            headlineM.append(NSAttributedString(string: part.text, attributes: [
                .font: regularHeadFont,
                .foregroundColor: part.isHighlight ? orangeColor : darkCharcoal,
                .paragraphStyle: headPara
            ]))
        }

        headlineM.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 260, width: cardW - 100, height: 170))

        // Subheadline
        let subPara = NSMutableParagraphStyle()
        subPara.alignment = .left
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
            .foregroundColor: mutedGrey,
            .paragraphStyle: subPara
        ]
        let subText = NSAttributedString(string: meta.subheadline, attributes: subAttrs)
        subText.draw(in: NSRect(x: cardX + 50, y: cardY + 75, width: cardW - 100, height: 35))

        // Source Attribution
        let srcAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .regular),
            .foregroundColor: lightGrey,
            .paragraphStyle: subPara
        ]
        let srcText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier", attributes: srcAttrs)
        srcText.draw(in: NSRect(x: cardX + 50, y: cardY + 36, width: cardW - 100, height: 28))
    }

    // 2. CTA Banner
    renderExactPNG(to: "\(clipDir)/cta_banner.png") { ctx in
        let ctaW: CGFloat = 960
        let ctaH: CGFloat = 110
        let ctaX: CGFloat = 60
        let ctaY: CGFloat = 150

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 24, color: NSColor(red: 1.0, green: 0.35, blue: 0.0, alpha: 0.55).cgColor)

        let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 36, yRadius: 36)
        orangeColor.setFill()
        ctaPath.fill()
        ctx.restoreGState()

        NSColor.white.withAlphaComponent(0.4).setStroke()
        ctaPath.lineWidth = 2
        ctaPath.stroke()

        let ctaPara = NSMutableParagraphStyle()
        ctaPara.alignment = .center
        let ctaAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 28),
            .foregroundColor: NSColor.white,
            .paragraphStyle: ctaPara
        ]
        let ctaText = NSAttributedString(string: meta.ctaText, attributes: ctaAttrs)
        ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 34, width: ctaW - 40, height: 50))
    }
}

print("Generated 5 CTD clip overlay sets successfully!")
