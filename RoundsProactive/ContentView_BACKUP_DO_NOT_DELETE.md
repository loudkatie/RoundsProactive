# **ROUNDS: The Human Calm in the Room**  
*A Loud Labs Project — Master Product + Engineering Plan*  
Version 1.0 | November 2025  

---

## 🩵 CLIENT OVERVIEW — HUMAN-FACING PLAN

### **Project Summary**
**Rounds** is a calm, AI-assisted reflection app for caregivers. It helps them record moments, thoughts, and updates about their loved ones — then summarizes and stores those reflections. The app proactively guides the caregiver through each step, much like Apple’s setup experience: intuitive, gentle, and trustworthy.

Rounds will launch as an **iOS 17 app** built in **SwiftUI**, integrated with **OpenAI’s 4o-mini model** for cost-efficient, warm summaries.

---

### **The Vision**
> “Hi. I’m here when you’re ready.”  
> That’s the essence of Rounds — a small companion that reduces cognitive load for those holding others together.

---

### **Goals**
1. Build an elegant MVP ready for **TestFlight demonstration to investors**.  
2. Show the potential for **AI-driven reflection and memory** while staying cost-efficient (~$10/week API budget).  
3. Maintain Apple-level polish: beautiful design, intuitive onboarding, warm tone, and zero friction.  
4. Create a base for future persistent memory, multi-user support, and push-driven continuity.

---

### **Target Users**
Primary: caregivers and family members of patients.  
Secondary: healthcare teams seeking emotional support tools for families.

---

### **Experience Flow**
| Stage | Description | Example Prompt |
|--------|--------------|----------------|
| **1. Greeting** | Animated Care Loop greets user. | “Hi. I’m here when you’re ready.” |
| **2. Permissions** | Voice explains why mic and notifications matter. | “This helps me listen when you’re ready to talk.” |
| **3. Recording** | Single glowing mic button, live waveform halo. | “You can talk about how today went.” |
| **4. Reflection** | AI summarizes with empathy. | “Here’s what you shared — would you like me to save it?” |
| **5. Reminder Loop** | Optional gentle notifications. | “It’s time for your next round.” |

---

### **Look & Feel**
- **Color palette:** cool blues (`#3A5EE0`, `#2EB1E6`, `#F5F8FF`)  
- **Typeface:** SF Pro Rounded  
- **Style:** Minimal, tactile, alive in motion  
- **Interaction:** Tap, breathe, listen — no clutter.  

---

### **Delivery Timeline**
| Phase | Milestone | Delivery |
|--------|------------|-----------|
| **1. Brand & Design System** | Logo, color, motion guidelines | ✅ Complete |
| **2. Core Build** | Onboarding, Recording, Reflection MVP | Week 1 |
| **3. AI Integration** | GPT-4o-mini reflection + caching | Week 2 |
| **4. Push & Notifications** | Local notifications for reminders | Week 3 |
| **5. TestFlight Demo Build** | VC-ready | End of Week 3 |

---

### **What You’ll Receive**
- **TestFlight-ready app** (`RoundsProactive`)  
- **GitHub Repo:** `github.com/LoudKatie/RoundsProactive`  
- **Assets:** App icon, Care Loop animation, marketing banner  
- **Docs:** README, onboarding script, press kit  

---

---

## ⚙️ ENGINEERING PRODUCT PLAN — INTERNAL USE

### **Architecture**
- **Language:** Swift 6.2  
- **Framework:** SwiftUI, Combine, AVFoundation, CoreData  
- **AI Layer:** OpenAI GPT-4o-mini  
- **Target:** iOS 17+  
- **Build System:** Xcode 16+  
- **Source Control:** GitHub (private repo, Loud Labs org)  
- **CI/CD:** GitHub Actions (lint + build validation)  

---

