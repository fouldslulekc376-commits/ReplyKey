import SwiftUI
import UIKit

/// 键盘本体：上半部分是「AI 回复」区，下半部分是标准 QWERTY。
struct KeyboardView: View {
    let needsGlobe: Bool
    let onInsert: (String) -> Void
    let onDelete: () -> Void
    let onReturn: () -> Void
    let onGlobe: () -> Void

    @State private var replies: [String] = []
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var shift = true
    @State private var numeric = false

    init(
        needsGlobe: Bool,
        onInsert: @escaping (String) -> Void,
        onDelete: @escaping () -> Void,
        onReturn: @escaping () -> Void,
        onGlobe: @escaping () -> Void
    ) {
        self.needsGlobe = needsGlobe
        self.onInsert = onInsert
        self.onDelete = onDelete
        self.onReturn = onReturn
        self.onGlobe = onGlobe
    }

    private let letterRows: [[String]] = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]

    private let numberRows: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "¥", "&", "@", "\""],
        [".", ",", "?", "!", "'", "*", "#", "%", "+"]
    ]

    private var rows: [[String]] { numeric ? numberRows : letterRows }

    var body: some View {
        VStack(spacing: 6) {
            replyBar
            ForEach(Array(rows.indices), id: \.self) { index in
                keyRow(index: index, keys: rows[index])
            }
            bottomRow
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.82, green: 0.83, blue: 0.86))
    }

    // MARK: - AI 回复区

    private var replyBar: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Button(action: generate) {
                    HStack(spacing: 5) {
                        Image(systemName: isLoading ? "hourglass" : "sparkles")
                        Text(isLoading ? "生成中…" : "高情商回复")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.95, green: 0.35, blue: 0.45))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Text(errorText ?? "复制对方消息，再点左边")
                    .font(.system(size: 11))
                    .foregroundColor(errorText == nil ? Color.black.opacity(0.5) : .red)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(replies, id: \.self) { text in
                        Button(action: { onInsert(text) }) {
                            Text(text)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 38)
        }
        .frame(height: 84, alignment: .top)
        .padding(.horizontal, 2)
    }

    // MARK: - 键盘区

    private func keyRow(index: Int, keys: [String]) -> some View {
        HStack(spacing: 5) {
            if index == 2 && !numeric {
                cap("⇧", width: 44) { shift.toggle() }
            }

            ForEach(keys, id: \.self) { key in
                cap(displayText(for: key)) { tap(key) }
            }

            if index == 2 {
                cap("⌫", width: 44) { onDelete() }
            }
        }
        .padding(.horizontal, index == 1 ? 14 : 0)
    }

    private var bottomRow: some View {
        HStack(spacing: 5) {
            cap(numeric ? "ABC" : "123", width: 48) { numeric.toggle() }

            if needsGlobe {
                cap("🌐", width: 40) { onGlobe() }
            }

            cap("空格") { onInsert(" ") }

            cap("↵", width: 56) { onReturn() }
        }
    }

    private func cap(_ title: String, width: CGFloat? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: title.count > 1 ? 15 : 20))
                .foregroundColor(.black)
                .frame(minWidth: 0, maxWidth: width ?? .infinity, minHeight: 40, maxHeight: 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }

    private func displayText(for key: String) -> String {
        if numeric { return key }
        return shift ? key.uppercased() : key
    }

    private func tap(_ key: String) {
        if !numeric && shift {
            onInsert(key.uppercased())
            shift = false
        } else {
            onInsert(key)
        }
    }

    // MARK: - 生成

    private func generate() {
        guard !isLoading else { return }

        let raw = (UIPasteboard.general.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            errorText = "先复制对方的消息"
            return
        }

        isLoading = true
        errorText = nil
        replies = []

        let message = String(raw.prefix(500))

        Task {
            do {
                let result = try await ReplyEngine.generate(for: message)
                await MainActor.run {
                    isLoading = false
                    let picked = Array(result.prefix(3))
                    replies = picked
                    if picked.isEmpty {
                        errorText = "没生成出东西，再试一次"
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorText = error.localizedDescription
                }
            }
        }
    }
}
