import Cocoa

let width: CGFloat = 1080
let height: CGFloat = 1920

let baseDir = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/ctd_5_distinct"
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
let mutedGrey = NSColor(red: 0.45, green: 0.50, blue: 0.58, alpha: 1.0)
let lightGrey = NSColor(red: 0.60, green: 0.65, blue: 0.72, alpha: 1.0)

func drawStandardHeader(topBadgeText: String, in ctx: CGContext) {
    // Official Logo on Top Left
    if let logoImage = NSImage(contentsOfFile: logoPath) {
        let targetLogoW: CGFloat = 260
        let targetLogoH: CGFloat = targetLogoW * (209.0 / 828.0)
        logoImage.draw(in: NSRect(x: 70, y: 1765, width: targetLogoW, height: targetLogoH))
    }

    // Top Right Badge
    let badgeW: CGFloat = 230
    let badgeH: CGFloat = 54
    let badgeX: CGFloat = width - badgeW - 70
    let badgeY: CGFloat = 1768
    let badgePath = NSBezierPath(roundedRect: NSRect(x: badgeX, y: badgeY, width: badgeW, height: badgeH), xRadius: 27, yRadius: 27)
    orangeColor.setFill()
    badgePath.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let bAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 22),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ]
    let bText = NSAttributedString(string: topBadgeText, attributes: bAttrs)
    bText.draw(in: NSRect(x: badgeX, y: badgeY + 12, width: badgeW, height: 35))
}

func drawStandardCTA(text: String, in ctx: CGContext) {
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 24, color: NSColor(red: 1.0, green: 0.35, blue: 0.0, alpha: 0.60).cgColor)

    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 32, yRadius: 32)
    orangeColor.setFill()
    ctaPath.fill()
    ctx.restoreGState()

    NSColor.white.withAlphaComponent(0.45).setStroke()
    ctaPath.lineWidth = 2
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 28),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: text, attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 34, width: ctaW - 40, height: 50))
}