### **File Hierarchy**
```
RoundsProactive/
 ├── App/
 │   ├── RoundsApp.swift
 │   ├── AppState.swift
 ├── DesignSystem/
 │   ├── Color+Rounds.swift
 │   ├── Typography.swift
 │   ├── ComponentLibrary.swift
 │   └── CareLoopAnimation.swift
 ├── Features/
 │   ├── Onboarding/
 │   ├── Recording/
 │   ├── Reflection/
 ├── Services/
 │   ├── SpeechManager.swift
 │   ├── OpenAIService.swift
 │   ├── NotificationManager.swift
 ├── Core/
 │   ├── Models/
 │   ├── Utilities/
 ├── Resources/
 │   ├── Assets.xcassets
 │   ├── Info.plist
 ├── Tests/
 │   ├── Unit/
 │   └── UI/
 ├── RoundsProactive.xcconfig
 ├── README.md
 └── Setup.sh
```

---

### **Feature Implementation Notes**

#### **1. Onboarding**
- SwiftUI Carousel with three slides.
- Animation: Care Loop fade-in using `TimelineView`.
- Automatic prompt for mic + notification permissions.
- Optional skip to “Start a Round.”

#### **2. Recording**
- Uses AVAudioRecorder with continuous metering.
- Live waveform halo animation around mic.
- Save audio locally with timestamped filename.

#### **3. Reflection (AI Summary)**
- Whisper API placeholder for transcription (offline fallback).
- Send transcript → `OpenAIService` → summary returned.
- Display summary text with empathy tone; “Save” or “Discard.”

#### **4. Notifications**
- `NotificationManager` handles local pushes.
- First notification scheduled after second session.
- Message: *“It’s time for your next round.”*

#### **5. Design System**
- Color, typography, motion constants in single file.
- SF Symbols used where possible to reduce assets.
- Animations built natively — no heavy Lottie files.

#### **6. Data Handling**
- UserDefaults for temporary storage.
- CoreData stubs prepared for v2 persistent sessions.

---

### **Technical Constraints**
- GPT-4o-mini limited to short reflection calls.
- Daily usage monitored with API call counter.
- Push notifications: local only until Apple Push Certificates added.

---

### **QA + Handoff**
**QA Checklist:**
- ✅ Builds on device with no warnings  
- ✅ Audio permission & recording stable  
- ✅ Reflections generated under $0.50/session  
- ✅ UI renders under 100ms transitions  
- ✅ Notification triggers verified locally  

**Deliverables for QA Review:**
- TestFlight build (v0.9.0)
- QA log sheet
- Bug tracker via GitHub issues  

---

## 📦 MASTER PLAN SUMMARY

**App Name:** Rounds  
**Internal Project:** RoundsProactive  
**Organization:** Loud Labs Inc.  
**Team ID:** VR88MM2R4N  
**Bundle ID:** com.loudlabs.rounds  
**GitHub:** @LoudKatie / RoundsProactive  
**Apple Dev:** Organization | Kathryn Richman (Account Holder)  
**Target:** iOS 17, Swift 6.2  
**Goal:** Beautiful, calm MVP for VC demo — TestFlight by end of Month 1  

---

**Next Milestone:**  
🏁 *Deliver RoundsProactive.zip and TestFlight-ready build with placeholder content + working onboarding and recording views.*  

---

*Prepared by: AI CTO / Creative Director (acting as Jony + Sam)  
For: Loud Labs Inc. | Confidential & Proprietary*


### Appendix — Implementation Notes (Internal)
- **Bundle IDs:**  
  - Internal demo/simulator build uses: `com.loudlabs.RoundsProactive`  
  - Public App Store name “Rounds” reserved for: `com.loudlabs.rounds`  
- **Current Build Mode:** Fake AI enabled (no network calls). `SpeechManager` and `OpenAIService` are stubs; real transcription and GPT summary will be wired in Phase 2.  
- **Targets:** iOS 17+. Automatic signing with team **VR88MM2R4N**.  
