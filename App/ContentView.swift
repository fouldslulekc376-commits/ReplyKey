import SwiftUI

struct ContentView: View {
    private var keyConfigured: Bool {
        !Secrets.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusCard
                    stepsCard
                    notesCard
                }
                .padding(20)
            }
            .navigationTitle("高情商回复")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("复制 → 生成 → 上屏")
                .font(.title2.bold())
            Text("这个 App 本身没有界面功能，真正干活的是键盘扩展。")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private var statusCard: some View {
        HStack(spacing: 10) {
            Image(systemName: keyConfigured ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(keyConfigured ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(keyConfigured ? "API Key 已配置" : "API Key 还没配置")
                    .font(.subheadline.bold())
                Text(keyConfigured ? "模型：\(Secrets.model)" : "去 GitHub 仓库 Settings 里加 Secret：API_KEY")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("怎么用").font(.headline)

            step(1, "启用键盘", "设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → 高情商回复")
            step(2, "打开完全访问", "在同一页点进「高情商回复」，把「允许完全访问」打开")
            step(3, "复制对方的消息", "在微信里长按消息 → 复制")
            step(4, "切键盘并生成", "点输入框 → 长按地球键切到本键盘 → 点「高情商回复」")
            step(5, "点一条上屏", "候选出现在按钮下方，点一下直接插入")
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("几个说明").font(.headline)
            bullet("密码框里系统会强制切回苹果键盘，这是苹果的限制")
            bullet("第一次读剪贴板可能弹「允许粘贴」，点允许即可")
            bullet("免费 Apple ID 签名 7 天过期，到期重新用 Sideloadly 覆盖安装")
            bullet("本键盘不做中文拼音，中文打字请用系统键盘")
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func step(_ index: Int, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(index)")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.accentColor)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("·").font(.subheadline.bold())
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
