//
//  BackgroundStreamTask.swift
//  LynkChat
//
//  Keeps AI streaming alive when the app backgrounds or locks
//  using iOS 26's BGContinuedProcessingTask.
//

#if !os(macOS)
import BackgroundTasks
import Foundation

@MainActor
enum BackgroundStreamTask {
    static let identifier = "com.SilverMarcs.LynkChatApp.aiStream"

    private static var registered = false
    private static var queue: [PendingItem] = []
    private static var activeProgress: Progress?

    private struct PendingItem {
        let task: Task<Void, Error>
        let subtitle: String
    }

    static func submit(streamingTask: Task<Void, Error>, subtitle: String) {
        registerIfNeeded()

        queue.append(PendingItem(task: streamingTask, subtitle: subtitle))

        let request = BGContinuedProcessingTaskRequest(
            identifier: identifier,
            title: "LynkChat",
            subtitle: subtitle
        )
        request.strategy = .queue

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            AppLogger.error("BGContinuedProcessingTask submit failed: \(error.localizedDescription)")
            queue.removeAll { $0.task == streamingTask }
        }
    }

    static func tickProgress() {
        guard let progress = activeProgress else { return }
        if progress.completedUnitCount < progress.totalUnitCount - 1 {
            progress.completedUnitCount += 1
        }
    }

    private static func registerIfNeeded() {
        guard !registered else { return }
        registered = true

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: .main
        ) { task in
            guard let bgTask = task as? BGContinuedProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(bgTask)
        }
    }

    private static func handle(_ bgTask: BGContinuedProcessingTask) {
        guard !queue.isEmpty else {
            bgTask.setTaskCompleted(success: false)
            return
        }
        let item = queue.removeFirst()

        bgTask.progress.totalUnitCount = 1000
        bgTask.progress.completedUnitCount = 0
        activeProgress = bgTask.progress

        bgTask.expirationHandler = {
            item.task.cancel()
        }

        Task { @MainActor in
            _ = try? await item.task.value
            if activeProgress === bgTask.progress {
                activeProgress = nil
            }
            bgTask.progress.completedUnitCount = bgTask.progress.totalUnitCount
            bgTask.setTaskCompleted(success: !item.task.isCancelled)
        }
    }
}
#endif
