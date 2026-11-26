import Cocoa

let width: CGFloat = 1080
let height: CGFloat = 1920

let baseDir = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/ctd_clips_6_10"
let logoPath = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/brand/Logo Broguy Panjang.png"
let logoBlackPath = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/brand/Logo Broguy Panjang Black.png"

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

func drawStandardHeader(topBadgeText: String, in ctx: CGContext, badgeBgColor: NSColor = orangeColor, badgeTextColor: NSColor = .white, useBlackLogo: Bool = false) {
    // Official Logo on Top Left
    let chosenLogo = useBlackLogo ? logoBlackPath : logoPath
    if let logoImage = NSImage(contentsOfFile: chosenLogo) {
        let targetLogoW: CGFloat = 260
        let targetLogoH: CGFloat = targetLogoW * (209.0 / 828.0)
        logoImage.draw(in: NSRect(x: 70, y: 1765, width: targetLogoW, height: targetLogoH))
    }

    // Top Right Badge
    let badgeW: CGFloat = 240
    let badgeH: CGFloat = 54
    let badgeX: CGFloat = width - badgeW - 70
    let badgeY: CGFloat = 1768
    let badgePath = NSBezierPath(roundedRect: NSRect(x: badgeX, y: badgeY, width: badgeW, height: badgeH), xRadius: 27, yRadius: 27)
    badgeBgColor.setFill()
    badgePath.fill()

    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let bAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 21),
        .foregroundColor: badgeTextColor,
        .paragraphStyle: cPara
    ]
    let bText = NSAttributedString(string: topBadgeText, attributes: bAttrs)
    bText.draw(in: NSRect(x: badgeX, y: badgeY + 12, width: badgeW, height: 35))
}


