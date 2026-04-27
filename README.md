# Skyfall-Charachters-8086-Assembly
Retro-style falling character game written in x86 Assembly language for Emu8086 emulator.

🎮 Skyfall CharactersSkyfall Characters is a retro-style, fast-paced arcade game developed entirely in Intel 8086 Assembly. The project demonstrates low-level hardware interactions, real-time interrupt handling, and efficient memory management within a 16-bit environment.



📖 OverviewIn this game, characters drop from the top of the screen at varying speeds. The player must "catch" them by pressing the corresponding key on the keyboard before they reach the bottom. It’s a test of both typing speed and reflexes, built from the ground up using BIOS and DOS interrupts.



✨ Key Features🚦 Dynamic Difficulty SystemThe game features a custom-built speed scaling system with three distinct levels:

🟢 EASY: 2x speed – Perfect for warming up.

🟡 MEDIUM: 3x speed – Requires steady focus.

🔴 HARD: 4x speed – Minimal delay (delay: 1), testing the limits of human reflexes.



🎨 Visual & UI DesignCustom About Page: A personalized screen featuring developer credentials and project info.Color-Coded Menus: Traffic-light inspired difficulty selection (Green-Yellow-Red).Optimized Rendering: Uses a specialized "Print-and-Vanish" algorithm to ensure smooth movement without leaving visual artifacts (trailing lines) on the screen.



⚙️ Technical DepthHardware Interrupts: Utilizes INT 10h for video services and INT 16h for non-blocking keyboard input.Randomization: Generates random columns and character types using the system clock (INT 1ah) as a seed.Timing: Real-time delay loops managed via system tick counts to ensure consistent gameplay across different emulators.



🛠 Technical SpecificationsComponentDetailLanguagex86 Assembly (16-bit)ArchitectureIntel 8086Emulatoremu8086 (Recommended)Video Mode80x25 Text Mode (Mode 03h).



🚀 How to RunDownload and install the emu8086 emulator.Clone this repository or download the game.asm file.Open the file in emu8086.Click Compile and then Emulate.Press Run to launch the game.Controls: Use 1, 2, and 3 to navigate menus; type the falling letters to play; press ESC to return to the main menu.



👤 Developer: Fidan Imamaliyeva Computer Engineering Student, Year 2Istanbul, 2026

