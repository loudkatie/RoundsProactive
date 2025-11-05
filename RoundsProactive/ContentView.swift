import SwiftUI
import Combine

// Feature flags from Scheme ▸ Run ▸ Environment
private let ROUNDS_TEST_MODE: Bool = ProcessInfo.processInfo.environment["ROUNDS_TEST_MODE"] == "1"
private let OPENAI_API_KEY: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

// MARK: - Global app navigation / state machine
@MainActor
final class AppState: ObservableObject {

    enum Screen {
        case splash        // breathing heart, “I’m here when you’re ready”
        case onboarding    // welcome / “Start a Round”
        case record        // mic screen + live transcript
        case summary       // plain-English summary / Save or Discard
        case aiExplain     // fake ChatGPT-style explain flow (demo)
    }

    @Published var currentScreen: Screen = .splash

    func proceed() {
        switch currentScreen {
        case .splash:
            currentScreen = .onboarding
        case .onboarding:
            currentScreen = .record
        case .record:
            currentScreen = .summary
        case .summary:
            currentScreen = .splash
        case .aiExplain:
            currentScreen = .splash
        }
    }
}

// MARK: - Root
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.currentScreen {
        case .splash:
            SplashView()
        case .onboarding:
            OnboardingView()
        case .record:
            RecordView()
        case .summary:
            SummaryView()
        case .aiExplain:
            AIExplainView()
        }
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var breathe = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.95), Color.cyan.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.95))
                    .scaleEffect(breathe ? 1.06 : 0.94)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: breathe)

                Text("Rounds")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)

                Text("I’m here when you’re ready.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 32)
            }
            .padding()
        }
        .ignoresSafeArea()
        .onAppear {
            breathe = true
            // slowed down for demo
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                appState.proceed()
            }
        }
    }
}

// MARK: - Onboarding
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Rounds")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("I’ll help you remember what happened, in plain language you can share with family. You don’t have to figure this out alone.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                appState.proceed()
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.blue))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Record + live transcript (UI-only in test mode)
struct RecordView: View {
    @EnvironmentObject var appState: AppState
    @State private var recording = false
    @State private var transcript: String = ""
    @State private var tick = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            // Branded header
            HStack {
                Image(systemName: "heart.circle.fill").font(.title2).foregroundStyle(.blue)
                Text("Rounds").font(.title3.bold())
                Spacer()
            }
            .padding(.horizontal)

            Text("Tell me what happened today.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            Button {
                recording.toggle()
            } label: {
                Image(systemName: recording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(recording ? .red : .blue)
                    .shadow(radius: recording ? 8 : 0)
                    .padding()
            }

            // Live transcript window
            ScrollView {
                Text(transcript.isEmpty
                     ? "Live transcript will appear here while you’re recording."
                     : transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 180)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))
            .padding(.horizontal)

            Text(recording ? "Recording…" : "Ready")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                appState.proceed()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.cyan))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)

            Spacer(minLength: 12)
        }
        .padding()
        // Simulate transcript growth in test mode
        .onReceive(tick) { _ in
            guard ROUNDS_TEST_MODE, recording else { return }
            let samples = [
                "Team reviewed vitals and overnight notes.",
                "Oxygen looked stable; continuing current settings.",
                "Pain control adjusted; monitoring effect.",
                "Plan: short walk with PT this afternoon."
            ]
            if let next = samples.randomElement() {
                transcript += (transcript.isEmpty ? "" : "\n") + "• " + next
            }
        }
        .onChange(of: recording) { isRec in
            if isRec && transcript.isEmpty {
                transcript = "• Listening… I’ll capture what’s said."
            }
        }
    }
}

// MARK: - Summary
struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var loading = true

    var body: some View {
        VStack(spacing: 22) {
            Text("Reflection")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal)

            Group {
                if loading {
                    ProgressView("Analyzing…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Here’s what matters today:")
                            .font(.headline)

                        Text("""
                        • The care team reviewed progress and adjusted medications.
                        • They’re watching oxygen levels and pain control.
                        • Overall stable. Small steps forward.

                        You can share this with family.
                        """)
                        .foregroundStyle(.secondary)
                        .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))

                    // Lead-in to AI explain flow (demo)
                    Button {
                        appState.currentScreen = .aiExplain
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                            Text("Understand with Rounds AI")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.blue))
                        .foregroundStyle(.white)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Discard") {
                    appState.currentScreen = .splash
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    appState.currentScreen = .splash
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            Spacer()
        }
        .onAppear {
            // fake “AI is working…” delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                loading = false
            }
        }
    }
}

// MARK: - AI Explain (UI-only demo when ROUNDS_TEST_MODE == 1)
struct AIExplainView: View {
    @EnvironmentObject var appState: AppState
    @State private var messages: [(role: String, text: String)] = []
    @State private var isTyping = false

    var body: some View {
        VStack(spacing: 0) {
            // Branded header
            HStack {
                Image(systemName: "heart.circle.fill").font(.title2).foregroundStyle(.blue)
                Text("Rounds AI").font(.title3.bold())
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                        HStack {
                            if msg.role == "ai" {
                                Text(msg.text)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer(minLength: 20)
                            } else {
                                Spacer(minLength: 20)
                                Text(msg.text)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.blue.opacity(0.15)))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                    if isTyping {
                        HStack {
                            Text("…")
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))
                            Spacer()
                        }
                    }
                }
                .padding()
            }

            HStack(spacing: 12) {
                Button("Done") {
                    appState.currentScreen = .splash
                }
                .buttonStyle(.bordered)

                Button("Copy Summary") {
                    let all = messages.map { ($0.role == "ai" ? "Rounds AI: " : "You: ") + $0.text }.joined(separator: "\n\n")
                    UIPasteboard.general.string = all
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear {
            runDemo()
        }
    }

    private func runDemo() {
        messages.removeAll()
        // If not in test mode and we had a key, we’d call the API here.
        // For demo: staged, friendly “doctor-brother” flow.
        appendAI("Hi, I’m here to help make sense of what was said. I’ll be brief and in plain language.")
        appendAI("From today’s notes: oxygen looked stable, pain control was adjusted, and PT is planned. No red flags were mentioned.")
        appendAI("Would you like a short list of follow-up questions for tomorrow?")
    }

    private func appendAI(_ text: String) {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            messages.append(("ai", text))
            isTyping = false
        }
    }
}
