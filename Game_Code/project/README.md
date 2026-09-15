# MINTED — Hybrid Board Game Companion

MINTED is a Flutter companion app for the physical MINTED board game. The physical board, dice, movement, and cash remain physical; the app handles player setup, profiles, supported hybrid/app events, calculations, banking, history, and game-state tracking.

## Implemented

- Splash/loading screen
- Home screen
- Start Game / player setup for 2–6 players
- Player names, colors, College/Non-College paths, and careers
- Player profiles and player switching
- Quiz: Easy / Medium / Hard with 20 / 50 / 100 Mint rewards
- Global News events
- Startup event handling
- Banking with 10% loans and 5% simple-interest investments
- Local game save/load with `shared_preferences`
- Continue Game
- Player-specific history
- Three-year game progression and final winner calculation
- Settings: music preference, reset game, clear saved data, about
- Music ON/OFF preference placeholder that is safe when no audio asset exists
- Unit tests for core game-state and financial rules

## Run

From `Game_Code/project`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Game flow

```text
Splash
  ↓
Home
  ↓
Start Game
  ↓
Player Setup
  ↓
Player Profiles
  ↓
Quiz / Banking / News / Startup / Save
  ↓
Year 1 → Year 2 → Year 3
  ↓
Final Net Worth
  ↓
Winner
  ↓
Home
```

## Scope reminder

Physical-only gameplay is intentionally kept outside the app: board movement, dice rolling, physical cash, Chance cards, and the business spinner.
