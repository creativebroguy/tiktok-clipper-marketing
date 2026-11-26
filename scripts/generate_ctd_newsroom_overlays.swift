import Cocoa

let width: CGFloat = 1080
let height: CGFloat = 1920

let baseDir = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/ctd_newsroom"
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
let darkBgColor = NSColor(red: 0.05, green: 0.06, blue: 0.09, alpha: 0.94) // Deep newsroom black
let strokeColor = NSColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 0.8)
let mutedGrey = NSColor(red: 0.55, green: 0.60, blue: 0.66, alpha: 1.0)

struct NewsClipMeta {
    let id: String
    let topBadge: String
    let headlineParts: [(text: String, isHighlight: Bool)]
    let subheadline: String
    let ctaText: String
}

let clips: [NewsClipMeta] = [
    NewsClipMeta(
        id: "clip_01",
        topBadge: "BROGUY NEWS",
        headlineParts: [
            ("OM DEDDY: 'GUE GAK BAKAL MAU PAKE ", false),
            ("KAOS KALENG-KALENG!'", true)
        ],
        subheadline: "Review Kaos Distro Lokal Kuningan yang Bikin Om Deddy Kaget",
        ctaText: "🛒 CEK KERANJANG KUNING SEKARANG • STOK TERBATAS!"
    ),
    NewsClipMeta(
        id: "clip_02",
        topBadge: "PRICE CHECK",
        headlineParts: [
            ("OM DEDDY KAGET: '", false),
            ("HARGA SAMA BAHANNYA ", true),
            ("GAK LOGIS!'", true)
        ],
        subheadline: "Kualitas Jahitan Rapi & Tebal Tapi Harga Cuma 70 Ribuan",
        ctaText: "🛒 KLAIM VOUCHER DISKON DI KERANJANG KUNING SEKARANG!"
    ),
    NewsClipMeta(
        id: "clip_03",
        topBadge: "DURABILITY TEST",
        headlineParts: [
            ("DEDDY CORBUZIER: '", false),
            ("GUE TARIK SEKUAT TENAGA, ", true),
            ("KERAHNYA ", false),
            ("GAK MELAR!'", true)
        ],
        subheadline: "Uji Ketahanan Kerah Kaos Broguy Langsung di Podcast",
        ctaText: "🛒 AMANKAN SIZE KAMU DI KERANJANG KUNING SEKARANG!"
    ),
    NewsClipMeta(
        id: "clip_04",
        topBadge: "VIRAL REACTION",
        headlineParts: [
            ("'", false),
            ("SERIUSAN 70 RIBU? ", true),
            ("GILA SIH ", false),
            ("BAGUS BANGET!'", true)
        ],
        subheadline: "Harga Boleh Murah, Kualitas Gak Boleh Murahan",
        ctaText: "🛒 BUKTIKAN SENDIRI DI KERANJANG KUNING SEKARANG!"
    ),
    NewsClipMeta(
        id: "clip_05",
        topBadge: "RECOMMENDATION",
        headlineParts: [
            ("OM DEDDY: 'GUA GAK BOHONG, ", false),
            ("BAHANNYA ", true),
            ("ENAK BANGET!'", true)
        ],
        subheadline: "Kualitas Kain Halus & Adem Setara Brand Mewah Jutaan",
        ctaText: "🛒 DAPATKAN KUALITAS MEWAH DI KERANJANG KUNING!"
    )
]

func drawDotMatrix(at origin: NSPoint, cols: Int, rows: Int, spacing: CGFloat, radius: CGFloat, in ctx: CGContext) {
    ctx.saveGState()
    NSColor.white.withAlphaComponent(0.40).setFill()
    for r in 0..<rows {
        for c in 0..<cols {
            let x = origin.x + CGFloat(c) * spacing
            let y = origin.y + CGFloat(r) * spacing
            let dot = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: radius * 2, height: radius * 2))
            dot.fill()
        }
    }
    ctx.restoreGState()
}