// =========================================================================
// LAYOUT 6: CYBER TECH SLATE & CORNER BRACKETS (Clip 6)
// Dark titanium slate card with bright orange L-shaped corner brackets & tech tags
// =========================================================================
let dir6 = "\(baseDir)/clip_06"
try? FileManager.default.createDirectory(atPath: dir6, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir6)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "TECH VERIFIED", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 520
    let cardX: CGFloat = 50
    let cardY: CGFloat = 260
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    // Base dark titanium slate card
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 32, color: NSColor.black.withAlphaComponent(0.7).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 32, yRadius: 32)
    NSColor(red: 0.05, green: 0.07, blue: 0.11, alpha: 0.97).setFill()
    cardPath.fill()
    ctx.restoreGState()

    // Subtle slate border
    NSColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 0.8).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    // Distinctive Feature: Bold Orange L-shaped Corner Brackets at all 4 corners!
    let bracketLen: CGFloat = 40
    let bracketInset: CGFloat = 20
    let bWidth: CGFloat = 4.0
    orangeColor.setStroke()

    // Top-Left Bracket
    let tlPath = NSBezierPath()
    tlPath.move(to: NSPoint(x: cardX + bracketInset, y: cardY + cardH - bracketInset - bracketLen))
    tlPath.line(to: NSPoint(x: cardX + bracketInset, y: cardY + cardH - bracketInset))
    tlPath.line(to: NSPoint(x: cardX + bracketInset + bracketLen, y: cardY + cardH - bracketInset))
    tlPath.lineWidth = bWidth
    tlPath.stroke()

    // Top-Right Bracket
    let trPath = NSBezierPath()
    trPath.move(to: NSPoint(x: cardX + cardW - bracketInset - bracketLen, y: cardY + cardH - bracketInset))
    trPath.line(to: NSPoint(x: cardX + cardW - bracketInset, y: cardY + cardH - bracketInset))
    trPath.line(to: NSPoint(x: cardX + cardW - bracketInset, y: cardY + cardH - bracketInset - bracketLen))
    trPath.lineWidth = bWidth
    trPath.stroke()

    // Bottom-Left Bracket
    let blPath = NSBezierPath()
    blPath.move(to: NSPoint(x: cardX + bracketInset, y: cardY + bracketInset + bracketLen))
    blPath.line(to: NSPoint(x: cardX + bracketInset, y: cardY + bracketInset))
    blPath.line(to: NSPoint(x: cardX + bracketInset + bracketLen, y: cardY + bracketInset))
    blPath.lineWidth = bWidth
    blPath.stroke()

    // Bottom-Right Bracket
    let brPath = NSBezierPath()
    brPath.move(to: NSPoint(x: cardX + cardW - bracketInset - bracketLen, y: cardY + bracketInset))
    brPath.line(to: NSPoint(x: cardX + cardW - bracketInset, y: cardY + bracketInset))
    brPath.line(to: NSPoint(x: cardX + cardW - bracketInset, y: cardY + bracketInset + bracketLen))
    brPath.lineWidth = bWidth
    brPath.stroke()

    // Category Tech Badge: [ BROGUY LABS // VERIFIED PICK ]
    let tagPath = NSBezierPath(roundedRect: NSRect(x: cardX + 50, y: cardY + cardH - 85, width: 330, height: 42), xRadius: 8, yRadius: 8)
    orangeColor.withAlphaComponent(0.18).setFill()
    tagPath.fill()
    orangeColor.setStroke()
    tagPath.lineWidth = 1.5
    tagPath.stroke()

    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .bold),
        .foregroundColor: orangeColor
    ]
    let tagText = NSAttributedString(string: "⚡ [ BROGUY LABS // DEDDY'S PICK ]", attributes: tagAttrs)
    tagText.draw(at: NSPoint(x: cardX + 62, y: cardY + cardH - 74))

    // Headline Text
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 8
    para.alignment = .left

    let h1Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 34, weight: .heavy),
        .foregroundColor: NSColor.white,
        .paragraphStyle: para
    ]
    let h2Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 37, weight: .black),
        .foregroundColor: orangeColor,
        .paragraphStyle: para
    ]

    let headline = NSMutableAttributedString()
    headline.append(NSAttributedString(string: "OM DEDDY LANGSUNG BUNGKUS:\n", attributes: h1Attrs))
    headline.append(NSAttributedString(string: "\"GUA AMBIL SATU BUAT GUA PAKE, INI LUAR BIASA!\"", attributes: h2Attrs))
    headline.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 250, width: cardW - 100, height: 160))

    // Subtitle & Attribution
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .medium),
        .foregroundColor: NSColor(red: 0.65, green: 0.72, blue: 0.82, alpha: 1.0)
    ]
    let sub = NSAttributedString(string: "Host Podcast Ternama Langsung Ambil & Pakai Sendiri di Studio", attributes: subAttrs)
    sub.draw(at: NSPoint(x: cardX + 50, y: cardY + 95))

    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 17, weight: .regular),
        .foregroundColor: NSColor(red: 0.40, green: 0.45, blue: 0.55, alpha: 1.0)
    ]
    let src = NSAttributedString(string: "Source: Close The Door Podcast • Broguy Official", attributes: srcAttrs)
    src.draw(at: NSPoint(x: cardX + 50, y: cardY + 45))
}

renderExactPNG(to: "\(dir6)/cta_banner.png") { ctx in
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 28, color: orangeColor.withAlphaComponent(0.65).cgColor)
    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 28, yRadius: 28)
    orangeColor.setFill()
    ctaPath.fill()
    ctx.restoreGState()

    NSColor.white.withAlphaComponent(0.4).setStroke()
    ctaPath.lineWidth = 2
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 28, weight: .black),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "🛒 AMBIL PROMONYA HARI INI • STOK MENIPIS!", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 34, width: ctaW - 40, height: 50))
}


// =========================================================================
// LAYOUT 7: LUXURY GOLD & JET BLACK CARD (Clip 7)
// Jet black card with 2.5px metallic amber/gold border, gold hairline rules, serif typography
// =========================================================================
let dir7 = "\(baseDir)/clip_07"
try? FileManager.default.createDirectory(atPath: dir7, withIntermediateDirectories: true, attributes: nil)

let goldColor = NSColor(red: 0.88, green: 0.72, blue: 0.32, alpha: 1.0) // #E0B852 Metallic Gold