// =========================================================================
// LAYOUT 1: NEWSROOM BROADCAST (Dark Container + Dot Matrix + Stacked Badge)
// =========================================================================
let dir1 = "\(baseDir)/clip_01"
try? FileManager.default.createDirectory(atPath: dir1, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir1)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "BROGUY NEWS", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 510
    let cardX: CGFloat = 50
    let cardY: CGFloat = 270
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 34, color: NSColor.black.withAlphaComponent(0.65).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 36, yRadius: 36)
    NSColor(red: 0.05, green: 0.06, blue: 0.09, alpha: 0.95).setFill()
    cardPath.fill()
    ctx.restoreGState()

    NSColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 0.8).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    // Dot grid matrix at top-left and bottom-right
    ctx.saveGState()
    NSColor.white.withAlphaComponent(0.35).setFill()
    for r in 0..<4 {
        for c in 0..<5 {
            let x1 = cardX + 30 + CGFloat(c) * 14
            let y1 = cardY + cardH - 85 + CGFloat(r) * 14
            NSBezierPath(ovalIn: NSRect(x: x1, y: y1, width: 5, height: 5)).fill()

            let x2 = cardX + cardW - 100 + CGFloat(c) * 14
            let y2 = cardY + 50 + CGFloat(r) * 14
            NSBezierPath(ovalIn: NSRect(x: x2, y: y2, width: 5, height: 5)).fill()
        }
    }
    ctx.restoreGState()

    // Stacked Badge
    let b1W: CGFloat = 200
    let b1H: CGFloat = 42
    let b1X: CGFloat = cardX + 120
    let b1Y: CGFloat = cardY + cardH - 68
    let b1Path = NSBezierPath(roundedRect: NSRect(x: b1X, y: b1Y, width: b1W, height: b1H), xRadius: 6, yRadius: 6)
    orangeColor.setFill()
    b1Path.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let b1Text = NSAttributedString(string: "BROGUY.ID", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 22),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ])
    b1Text.draw(in: NSRect(x: b1X, y: b1Y + 8, width: b1W, height: 30))

    let b2W: CGFloat = 150
    let b2H: CGFloat = 40
    let b2X: CGFloat = cardX + 120
    let b2Y: CGFloat = b1Y - 46
    let b2Path = NSBezierPath(roundedRect: NSRect(x: b2X, y: b2Y, width: b2W, height: b2H), xRadius: 5, yRadius: 5)
    NSColor.white.setFill()
    b2Path.fill()

    let b2Text = NSAttributedString(string: "NEWS", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 26),
        .foregroundColor: darkCharcoal,
        .paragraphStyle: cPara
    ])
    b2Text.draw(in: NSRect(x: b2X, y: b2Y + 6, width: b2W, height: 32))

    let linePath = NSBezierPath()
    linePath.move(to: NSPoint(x: b2X + b2W + 20, y: b2Y + 20))
    linePath.line(to: NSPoint(x: cardX + cardW - 60, y: b2Y + 20))
    NSColor.white.withAlphaComponent(0.40).setStroke()
    linePath.lineWidth = 2.0
    linePath.stroke()

    // Headline
    let hPara = NSMutableParagraphStyle()
    hPara.lineSpacing = 8
    let hFont = NSFont.boldSystemFont(ofSize: 42)
    let hM = NSMutableAttributedString()
    hM.append(NSAttributedString(string: "OM DEDDY TEGAS: 'GUE GAK BAKAL MAU PAKE ", attributes: [.font: hFont, .foregroundColor: NSColor.white, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "KAOS KALENG-KALENG!'", attributes: [.font: hFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.draw(in: NSRect(x: cardX + 60, y: cardY + 110, width: cardW - 120, height: 210))

    let subText = NSAttributedString(string: "Review Kaos Distro Lokal Kuningan yang Bikin Om Deddy Kaget", attributes: [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: mutedGrey
    ])
    subText.draw(in: NSRect(x: cardX + 60, y: cardY + 65, width: cardW - 200, height: 30))

    let credText = NSAttributedString(string: "🌐 Broguy.id  •  Source : Youtube Deddy Corbuzier", attributes: [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor.white.withAlphaComponent(0.40)
    ])
    credText.draw(in: NSRect(x: cardX + 60, y: cardY + 30, width: cardW - 120, height: 26))
}
renderExactPNG(to: "\(dir1)/cta_banner.png") { ctx in
    drawStandardCTA(text: "🛒 CEK KERANJANG KUNING SEKARANG • STOK TERBATAS!", in: ctx)
}


// =========================================================================
// LAYOUT 2: WHITE SPEECH BUBBLE (Pure White Card + Upward Triangle Pointer)
// =========================================================================
let dir2 = "\(baseDir)/clip_02"
try? FileManager.default.createDirectory(atPath: dir2, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir2)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "DURABILITY TEST", in: ctx)

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

    // Pill Badge
    let pillW: CGFloat = 190
    let pillH: CGFloat = 46
    let pillX: CGFloat = cardX + 50
    let pillY: CGFloat = cardY + cardH - 75
    let pillPath = NSBezierPath(roundedRect: NSRect(x: pillX, y: pillY, width: pillW, height: pillH), xRadius: 23, yRadius: 23)
    orangeColor.setFill()
    pillPath.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let pillText = NSAttributedString(string: "BROGUY.ID", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 22),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ])
    pillText.draw(in: NSRect(x: pillX, y: pillY + 10, width: pillW, height: 30))

    // Serif Headline
    let hPara = NSMutableParagraphStyle()
    hPara.lineSpacing = 6
    let serifFont = NSFont(name: "Georgia-Bold", size: 36) ?? NSFont.boldSystemFont(ofSize: 36)
    let hM = NSMutableAttributedString()
    hM.append(NSAttributedString(string: "\"DEDDY CORBUZIER: '", attributes: [.font: serifFont, .foregroundColor: darkCharcoal, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "GUE TARIK SEKUAT TENAGA, ", attributes: [.font: serifFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "KERAHNYA ", attributes: [.font: serifFont, .foregroundColor: darkCharcoal, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "GAK MELAR!'\"", attributes: [.font: serifFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 260, width: cardW - 100, height: 170))

    let subText = NSAttributedString(string: "Uji Ketahanan Kerah Kaos Broguy Langsung di Podcast", attributes: [
        .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
        .foregroundColor: mutedGrey
    ])
    subText.draw(in: NSRect(x: cardX + 50, y: cardY + 75, width: cardW - 100, height: 35))

    let srcText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier", attributes: [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: lightGrey
    ])
    srcText.draw(in: NSRect(x: cardX + 50, y: cardY + 36, width: cardW - 100, height: 28))
}
renderExactPNG(to: "\(dir2)/cta_banner.png") { ctx in
    drawStandardCTA(text: "🛒 BUKTIKAN KEKUATAN KERAHNYA DI KERANJANG KUNING!", in: ctx)
}


// =========================================================================
// LAYOUT 3: DARK GRAPHITE MINIMALIST (Midnight Card + Full Bottom Polka Dots)
// =========================================================================
let dir3 = "\(baseDir)/clip_03"
try? FileManager.default.createDirectory(atPath: dir3, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir3)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "PRICE CHECK", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 500
    let cardX: CGFloat = 50
    let cardY: CGFloat = 280
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 30, color: NSColor.black.withAlphaComponent(0.70).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 34, yRadius: 34)
    NSColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 0.96).setFill()
    cardPath.fill()
    ctx.restoreGState()

    NSColor(red: 0.22, green: 0.26, blue: 0.35, alpha: 0.7).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    // Full Polka Dot Grid across the bottom third of the card
    ctx.saveGState()
    NSColor.white.withAlphaComponent(0.25).setFill()
    let dotRows = 3
    let dotCols = 32
    let dotSpacing: CGFloat = 28
    let dotStartX = cardX + 45
    let dotStartY = cardY + 35
    for r in 0..<dotRows {
        for c in 0..<dotCols {
            let x = dotStartX + CGFloat(c) * dotSpacing
            let y = dotStartY + CGFloat(r) * dotSpacing
            NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 4.5, height: 4.5)).fill()
        }
    }
    ctx.restoreGState()

    // Horizontal line above dots
    let divLine = NSBezierPath()
    divLine.move(to: NSPoint(x: cardX + 40, y: cardY + 125))
    divLine.line(to: NSPoint(x: cardX + cardW - 40, y: cardY + 125))
    NSColor.white.withAlphaComponent(0.20).setStroke()
    divLine.lineWidth = 1.5
    divLine.stroke()

    // Badge: "BROGUY.ID" Pill
    let pillW: CGFloat = 180
    let pillH: CGFloat = 44
    let pillX: CGFloat = cardX + 50
    let pillY: CGFloat = cardY + cardH - 70
    let pillPath = NSBezierPath(roundedRect: NSRect(x: pillX, y: pillY, width: pillW, height: pillH), xRadius: 22, yRadius: 22)
    orangeColor.setFill()
    pillPath.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let pillText = NSAttributedString(string: "BROGUY.ID", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 20),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ])
    pillText.draw(in: NSRect(x: pillX, y: pillY + 10, width: pillW, height: 28))

    // Headline (Serif + Quotes)
    let hPara = NSMutableParagraphStyle()
    hPara.lineSpacing = 6
    let serifFont = NSFont(name: "Georgia-Bold", size: 36) ?? NSFont.boldSystemFont(ofSize: 36)
    let hM = NSMutableAttributedString()
    hM.append(NSAttributedString(string: "Om Deddy Kaget : \n\"", attributes: [.font: serifFont, .foregroundColor: NSColor.white, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "Harga 70 Ribu ", attributes: [.font: serifFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "sama Bahannya ", attributes: [.font: serifFont, .foregroundColor: NSColor.white, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "Ga Logis!\"", attributes: [.font: serifFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 260, width: cardW - 100, height: 180))

    let srcText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier", attributes: [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor.white.withAlphaComponent(0.50)
    ])
    srcText.draw(in: NSRect(x: cardX + 50, y: cardY + 140, width: cardW - 100, height: 26))
}
renderExactPNG(to: "\(dir3)/cta_banner.png") { ctx in
    drawStandardCTA(text: "🛒 KLAIM VOUCHER 70 RIBUAN DI KERANJANG KUNING SEKARANG!", in: ctx)
}


// =========================================================================
// LAYOUT 4: EXECUTIVE REVIEW (Warm Mocha Container + 8px Solid Orange Accent Bar)
// =========================================================================
let dir4 = "\(baseDir)/clip_04"
try? FileManager.default.createDirectory(atPath: dir4, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir4)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "VIP REVIEW", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 490
    let cardX: CGFloat = 50
    let cardY: CGFloat = 280
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 32, color: NSColor.black.withAlphaComponent(0.75).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 30, yRadius: 30)
    NSColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 0.96).setFill() // Warm mocha dark
    cardPath.fill()
    ctx.restoreGState()

    // 8px Solid Orange Vertical Accent Bar on the Left Edge
    let barRect = NSRect(x: cardX, y: cardY + 25, width: 9, height: cardH - 50)
    let barPath = NSBezierPath(roundedRect: barRect, xRadius: 4.5, yRadius: 4.5)
    orangeColor.setFill()
    barPath.fill()

    // Header badge inside card
    let badgeText = NSAttributedString(string: "✦ EXECUTIVE FASHION REVIEW ✦", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 19),
        .foregroundColor: orangeColor
    ])
    badgeText.draw(at: NSPoint(x: cardX + 45, y: cardY + cardH - 65))

    let hPara = NSMutableParagraphStyle()
    hPara.lineSpacing = 8
    let hFont = NSFont.boldSystemFont(ofSize: 38)
    let hM = NSMutableAttributedString()
    hM.append(NSAttributedString(string: "\"", attributes: [.font: hFont, .foregroundColor: NSColor.white, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "DIKASIH LOGO BRAND MEWAH GUCCI, ", attributes: [.font: hFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "ORANG JUGA PERCAYA! SAKING ", attributes: [.font: hFont, .foregroundColor: NSColor.white, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "MEWAHNYA KAIN INI!\"", attributes: [.font: hFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.draw(in: NSRect(x: cardX + 45, y: cardY + cardH - 265, width: cardW - 90, height: 190))

    let subText = NSAttributedString(string: "Kualitas Kain Standar Internasional Tanpa Harga Jutaan Rupiah", attributes: [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor(white: 0.70, alpha: 1.0)
    ])
    subText.draw(in: NSRect(x: cardX + 45, y: cardY + 75, width: cardW - 90, height: 30))

    let credText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier  •  Brand : Broguy.id", attributes: [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(white: 0.45, alpha: 1.0)
    ])
    credText.draw(in: NSRect(x: cardX + 45, y: cardY + 35, width: cardW - 90, height: 26))
}
renderExactPNG(to: "\(dir4)/cta_banner.png") { ctx in
    drawStandardCTA(text: "🛒 MILIKI KUALITAS BRAND MEWAH DENGAN HARGA TERJANGKAU!", in: ctx)
}


// =========================================================================
// LAYOUT 5: CLEAN MODERN HAUL (White Frosted Card + Double Border + Pill Tag)
// =========================================================================
let dir5 = "\(baseDir)/clip_05"
try? FileManager.default.createDirectory(atPath: dir5, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir5)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "REKOMENDASI", in: ctx)

    let cardW: CGFloat = 960
    let cardH: CGFloat = 460
    let cardX: CGFloat = 60
    let cardY: CGFloat = 300
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 32, color: NSColor(white: 0, alpha: 0.45).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 38, yRadius: 38)
    NSColor(white: 0.98, alpha: 0.98).setFill()
    cardPath.fill()
    ctx.restoreGState()

    // Double Border
    NSColor(white: 0.88, alpha: 1.0).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    let innerRect = cardRect.insetBy(dx: 12, dy: 12)
    let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 28, yRadius: 28)
    NSColor(red: 1.0, green: 0.40, blue: 0.0, alpha: 0.15).setStroke()
    innerPath.lineWidth = 1.0
    innerPath.stroke()

    // Badge: "OM DEDDY'S CHOICE" Pill
    let pillW: CGFloat = 240
    let pillH: CGFloat = 44
    let pillX: CGFloat = cardX + 45
    let pillY: CGFloat = cardY + cardH - 72
    let pillPath = NSBezierPath(roundedRect: NSRect(x: pillX, y: pillY, width: pillW, height: pillH), xRadius: 22, yRadius: 22)
    orangeColor.setFill()
    pillPath.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let pillText = NSAttributedString(string: "OM DEDDY'S CHOICE", attributes: [
        .font: NSFont.boldSystemFont(ofSize: 18),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ])
    pillText.draw(in: NSRect(x: pillX, y: pillY + 10, width: pillW, height: 28))

    // Modern Sans Headline
    let hPara = NSMutableParagraphStyle()
    hPara.lineSpacing = 7
    let hFont = NSFont.boldSystemFont(ofSize: 38)
    let hM = NSMutableAttributedString()
    hM.append(NSAttributedString(string: "\"OM DEDDY: '", attributes: [.font: hFont, .foregroundColor: darkCharcoal, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "GUA GAK BOHONG, ", attributes: [.font: hFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "KETIKA DIPEGANG ", attributes: [.font: hFont, .foregroundColor: darkCharcoal, .paragraphStyle: hPara]))
    hM.append(NSAttributedString(string: "BAHANNYA ENAK BANGET!'\"", attributes: [.font: hFont, .foregroundColor: orangeColor, .paragraphStyle: hPara]))
    hM.draw(in: NSRect(x: cardX + 45, y: cardY + cardH - 260, width: cardW - 90, height: 180))

    let subText = NSAttributedString(string: "Rekomendasi Nyata Tekstur Bahan Lembut & Adem Seharian", attributes: [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: mutedGrey
    ])
    subText.draw(in: NSRect(x: cardX + 45, y: cardY + 75, width: cardW - 90, height: 30))

    let srcText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier  •  Broguy.id", attributes: [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: lightGrey
    ])
    srcText.draw(in: NSRect(x: cardX + 45, y: cardY + 36, width: cardW - 90, height: 26))
}
renderExactPNG(to: "\(dir5)/cta_banner.png") { ctx in
    drawStandardCTA(text: "🛒 RASAKAN SENDIRI BAHANNYA • ORDER DI KERANJANG KUNING!", in: ctx)
}

print("All 5 DISTINCT overlay sets generated successfully!")
