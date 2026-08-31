import WidgetKit
import SwiftUI

struct DuoEntry: TimelineEntry {
    let date: Date
    let user: String
    let tasks: [DuoTask]
    let error: Bool
}

struct DuoProvider: TimelineProvider {
    func placeholder(in context: Context) -> DuoEntry {
        DuoEntry(date: .now, user: "Luisa", tasks: [
            DuoTask(id: "1", title: "Conferir anúncios", description: nil, assignee: "Luisa", due_date: nil, priority: "high", status: "pending", created_by: nil, created_at: nil, client: "DAC"),
            DuoTask(id: "2", title: "Responder clientes", description: nil, assignee: "Luisa", due_date: nil, priority: "medium", status: "pending", created_by: nil, created_at: nil, client: nil)
        ], error: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (DuoEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DuoEntry>) -> Void) {
        Task {
            let user = SharedSession.user ?? "Luisa"
            guard let token = SharedSession.token else {
                completion(Timeline(entries: [DuoEntry(date: .now, user: user, tasks: [], error: true)], policy: .after(.now.addingTimeInterval(900))))
                return
            }

            do {
                let all = try await DuoAPI.fetchTasks(token: token)
                let today = DateFormatter.duoToday.string(from: Date())
                let visible = all.filter {
                    $0.assignee == user &&
                    $0.status != "done" &&
                    ($0.due_date == nil || $0.due_date == today)
                }
                .sorted { rank($0.priority) < rank($1.priority) }

                let entry = DuoEntry(date: .now, user: user, tasks: Array(visible.prefix(5)), error: false)
                completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900))))
            } catch {
                completion(Timeline(entries: [DuoEntry(date: .now, user: user, tasks: [], error: true)], policy: .after(.now.addingTimeInterval(600))))
            }
        }
    }

    private func rank(_ value: String) -> Int {
        switch value {
        case "high": return 0
        case "medium": return 1
        default: return 2
        }
    }
}

extension DateFormatter {
    static let duoToday: DateFormatter = {
        let d = DateFormatter()
        d.calendar = Calendar(identifier: .gregorian)
        d.locale = Locale(identifier: "en_US_POSIX")
        d.dateFormat = "yyyy-MM-dd"
        return d
    }()
}

struct DuoWidgetView: View {
    let entry: DuoEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("DUO Task")
                    .font(.headline.bold())
                Spacer()
                Text(entry.user)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            if entry.error {
                Spacer()
                Text("Abra o DUO Task para atualizar o acesso.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            } else if entry.tasks.isEmpty {
                Spacer()
                Label("Tudo certo por hoje", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(4)) { task in
                    HStack(alignment: .top, spacing: 7) {
                        Circle()
                            .frame(width: 7, height: 7)
                            .padding(.top, 5)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(task.title)
                                .font(.caption.bold())
                                .lineLimit(1)
                            if let client = task.client, !client.isEmpty {
                                Text(client)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Spacer(minLength: 0)
                Text("\(entry.tasks.count) tarefa(s) para hoje")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(DuoConfig.siteURL)
    }
}

struct DUOTaskWidget: Widget {
    let kind = "DUOTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuoProvider()) { entry in
            DuoWidgetView(entry: entry)
        }
        .configurationDisplayName("Tarefas de Hoje")
        .description("Veja as tarefas do dia sem abrir o DUO Task.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DUOTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        DUOTaskWidget()
    }
}
