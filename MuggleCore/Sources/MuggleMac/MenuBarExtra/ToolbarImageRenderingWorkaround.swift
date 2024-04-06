import SwiftUI

protocol MacOSToolbarImageRenderingWorkaroundView: View {
  static var id: String { get }
  @MainActor init()
}

extension MacOSToolbarImageRenderingWorkaroundView {
  static var id: String { "\(Self.self)" }
}

extension View {
  @MainActor
  func render<Content: MacOSToolbarImageRenderingWorkaroundView>(_ content: Content.Type) -> Image? {
    if let image = cache[Content.id] { return image }
    let renderer = ImageRenderer(content: content.init())
    renderer.scale = 3
    renderer.isOpaque = false
    #if os(macOS)
    guard let render = renderer.nsImage else { return nil }
    render.isTemplate = true
    let image = Image(nsImage: render)
    #elseif os(visionOS)
    guard let render = renderer.uiImage?.withRenderingMode(.alwaysTemplate) else { return nil }
    let image = Image(uiImage: render)
    #endif
    cache[Content.id] = image
    return image
  }
}

private var cache: [String: Image] = [:]

// MARK: - "Images"

struct ConnectingMug: MacOSToolbarImageRenderingWorkaroundView {
  var body: some View {
    ZStack {
      EmptyMug()
        .opacity(0.75)

      let size = 7.0
      Image(systemName: "magnifyingglass")
        .resizable()
        .scaledToFit()
        .fontWeight(.bold)
        .frame(width: size, height: size)
        .offset(x: -1.4, y: 1)
    }
  }
}

struct EmptyMug: MacOSToolbarImageRenderingWorkaroundView {
  var body: some View {
    let size = 16.0
    Image(systemName: "mug")
      .resizable()
      .scaledToFit()
      .fontWeight(.semibold)
      .frame(width: size, height: size)
  }
}

struct EmptyChargingMug: MacOSToolbarImageRenderingWorkaroundView {
  var body: some View {
    ZStack {
      EmptyMug()
        .opacity(0.75)

      let size = 8.0
      Image(systemName: "bolt.fill")
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .offset(x: -1.4, y: 1)
    }
  }
}

struct FullMug: MacOSToolbarImageRenderingWorkaroundView {
  var body: some View {
    let size = 16.0
    Image(systemName: "mug.fill")
      .resizable()
      .scaledToFit()
      .fontWeight(.semibold)
      .frame(width: size, height: size)
  }
}

struct FullChargingMug: MacOSToolbarImageRenderingWorkaroundView {
  var body: some View {
    ZStack {
      FullMug()

      let size = 10.5
      Image(systemName: "bolt.fill")
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .offset(x: -1.4, y: 1)
        .blendMode(.destinationOut)
    }
  }
}