for meta in clips {
    let clipDir = "\(baseDir)/\(meta.id)"
    try? FileManager.default.createDirectory(atPath: clipDir, withIntermediateDirectories: true, attributes: nil)

    // 1. Hook Card (Newsroom Broadcast Style)
    renderExactPNG(to: "\(clipDir)/hook_card.png") { ctx in
        let cPara = NSMutableParagraphStyle()
        cPara.alignment = .center

        // Top Left Brand Logo
        if let logoImage = NSImage(contentsOfFile: logoPath) {
            let targetLogoW: CGFloat = 260
            let targetLogoH: CGFloat = targetLogoW * (209.0 / 828.0)
            let logoX: CGFloat = 70
            let logoY: CGFloat = 1765
            logoImage.draw(in: NSRect(x: logoX, y: logoY, width: targetLogoW, height: targetLogoH))
        }

        // Top Right Pill Badge
        let badgeW: CGFloat = 230
        let badgeH: CGFloat = 54
        let badgeX: CGFloat = width - badgeW - 70
        let badgeY: CGFloat = 1768
        let badgePath = NSBezierPath(roundedRect: NSRect(x: badgeX, y: badgeY, width: badgeW, height: badgeH), xRadius: 27, yRadius: 27)
        orangeColor.setFill()
        badgePath.fill()

        let bAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 22),
            .foregroundColor: NSColor.white,
            .paragraphStyle: cPara
        ]
        let bText = NSAttributedString(string: meta.topBadge, attributes: bAttrs)
        bText.draw(in: NSRect(x: badgeX, y: badgeY + 12, width: badgeW, height: 35))

        // Lower Third Newsroom Container
        let cardW: CGFloat = 980
        let cardH: CGFloat = 510
        let cardX: CGFloat = 50
        let cardY: CGFloat = 270
        let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 34, color: NSColor.black.withAlphaComponent(0.60).cgColor)

        let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 36, yRadius: 36)
        darkBgColor.setFill()
        cardPath.fill()
        ctx.restoreGState()

        // Border stroke
        strokeColor.setStroke()
        cardPath.lineWidth = 1.5
        cardPath.stroke()

        // Decorative Dot Matrix grids
        drawDotMatrix(at: NSPoint(x: cardX + 30, y: cardY + cardH - 85), cols: 5, rows: 4, spacing: 14, radius: 2.5, in: ctx)
        drawDotMatrix(at: NSPoint(x: cardX + cardW - 100, y: cardY + 50), cols: 5, rows: 4, spacing: 14, radius: 2.5, in: ctx)

        // Stacked Badge: "BROGUY.ID" (Orange) + "NEWS" (White)
        let b1W: CGFloat = 200
        let b1H: CGFloat = 42
        let b1X: CGFloat = cardX + 120
        let b1Y: CGFloat = cardY + cardH - 68

        let b1Path = NSBezierPath(roundedRect: NSRect(x: b1X, y: b1Y, width: b1W, height: b1H), xRadius: 6, yRadius: 6)
        orangeColor.setFill()
        b1Path.fill()

        let b1Para = NSMutableParagraphStyle()
        b1Para.alignment = .center
        let b1Attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 22),
            .foregroundColor: NSColor.white,
            .paragraphStyle: b1Para
        ]
        let b1Text = NSAttributedString(string: "BROGUY.ID", attributes: b1Attrs)
        b1Text.draw(in: NSRect(x: b1X, y: b1Y + 8, width: b1W, height: 30))

        // "NEWS" Box
        let b2W: CGFloat = 150
        let b2H: CGFloat = 40
        let b2X: CGFloat = cardX + 120
        let b2Y: CGFloat = b1Y - 46

        let b2Path = NSBezierPath(roundedRect: NSRect(x: b2X, y: b2Y, width: b2W, height: b2H), xRadius: 5, yRadius: 5)
        NSColor.white.setFill()
        b2Path.fill()

        let b2Attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 26),
            .foregroundColor: NSColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0),
            .paragraphStyle: b1Para
        ]
        let b2Text = NSAttributedString(string: "NEWS", attributes: b2Attrs)
        b2Text.draw(in: NSRect(x: b2X, y: b2Y + 6, width: b2W, height: 32))

        // Thin Horizontal Dividing Line
        let linePath = NSBezierPath()
        linePath.move(to: NSPoint(x: b2X + b2W + 20, y: b2Y + 20))
        linePath.line(to: NSPoint(x: cardX + cardW - 60, y: b2Y + 20))
        NSColor.white.withAlphaComponent(0.45).setStroke()
        linePath.lineWidth = 2.0
        linePath.stroke()

        // Headline Text (Bold Modern Sans)
        let headPara = NSMutableParagraphStyle()
        headPara.lineSpacing = 8
        headPara.alignment = .left

        let headlineFont = NSFont.boldSystemFont(ofSize: 42)
        let headlineM = NSMutableAttributedString()

        for part in meta.headlineParts {
            headlineM.append(NSAttributedString(string: part.text, attributes: [
                .font: headlineFont,
                .foregroundColor: part.isHighlight ? orangeColor : NSColor.white,
                .paragraphStyle: headPara
            ]))
        }

        headlineM.draw(in: NSRect(x: cardX + 60, y: cardY + 110, width: cardW - 120, height: 210))

        // Subtitle & Attribution at bottom of card
        let subPara = NSMutableParagraphStyle()
        subPara.alignment = .left
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: mutedGrey,
            .paragraphStyle: subPara
        ]
        let subText = NSAttributedString(string: meta.subheadline, attributes: subAttrs)
        subText.draw(in: NSRect(x: cardX + 60, y: cardY + 65, width: cardW - 200, height: 30))

        let credAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.40),
            .paragraphStyle: subPara
        ]
        let credText = NSAttributedString(string: "🌐 Broguy.id  •  Source : Youtube Deddy Corbuzier", attributes: credAttrs)
        credText.draw(in: NSRect(x: cardX + 60, y: cardY + 30, width: cardW - 120, height: 26))
    }

    // 2. CTA Banner (News Ticker Style)
    renderExactPNG(to: "\(clipDir)/cta_banner.png") { ctx in
        let ctaW: CGFloat = 980
        let ctaH: CGFloat = 110
        let ctaX: CGFloat = 50
        let ctaY: CGFloat = 135

        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 24, color: NSColor(red: 1.0, green: 0.35, blue: 0.0, alpha: 0.60).cgColor)

        let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 32, yRadius: 32)
        orangeColor.setFill()
        ctaPath.fill()
        ctx.restoreGState()

        NSColor.white.withAlphaComponent(0.5).setStroke()
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

print("Generated 5 Newsroom overlay sets successfully!")