renderExactPNG(to: "\(dir7)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "PREMIUM TIER", in: ctx, badgeBgColor: goldColor, badgeTextColor: .black)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 520
    let cardX: CGFloat = 50
    let cardY: CGFloat = 260
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    // Base Jet Black Card
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 36, color: NSColor.black.withAlphaComponent(0.85).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 36, yRadius: 36)
    NSColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 0.98).setFill()
    cardPath.fill()
    ctx.restoreGState()

    // Metallic Gold Border
    goldColor.setStroke()
    cardPath.lineWidth = 2.5
    cardPath.stroke()

    // Distinctive Feature: Top Center Gold Crest with Hairline Rules
    let crestY: CGFloat = cardY + cardH - 65
    let crestText = "✦ BROGUY EXECUTIVE COLLECTION ✦"
    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center
    let crestAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .bold),
        .foregroundColor: goldColor,
        .paragraphStyle: cPara
    ]
    let crestAttrStr = NSAttributedString(string: crestText, attributes: crestAttrs)
    crestAttrStr.draw(in: NSRect(x: cardX + 150, y: crestY - 4, width: cardW - 300, height: 30))

    // Hairline divider rules on left and right of crest
    goldColor.withAlphaComponent(0.4).setStroke()
    let leftRule = NSBezierPath()
    leftRule.move(to: NSPoint(x: cardX + 60, y: crestY + 8))
    leftRule.line(to: NSPoint(x: cardX + 260, y: crestY + 8))
    leftRule.lineWidth = 1.0
    leftRule.stroke()

    let rightRule = NSBezierPath()
    rightRule.move(to: NSPoint(x: cardX + cardW - 260, y: crestY + 8))
    rightRule.line(to: NSPoint(x: cardX + cardW - 60, y: crestY + 8))
    rightRule.lineWidth = 1.0
    rightRule.stroke()

    // Headline in High-End Serif
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 8
    para.alignment = .left

    let serifFont = NSFont(name: "Georgia-Bold", size: 34) ?? NSFont.boldSystemFont(ofSize: 34)
    let serifHighlight = NSFont(name: "Georgia-Bold", size: 38) ?? NSFont.boldSystemFont(ofSize: 38)

    let h1Attrs: [NSAttributedString.Key: Any] = [
        .font: serifFont,
        .foregroundColor: NSColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0),
        .paragraphStyle: para
    ]
    let h2Attrs: [NSAttributedString.Key: Any] = [
        .font: serifHighlight,
        .foregroundColor: goldColor,
        .paragraphStyle: para
    ]

    let headline = NSMutableAttributedString()
    headline.append(NSAttributedString(string: "OM DEDDY BINGUNG:\n", attributes: h1Attrs))
    headline.append(NSAttributedString(string: "\"PABRIK LU UNTUNG DARI MANA KALAU JUAL 70 RIBUAN?!\"", attributes: h2Attrs))
    headline.draw(in: NSRect(x: cardX + 55, y: cardY + cardH - 250, width: cardW - 110, height: 165))

    // Subtitle & Attribution
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .medium),
        .foregroundColor: NSColor(red: 0.75, green: 0.72, blue: 0.65, alpha: 1.0)
    ]
    let sub = NSAttributedString(string: "Bahan Premium Tebal 24s Tapi Dijual Harga Grosir Langsung Dari Pabrik", attributes: subAttrs)
    sub.draw(at: NSPoint(x: cardX + 55, y: cardY + 95))

    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .regular),
        .foregroundColor: goldColor.withAlphaComponent(0.6)
    ]
    let src = NSAttributedString(string: "Close The Door Exclusive • Broguy.id", attributes: srcAttrs)
    src.draw(at: NSPoint(x: cardX + 55, y: cardY + 45))
}

renderExactPNG(to: "\(dir7)/cta_banner.png") { ctx in
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 28, color: goldColor.withAlphaComponent(0.5).cgColor)
    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 28, yRadius: 28)
    NSColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1.0).setFill()
    ctaPath.fill()
    ctx.restoreGState()

    goldColor.setStroke()
    ctaPath.lineWidth = 2.5
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 26),
        .foregroundColor: goldColor,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "✦ KLAIM HARGA PABRIK 70 RIBUAN DI KERANJANG KUNING ✦", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 36, width: ctaW - 40, height: 50))
}


