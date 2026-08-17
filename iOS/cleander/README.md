# Cleander

Swipe through random photos, queue deletes, and clear your camera roll in small hunts.

## Features

- Photo library access (full or limited)
- Start a **hunt** from All Photos or a specific album
- Daily-size or **unlimited** mode
- Random order, skipping already-reviewed photos
- Swipe **right** keep · **left** queue delete · **down** later
- **I’m Done** confirms batched deletes
- Review queue before deleting
- Undo last decision
- Reset review history in Settings

## Open in Xcode

1. Accept the Xcode license if needed: `sudo xcodebuild -license accept`
2. Open `Cleander.xcodeproj`
3. Select your Team under Signing & Capabilities
4. Run on a physical iPhone (Photos delete works best on device)

## TestFlight

Archive in Xcode → Distribute App → TestFlight → invite friends.

## Privacy

Cleander only deletes photos you explicitly queue and confirm with **I’m Done**. Review history is stored on-device.
