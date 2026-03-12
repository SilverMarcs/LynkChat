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
        if let existingIndex = cacheOrder.firstIndex(of: request) {
            cacheOrder.remove(at: existingIndex)
        }
        cacheOrder.append(request)

        if cacheOrder.count > cacheLimit {
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
            await MacMarkdownRenderer(fontSize: request.fontSize, themeName: request.themeName).render(request.text)
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
    let isStreaming: Bool
    var calculatedHeight: Binding<CGFloat>?

    @MainActor
    final class Coordinator {
        private let streamingRenderDelay: Duration = .milliseconds(180)
        private var currentRequest: MarkdownRenderRequest?
        private var pendingRenderRequest: MarkdownRenderRequest?
        private var lastRenderedRequest: MarkdownRenderRequest?
        private var lastRenderedDocument: MarkdownRenderedDocument?
        private var renderTask: Task<Void, Never>?

        deinit {
            renderTask?.cancel()
        }

        func update(
            nsView: MarkdownContainerView,
            text: String,
            fontSize: CGFloat,
            themeName: String,
            isStreaming: Bool
        ) {
            let request = MarkdownRenderRequest(text: text, fontSize: fontSize, themeName: themeName)

            if let cachedDocument = MarkdownRenderCacheStore.document(for: request) {
                renderTask?.cancel()
                renderTask = nil
                pendingRenderRequest = nil
                applyRenderedDocument(cachedDocument, for: request, to: nsView)
                return
            }

            if isStreaming, let streamedDocument = streamedDocument(for: request) {
                currentRequest = request
                nsView.apply(document: streamedDocument, for: request)
            } else if lastRenderedDocument == nil {
                currentRequest = request
                nsView.showPlaceholder(text: text, fontSize: fontSize, for: request)
            } else {
                currentRequest = request
            }

            guard pendingRenderRequest != request || !isStreaming else {
                return
            }

            let renderDelay = isStreaming && shouldCoalesceStreamingRender(for: request)
                ? streamingRenderDelay
                : .zero
            pendingRenderRequest = request
            renderTask?.cancel()
            renderTask = Task { [weak nsView] in
                if renderDelay > .zero {
                    try? await Task.sleep(for: renderDelay)
                }

                guard !Task.isCancelled else { return }
                let document = await MarkdownRenderScheduler.shared.document(for: request)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    MarkdownRenderCacheStore.store(document, for: request)

                    guard let nsView, self.currentRequest == request else { return }
                    self.pendingRenderRequest = nil
                    self.applyRenderedDocument(document, for: request, to: nsView)
                }
            }
        }

        private func streamedDocument(for request: MarkdownRenderRequest) -> MarkdownRenderedDocument? {
            guard let lastRenderedRequest,
                  let lastRenderedDocument,
                  lastRenderedRequest.fontSize == request.fontSize,
                  lastRenderedRequest.themeName == request.themeName,
                  request.text.hasPrefix(lastRenderedRequest.text),
                  request.text != lastRenderedRequest.text else {
                return nil
            }

            let appendedText = String(request.text.dropFirst(lastRenderedRequest.text.count))
            guard !appendedText.isEmpty else {
                return lastRenderedDocument
            }

            return lastRenderedDocument.appendingPlainText(appendedText, fontSize: request.fontSize)
        }

        private func shouldCoalesceStreamingRender(for request: MarkdownRenderRequest) -> Bool {
            guard let lastRenderedRequest else { return false }
            return lastRenderedRequest.fontSize == request.fontSize &&
                lastRenderedRequest.themeName == request.themeName &&
                request.text.hasPrefix(lastRenderedRequest.text) &&
                request.text != lastRenderedRequest.text
        }

        private func applyRenderedDocument(
            _ document: MarkdownRenderedDocument,
            for request: MarkdownRenderRequest,
            to nsView: MarkdownContainerView
        ) {
            currentRequest = request
            lastRenderedRequest = request
            lastRenderedDocument = document
            nsView.apply(document: document, for: request)
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
                themeName: themeName,
                isStreaming: isStreaming
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
            themeName: nsView.activeThemeName,
            isStreaming: isStreaming
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
            themeName: nsView.activeThemeName,
            isStreaming: isStreaming
        )
        return nsView.measuredSize(for: width)
    }
}
#endif
