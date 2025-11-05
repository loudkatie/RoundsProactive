import SwiftUI

// AppState: controls which screen the user is on
final class AppState: ObservableObject {
    enum Screen {
        case splash
        case onboarding
        case record
        case summary
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
        }
    }
}

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
                colors: [
                    Color.blue.opacity(0.95),
                    Color.cyan.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.95))
                    .scaleEffect(breathe ? 1.06 : 0.94)
                    .animation(
                        .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                        value: breathe
                    )

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
            // after a beat, move forward
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                appState.proceed()
            }
        }
    }
}

// MARK: - Onboarding Screen
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to Rounds")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(
                "I’ll help you remember what happened, in plain language you can share with family. " +
                "You don’t have to figure this out alone."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .padding(.horizontal)

            Button {
                appState.proceed()
            } label: {
                Text("Start a Round")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.blue)
                    )
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Recording Screen
struct RecordView: View {
    @EnvironmentObject var appState: AppState
    @State private var recording = false

    var body: some View {
        VStack(spacing: 28) {
            Text("Tell me what happened today.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Button {
                recording.toggle()
            } label: {
                Image(systemName: recording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(recording ? .red : .blue)
                    .shadow(radius: recording ? 8 : 0)
                    .padding()
            }

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
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.cyan)
                    )
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)

            Spacer(minLength: 20)
        }
        .padding()
    }
}

// MARK: - Summary Screen
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

                        Text(
                          """
                          • The care team reviewed progress and adjusted medications.
                          • They’re watching oxygen levels and pain control.
                          • Overall stable. Small steps forward.

                          You can share this with family.
                          """
                        )
                        .foregroundStyle(.secondary)
                        .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
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
            // fake "AI is working..." delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                loading = false
            }
        }
    }
}
