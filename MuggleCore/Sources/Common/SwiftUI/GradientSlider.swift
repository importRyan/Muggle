import SwiftUI

/// Apply track gradient using `.backgroundStyle`
public struct GradientSlider<Label: View>: View {

  public init(value: Binding<Double>, range: ClosedRange<Double>, interiorLabel: Label, onEditingEnded: @escaping () -> Void) {
    self.value = value
    self.range = range
    self.interiorLabel = interiorLabel
    self.onEditingEnded = onEditingEnded
  }

  private let value: Binding<Double>
  private let range: ClosedRange<Double>
  private let interiorLabel: Label
  private let onEditingEnded: () -> Void
  @Environment(\.controlSize.points) private var size

  public var body: some View {
    Component(
      value: value,
      range: range,
      interiorLabel: interiorLabel,
      onEditingEnded: onEditingEnded,
      size: size,
      trackInset: size / 2
    )
  }
}

// MARK: - Component

private struct Component<Label: View>: View {

  @Binding var value: Double
  let range: ClosedRange<Double>
  let interiorLabel: Label
  let onEditingEnded: () -> Void
  let size: CGFloat
  let trackInset: CGFloat

  @Environment(\.isEnabled) var isEnabled
  @FocusState private var isFocused
  @State private var isHovered = false
  @GestureState private var isInteracting = false

  var body: some View {
    GeometryReader { geo in
      ZStack {
        Track()

        let trackWidth = geo.size.width
        let x: CGFloat = range.percentage(value) * trackWidth
        let xRange = trackInset...(trackWidth - trackInset)
        Thumb(
          isInteracting: isInteracting,
          isTrackHovered: isHovered,
          label: interiorLabel,
          size: size
        )
        .position(x: x.clamped(xRange), y: trackInset)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .simultaneousGesture(
          SimultaneousGesture(tap(trackWidth), slide(trackWidth)),
          including: isEnabled ? .all : []
        )
      }
    }
    .frame(height: size)
    .onHover(perform: onHover)
    .accessibilityElement()
    .accessibilityAdjustableAction(accessibilityAdjustableAction)
    .contentShape(.capsule)
    .focusable(isEnabled, interactions: isEnabled ? [.activate, .edit] : [.activate])
    .focused($isFocused)
    .focusEffectDisabled()
  }
}

private extension Component {

  func accessibilityAdjustableAction(direction: AccessibilityAdjustmentDirection) {
    func animateValue(_ newValue: Double) {
      withAnimation(.smooth.fast) {
        value = newValue
      }
      onEditingEnded()
    }
    switch direction {
    case .increment: animateValue(min(value + 1, range.upperBound))
    case .decrement: animateValue(max(value - 1, range.lowerBound))
    @unknown default: Log.app.warning("accessibilityAdjustableAction unknown case")
    }
  }

  func onHover(_ isHovering: Bool) {
    guard isEnabled else {
      isHovered = false
      return
    }
    isHovered = isHovering
    isFocused = isHovering
  }

  func slide(_ trackWidth: CGFloat) -> _EndedGesture<GestureStateGesture<_ChangedGesture<DragGesture>, Bool>> {
    DragGesture(minimumDistance: 3)
      .onChanged { gesture in
        if isInteracting {
          value = range.boundedValue(percentage: gesture.location.x / trackWidth)
          return
        }
        withAnimation(.smooth.fast) {
          value = range.boundedValue(percentage: gesture.location.x / trackWidth)
        }
      }
      .updating($isInteracting) { _, state, _ in state = true }
      .onEnded { _ in onEditingEnded() }
  }

  func tap(_ trackWidth: CGFloat) -> _EndedGesture<SpatialTapGesture> {
    SpatialTapGesture()
      .onEnded { gesture in
        withAnimation(.smooth.fast) {
          value = range.boundedValue(percentage: gesture.location.x / trackWidth)
          onEditingEnded()
        }
      }
  }
}

private struct Thumb<Label: View>: View {
  let isInteracting: Bool
  let isTrackHovered: Bool
  let label: Label
  let size: CGFloat

  private var shadowRadius: CGFloat {
    var base = 4.0
    if isInteracting { base += 3 }
    if isHovered { base += 5 }
    if isTrackHovered { base += 3 }
    return base
  }

  private var scaleEffect: CGFloat {
    var base = 1.0
    if isInteracting { base *= 1.2 }
    if isHovered { base *= 1.05 }
    if isTrackHovered { base *= 1.05 }
    return base
  }

  @State private var isHovered = false

  var body: some View {
    ZStack {
      Circle().opacity(0.93)
      Circle().strokeBorder(lineWidth: 1)
      label
        .foregroundStyle(.black.opacity(0.8))
        .frame(width: size, height: size)
        .clipShape(.circle)
    }
    .foregroundStyle(.white)
    .frame(width: size, height: size)
    .compositingGroup()
    .animation(.bouncy) {
      $0
        .shadow(radius: shadowRadius, x: 1, y: 1)
        .scaleEffect(scaleEffect)
    }
    .onHover { isHovered = $0 }
  }
}

private struct Track: View {
  @Environment(\.isEnabled) var isEnabled

  var body: some View {
    Capsule()
      .fill(.background)
      .grayscale(isEnabled ? 0 : 1)
  }
}
