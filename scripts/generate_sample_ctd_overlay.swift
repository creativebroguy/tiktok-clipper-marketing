import Cocoa

let width: CGFloat = 1080
let height: CGFloat = 1920

let outDir = "/Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/assets/sample_ctd"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true, attributes: nil)

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

// 1. RENDER HOOK CARD OVERLAY
renderExactPNG(to: "\(outDir)/hook_card.png") { ctx in
    let cPara = NSMutableParagraphStyle()
    cPara.alignment = .center

    // Top Left Brand Logo: [B] BROGUY
    let logoBoxW: CGFloat = 52
    let logoBoxH: CGFloat = 52
    let logoX: CGFloat = 70
    let logoY: CGFloat = 1770

    let logoBox = NSBezierPath(roundedRect: NSRect(x: logoX, y: logoY, width: logoBoxW, height: logoBoxH), xRadius: 10, yRadius: 10)
    NSColor.white.setStroke()
    logoBox.lineWidth = 3.5
    logoBox.stroke()

    let bLetterAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 32),
        .foregroundColor: NSColor.white,
        .paragraphStyle: cPara
    ]
    let bLetter = NSAttributedString(string: "B", attributes: bLetterAttrs)
    bLetter.draw(in: NSRect(x: logoX, y: logoY + 4, width: logoBoxW, height: 42))

    let brandNameAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.boldSystemFont(ofSize: 36),
        .foregroundColor: NSColor.white
    ]
    let brandName = NSAttributedString(string: "BROGUY", attributes: brandNameAttrs)
    brandName.draw(at: NSPoint(x: logoX + logoBoxW + 18, y: logoY + 9))

    // Top Right Badge: "Fashion Info"
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
    let bText = NSAttributedString(string: "Fashion Info", attributes: bAttrs)
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

    // Speech bubble triangle pointing up
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

    // Inner card border
    NSColor(white: 0.90, alpha: 1.0).setStroke()
    cardPath.lineWidth = 1.5
    cardPath.stroke()

    // 1. Brand Pill: "BROGUY.ID"
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

    // 2. Headline Quotes with orange highlight
    let headPara = NSMutableParagraphStyle()
    headPara.lineSpacing = 6
    headPara.alignment = .left

    let regularHeadFont = NSFont(name: "Georgia-Bold", size: 36) ?? NSFont.boldSystemFont(ofSize: 36)

    let headlineM = NSMutableAttributedString()
    headlineM.append(NSAttributedString(string: "\"OM DEDDY: ", attributes: [
        .font: regularHeadFont,
        .foregroundColor: darkCharcoal,
        .paragraphStyle: headPara
    ]))
    headlineM.append(NSAttributedString(string: "'BUAT 70 RIBU INI BAGUS BANGET! ", attributes: [
        .font: regularHeadFont,
        .foregroundColor: orangeColor,
        .paragraphStyle: headPara
    ]))
    headlineM.append(NSAttributedString(string: "BAHANNYA ", attributes: [
        .font: regularHeadFont,
        .foregroundColor: darkCharcoal,
        .paragraphStyle: headPara
    ]))
    headlineM.append(NSAttributedString(string: "LUAR BIASA!'\"", attributes: [
        .font: regularHeadFont,
        .foregroundColor: orangeColor,
        .paragraphStyle: headPara
    ]))

    headlineM.draw(in: NSRect(x: cardX + 50, y: cardY + cardH - 260, width: cardW - 100, height: 170))

    // 3. Sub-headline / Social Proof
    let subPara = NSMutableParagraphStyle()
    subPara.alignment = .left
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
        .foregroundColor: mutedGrey,
        .paragraphStyle: subPara
    ]
    let subText = NSAttributedString(string: "Rekomendasi Kaos Pilihan Om Deddy di Close The Door", attributes: subAttrs)
    subText.draw(in: NSRect(x: cardX + 50, y: cardY + 75, width: cardW - 100, height: 35))

    // 4. Source Attribution
    let srcAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: lightGrey,
        .paragraphStyle: subPara
    ]
    let srcText = NSAttributedString(string: "Source : Youtube Deddy Corbuzier", attributes: srcAttrs)
    srcText.draw(in: NSRect(x: cardX + 50, y: cardY + 36, width: cardW - 100, height: 28))
}

// 2. RENDER CTA BANNER OVERLAY
renderExactPNG(to: "\(outDir)/cta_banner.png") { ctx in
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
        .font: NSFont.boldSystemFont(ofSize: 30),
        .foregroundColor: NSColor.white,
        .paragraphStyle: ctaPara
    ]
    let ctaText = NSAttributedString(string: "🛒 KLAIM VOUCHER DI KERANJANG KUNING SEKARANG!", attributes: ctaAttrs)
    ctaText.draw(in: NSRect(x: ctaX + 20, y: ctaY + 34, width: ctaW - 40, height: 50))
}

print("Exact 1080x1920 overlay generation complete!")
