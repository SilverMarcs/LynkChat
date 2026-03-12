import SwiftUI

#if os(macOS)
struct MarkdownRenderRequest: Hashable, Sendable {
    let text: String
    let fontSize: CGFloat
    let themeName: String
}

@MainActor
private enum MarkdownRenderCacheStore {
    private static let cacheLimit = 120
    private static var cachedDocuments: [MarkdownRenderRequest: MarkdownRenderedDocument] = [:]
    private static var cacheOrder: [MarkdownRenderRequest] = []

    static func document(for request: MarkdownRenderRequest) -> MarkdownRenderedDocument? {
        cachedDocuments[request]
    }

    static func store(_ document: MarkdownRenderedDocument, for request: MarkdownRenderRequest) {
        cachedDocuments[request] = document
        cacheOrder.removeAll { $0 == request }
        cacheOrder.append(request)

        while cacheOrder.count > cacheLimit {
            let evictedRequest = cacheOrder.removeFirst()
            cachedDocuments.removeValue(forKey: evictedRequest)
        }
    }
}

actor MarkdownRenderScheduler {
    static let shared = MarkdownRenderScheduler()

    private var inFlightTasks: [MarkdownRenderRequest: Task<MarkdownRenderedDocument, Never>] = [:]

    func document(for request: MarkdownRenderRequest) async -> MarkdownRenderedDocument {
        if let existingTask = inFlightTasks[request] {
            return await existingTask.value
        }

        let renderTask = Task.detached(priority: .utility) {
            MacMarkdownRenderer(fontSize: request.fontSize, themeName: request.themeName).render(request.text)
        }

        inFlightTasks[request] = renderTask
        let document = await renderTask.value
        inFlightTasks[request] = nil
        return document
    }
}

struct MacMarkdownRepresentable: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    var calculatedHeight: Binding<CGFloat>?

    @MainActor
    final class Coordinator {
        private var currentRequest: MarkdownRenderRequest?
        private var renderTask: Task<Void, Never>?

        deinit {
            renderTask?.cancel()
        }

        func update(
            nsView: MarkdownContainerView,
            text: String,
            fontSize: CGFloat,
            themeName: String
        ) {
            let request = MarkdownRenderRequest(text: text, fontSize: fontSize, themeName: themeName)

            if let cachedDocument = MarkdownRenderCacheStore.document(for: request) {
                currentRequest = request
                renderTask?.cancel()
                renderTask = nil
                nsView.apply(document: cachedDocument, for: request)
                return
            }

            nsView.showPlaceholder(text: text, fontSize: fontSize, for: request)

            guard currentRequest != request else {
                return
            }

            currentRequest = request
            renderTask?.cancel()
            renderTask = Task { [weak nsView] in
                let document = await MarkdownRenderScheduler.shared.document(for: request)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    MarkdownRenderCacheStore.store(document, for: request)

                    guard let nsView, self.currentRequest == request else { return }
                    nsView.apply(document: document, for: request)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> MarkdownContainerView {
        MarkdownContainerView()
    }

    func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
        nsView.onThemeChange = { [weak nsView] themeName in
            guard let nsView else { return }
            context.coordinator.update(
                nsView: nsView,
                text: text,
                fontSize: fontSize,
                themeName: themeName
            )
        }
        nsView.onHeightChange = { newHeight in
            guard let calculatedHeight, calculatedHeight.wrappedValue != newHeight else { return }
            calculatedHeight.wrappedValue = newHeight
        }
        context.coordinator.update(
            nsView: nsView,
            text: text,
            fontSize: fontSize,
            themeName: nsView.activeThemeName
        )
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: MarkdownContainerView,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width else { return nil }
        context.coordinator.update(
            nsView: nsView,
            text: text,
            fontSize: fontSize,
            themeName: nsView.activeThemeName
        )
        return nsView.measuredSize(for: width)
    }
}
#endif