// =========================================================================
// LAYOUT 8: SPLIT TWO-TONE DUAL CARD (Clip 8)
// Top header band (Orange) fused with crisp White lower body, checkmark icon
// =========================================================================
let dir8 = "\(baseDir)/clip_08"
try? FileManager.default.createDirectory(atPath: dir8, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir8)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "DURABILITY #1", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 520
    let cardX: CGFloat = 50
    let cardY: CGFloat = 260

    // Lower white body
    let lowerH: CGFloat = 445
    let lowerRect = NSRect(x: cardX, y: cardY, width: cardW, height: lowerH)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 32, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    let lowerPath = NSBezierPath(roundedRect: lowerRect, xRadius: 34, yRadius: 34)
    NSColor.white.setFill()
    lowerPath.fill()
    ctx.restoreGState()

    // Upper Orange Band
    let upperH: CGFloat = 85
    let upperY: CGFloat = cardY + lowerH - 10
    let upperRect = NSRect(x: cardX, y: upperY, width: cardW, height: upperH)
    let upperPath = NSBezierPath(roundedRect: upperRect, xRadius: 34, yRadius: 34)
    orangeColor.setFill()
    upperPath.fill()

    // Seal the seam
    let seamRect = NSRect(x: cardX, y: upperY, width: cardW, height: 25)
    orangeColor.setFill()
    seamRect.fill()

    // Upper Band Text
    let upAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .black),
        .foregroundColor: NSColor.white
    ]
    let upText = NSAttributedString(string: "✓ HASIL UJI KETAHANAN KERAH & JAHITAN", attributes: upAttrs)
    upText.draw(at: NSPoint(x: cardX + 45, y: upperY + 28))

    // Headline inside white body
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 7
    para.alignment = .left

    let h1Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 34, weight: .heavy),
        .foregroundColor: NSColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1.0),
        .paragraphStyle: para
    ]
    let h2Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 37, weight: .black),
        .foregroundColor: NSColor(red: 0.88, green: 0.22, blue: 0.0, alpha: 1.0),
        .paragraphStyle: para
    ]

    let headline = NSMutableAttributedString()
    headline.append(NSAttributedString(string: "KAOS MURAH BIASANYA GAMPANG BELEL,\n", attributes: h1Attrs))
    headline.append(NSAttributedString(string: "TAPI YANG INI DITARIK TETAP GAK MELAR!", attributes: h2Attrs))
    headline.draw(in: NSRect(x: cardX + 50, y: cardY + lowerH - 180, width: cardW - 100, height: 160))

    // Subtitle & Attribution
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0)
    ]
    let sub = NSAttributedString(string: "Uji Ketahanan Ekstrem Double Rib Collar Jahitan Rantai Standar Ekspor", attributes: subAttrs)
    sub.draw(at: NSPoint(x: cardX + 50, y: cardY + 95))

    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .regular),
        .foregroundColor: NSColor(red: 0.55, green: 0.60, blue: 0.68, alpha: 1.0)
    ]
    let src = NSAttributedString(string: "Uji Langsung: Deddy Corbuzier • Broguy.id", attributes: srcAttrs)
    src.draw(at: NSPoint(x: cardX + 50, y: cardY + 45))
}

renderExactPNG(to: "\(dir8)/cta_banner.png") { ctx in
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 26, color: orangeColor.withAlphaComponent(0.6).cgColor)
    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 28, yRadius: 28)
    orangeColor.setFill()
    ctaPath.fill()
    ctx.restoreGState()

    NSColor.white.withAlphaComponent(0.45).setStroke()
    ctaPath.lineWidth = 2
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 27),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "🛒 ORDER KAOS ANTI-MELAR SEKARANG • GARANSI AWET!", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 36, width: ctaW - 40, height: 50))
}


