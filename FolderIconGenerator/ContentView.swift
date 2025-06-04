import AppKit
import SwiftUI

struct ContentView: View {
    @AppStorage("symbolName") var symbolName = "custom.folder.fill.badge.sparkles"

    @AppStorage("luminanceToAlpha") var luminanceToAlpha = true

    @State var customIcon: Image?
    
    private var isCustomIcon: Bool {
        customIcon != nil
    }

    var body: some View {
        VStack(spacing: 16) {
            let content = Image(ImageResource.folder512)
                .alignmentGuide(.firstTextBaseline) { d in
                    d[.bottom] - d.height * 0.375
                }
                .overlay(alignment: .centerFirstTextBaseline) {
                    let cgImage: CGImage? = customIcon.flatMap { icon in
                        let content = icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                        return if luminanceToAlpha {
                            ImageRenderer(content: content
                                .background(.white)
                                .colorInvert()
                                .drawingGroup()
                                .luminanceToAlpha()
                            ).cgImage
                        } else {
                            ImageRenderer(content: content).cgImage
                        }
                    }

                    ZStack {
                        if let cgImage {
                            Image(systemName: "circle")
                                .hidden()
                                .overlay {
                                    let image = Image(decorative: cgImage, scale: 1)

                                    image
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaleEffect(0.85)
                                }
                        } else {
                            Image(_internalSystemName: symbolName)
                            Image(symbolName)
                        }
                    }
                    .font(.system(size: 180))
                    .offset(y: 25)
                    .foregroundStyle(
                        Color.folder
                            .shadow(.inner(color: .black.opacity(0.1), radius: 0.5, y: 0.5))
                            .shadow(.drop(color: .white.opacity(0.4), radius: 1, y: 1))
                    )
                }

            let renderer: ImageRenderer = {
                let r = ImageRenderer(content: content)
                r.proposedSize = .init(width: 512, height: 512)
                r.scale = 2

                return r
            }()

            GroupBox {
                if let cgImage = renderer.cgImage {
                    let image = Image(decorative: cgImage, scale: 1)

                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .draggable(image)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .contextMenu {
                            Button("Copy") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.writeObjects([NSImage(cgImage: cgImage, size: .init(width: 1024, height: 1024))])
                            }

                            Section {
                                Toggle("Use Luminance as Alpha Channel", isOn: $luminanceToAlpha)

                                Button("Clear Custom Icon") {
                                    customIcon = nil
                                }
                            }
                            .disabled(!isCustomIcon)
                        }
                }
            }
            .dropDestination(for: URL.self) { urls, _ in
                guard let url = urls.first,
                      let nsImage = NSImage(contentsOf: url) else { return false }
                
                customIcon = Image(nsImage: nsImage)

                return true
            }

            GroupBox {
                LabeledContent("Symbol Name:") {
                    TextField("person.fill", text: $symbolName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(8)
            }
            .disabled(isCustomIcon)

            HStack {
                Label("[How to change icons for folders on macOS](https://support.apple.com/guide/mac-help/change-icons-for-files-or-folders-on-mac-mchlp2313/mac)", systemImage: "info.circle.fill")

                Spacer()

                Text("by [Robb Böhnke](https://robb.is)")
            }
            .labelStyle(InlineLabelStyle())
            .foregroundStyle(.secondary)
            .font(.caption)
            .tracking(0.3)
            .imageScale(.large)
        }
        .padding()
        .frame(width: 512, height: 512)
        .navigationTitle("Folder Icon Generator")
    }
}

struct InlineLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Color.clear
                .frame(width: 13, height: 8)
                .overlay(alignment: .centerFirstTextBaseline) {
                    configuration.icon
                }

            configuration.title
        }
    }
}

extension Image {
    @_silgen_name("$s7SwiftUI5ImageV19_internalSystemNameACSS_tcfC")
    init(_internalSystemName: String)
}

#Preview {
    ContentView()
}