// =========================================================================
// LAYOUT 9: VIBRANT SUNSET GRADIENT GLASSMORPHISM (Clip 9)
// Deep crimson to burnt amber gradient with glowing orange inner rim
// =========================================================================
let dir9 = "\(baseDir)/clip_09"
try? FileManager.default.createDirectory(atPath: dir9, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir9)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "KARYA LOKAL", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 520
    let cardX: CGFloat = 50
    let cardY: CGFloat = 260
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    // Base card with sunset crimson gradient
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 34, color: NSColor.black.withAlphaComponent(0.7).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 36, yRadius: 36)

    // Draw gradient
    let colorTop = NSColor(red: 0.18, green: 0.05, blue: 0.08, alpha: 0.98) // Deep Crimson
    let colorBot = NSColor(red: 0.11, green: 0.06, blue: 0.04, alpha: 0.98) // Dark Amber
    let grad = NSGradient(starting: colorBot, ending: colorTop)
    grad?.draw(in: cardPath, angle: 90)
    ctx.restoreGState()

    // Glowing Sunset Orange Rim
    NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.75).setStroke()
    cardPath.lineWidth = 2.0
    cardPath.stroke()

    // Distinctive Category Badge: 🇮🇩 100% PRODUK ASLI KUNINGAN
    let tagW: CGFloat = 340
    let tagH: CGFloat = 42
    let tagPath = NSBezierPath(roundedRect: NSRect(x: cardX + 50, y: cardY + cardH - 85, width: tagW, height: tagH), xRadius: 21, yRadius: 21)
    NSColor(red: 0.90, green: 0.15, blue: 0.15, alpha: 0.35).setFill()
    tagPath.fill()
    NSColor(red: 1.0, green: 0.30, blue: 0.20, alpha: 0.9).setStroke()
    tagPath.lineWidth = 1.5
    tagPath.stroke()

    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 18),
        .foregroundColor: NSColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
    ]
    let tagText = NSAttributedString(string: "🇮🇩 100% PRODUK ASLI KUNINGAN", attributes: tagAttrs)
    tagText.draw(at: NSPoint(x: cardX + 70, y: cardY + cardH - 74))

    // Headline
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 8
    para.alignment = .left

    let h1Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 34, weight: .heavy),
        .foregroundColor: NSColor.white,
        .paragraphStyle: para
    ]
    let h2Attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 37, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.75, blue: 0.10, alpha: 1.0), // Warm amber yellow
        .paragraphStyle: para
    ]

    let headline = NSMutableAttributedString()
    headline.append(NSAttributedString(string: "DARI KUNINGAN JAWA BARAT,\n", attributes: h1Attrs))
    headline.append(NSAttributedString(string: "BIKIN OM DEDDY KAGUM SAMA KUALITASNYA!", attributes: h2Attrs))
    headline.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 250, width: cardW - 100, height: 160))

    // Subtitle & Attribution
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .medium),
        .foregroundColor: NSColor(red: 0.85, green: 0.75, blue: 0.72, alpha: 1.0)
    ]
    let sub = NSAttributedString(string: "Bukti Karya Anak Bangsa Mampu Saingi Standar Kaos Branded Import", attributes: subAttrs)
    sub.draw(at: NSPoint(x: cardX + 50, y: cardY + 95))

    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .regular),
        .foregroundColor: NSColor(red: 0.65, green: 0.55, blue: 0.52, alpha: 1.0)
    ]
    let src = NSAttributedString(string: "Youtube Close The Door • Bangga Buatan Indonesia", attributes: srcAttrs)
    src.draw(at: NSPoint(x: cardX + 50, y: cardY + 45))
}

renderExactPNG(to: "\(dir9)/cta_banner.png") { ctx in
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 28, color: orangeColor.withAlphaComponent(0.65).cgColor)
    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 28, yRadius: 28)
    orangeColor.setFill()
    ctaPath.fill()
    ctx.restoreGState()

    NSColor.white.withAlphaComponent(0.4).setStroke()
    ctaPath.lineWidth = 2
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 26),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "🛒 DUKUNG BRAND LOKAL KEBANGGAAN • CEK PROMO HARI INI!", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 36, width: ctaW - 40, height: 50))
}


// =========================================================================
// LAYOUT 10: EDITORIAL QC STAMP & INSPECTION TICKET (Clip 10)
// Japanese natural off-white linen aesthetic, dashed divider, circular QC PASSED seal
// =========================================================================
let dir10 = "\(baseDir)/clip_10"
try? FileManager.default.createDirectory(atPath: dir10, withIntermediateDirectories: true, attributes: nil)

renderExactPNG(to: "\(dir10)/hook_card.png") { ctx in
    drawStandardHeader(topBadgeText: "100% ORIGINAL", in: ctx)

    let cardW: CGFloat = 980
    let cardH: CGFloat = 520
    let cardX: CGFloat = 50
    let cardY: CGFloat = 260
    let cardRect = NSRect(x: cardX, y: cardY, width: cardW, height: cardH)

    // Base Off-White Linen Paper Card
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 32, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 34, yRadius: 34)
    NSColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 0.98).setFill()
    cardPath.fill()
    ctx.restoreGState()

    // Subtle edge border
    NSColor(red: 0.85, green: 0.82, blue: 0.76, alpha: 1.0).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    // Distinctive Feature 1: Circular Crimson QC Passed Stamp on Top Right
    let stampCenterX: CGFloat = cardX + cardW - 110
    let stampCenterY: CGFloat = cardY + cardH - 65
    let stampRadius: CGFloat = 45
    let stampPath = NSBezierPath(ovalIn: NSRect(x: stampCenterX - stampRadius, y: stampCenterY - stampRadius, width: stampRadius * 2, height: stampRadius * 2))
    let crimsonColor = NSColor(red: 0.80, green: 0.15, blue: 0.10, alpha: 0.9)
    crimsonColor.setStroke()
    stampPath.lineWidth = 2.5
    stampPath.stroke()

    let stampPara = NSMutableParagraphStyle()
    stampPara.alignment = .center
    let stampAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 13),
        .foregroundColor: crimsonColor,
        .paragraphStyle: stampPara
    ]
    let stampText = NSAttributedString(string: "QC PASSED\n★ 100% ★\nCOTTON", attributes: stampAttrs)
    stampText.draw(in: NSRect(x: stampCenterX - stampRadius, y: stampCenterY - 22, width: stampRadius * 2, height: 50))

    // Distinctive Feature 2: Category Badge
    let tagPath = NSBezierPath(roundedRect: NSRect(x: cardX + 50, y: cardY + cardH - 85, width: 280, height: 42), xRadius: 8, yRadius: 8)
    NSColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0).setFill()
    tagPath.fill()

    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 18),
        .foregroundColor: NSColor.white
    ]
    let tagText = NSAttributedString(string: "🔍 DETAIL INSPEKSI & QC", attributes: tagAttrs)
    tagText.draw(at: NSPoint(x: cardX + 68, y: cardY + cardH - 74))

    // Headline (Editorial Serif Display)
    let para = NSMutableParagraphStyle()
    para.lineSpacing = 7
    para.alignment = .left

    let serifFont = NSFont(name: "Georgia-Bold", size: 34) ?? NSFont.boldSystemFont(ofSize: 34)
    let serifHighlight = NSFont(name: "Georgia-Bold", size: 37) ?? NSFont.boldSystemFont(ofSize: 37)

    let h1Attrs: [NSAttributedString.Key: Any] = [
        .font: serifFont,
        .foregroundColor: NSColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0),
        .paragraphStyle: para
    ]
    let h2Attrs: [NSAttributedString.Key: Any] = [
        .font: serifHighlight,
        .foregroundColor: crimsonColor,
        .paragraphStyle: para
    ]

    let headline = NSMutableAttributedString()
    headline.append(NSAttributedString(string: "REVIEW JUJUR OM DEDDY:\n", attributes: h1Attrs))
    headline.append(NSAttributedString(string: "\"JAHITANNYA RAPI BANGET, BAHAN ADEM GAK GERAH!\"", attributes: h2Attrs))
    headline.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 250, width: cardW - 100, height: 160))

    // Subtitle & Attribution
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor(red: 0.38, green: 0.40, blue: 0.45, alpha: 1.0)
    ]
    let sub = NSAttributedString(string: "Detailing Jahitan Kumis & Overdeck Rapi Standar Pakaian Jutaan", attributes: subAttrs)
    sub.draw(at: NSPoint(x: cardX + 50, y: cardY + 95))

    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .regular),
        .foregroundColor: NSColor(red: 0.55, green: 0.58, blue: 0.65, alpha: 1.0)
    ]
    let src = NSAttributedString(string: "Official Review • Broguy Apparel Indonesia", attributes: srcAttrs)
    src.draw(at: NSPoint(x: cardX + 50, y: cardY + 45))
}

renderExactPNG(to: "\(dir10)/cta_banner.png") { ctx in
    let ctaW: CGFloat = 980
    let ctaH: CGFloat = 110
    let ctaX: CGFloat = 50
    let ctaY: CGFloat = 140

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 26, color: NSColor.black.withAlphaComponent(0.6).cgColor)
    let ctaPath = NSBezierPath(roundedRect: NSRect(x: ctaX, y: ctaY, width: ctaW, height: ctaH), xRadius: 28, yRadius: 28)
    NSColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0).setFill()
    ctaPath.fill()
    ctx.restoreGState()

    orangeColor.setStroke()
    ctaPath.lineWidth = 2.5
    ctaPath.stroke()

    let ctaPara = NSMutableParagraphStyle()
    ctaPara.alignment = .center
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 25),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "🛒 CHECKOUT SEKARANG • JAMINAN KUALITAS & KEPUASAN 100%", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 36, width: ctaW - 40, height: 50))
}

print("Successfully generated 5 new distinct overlay packages in \(baseDir)")
