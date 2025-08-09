# Game of Life - Assembly Implementation

> **Suggested GitHub Repository Name**: `game-of-life-assembly-8086`

A classic Conway's Game of Life implementation written in x86 Assembly language for the 8086 processor.

## 🎮 About

This project is a final assignment for the Microprocessors course, implementing Conway's Game of Life as a graphical application with mouse interaction, file management, and scoring system.

## 👥 Authors

- **Tiago Monteiro** (N63368)
- **Lucas Pereira** (N62683) 
- **Isaac Furtado** (N62884)

## 🎯 Features

- **Interactive Game Board**: 160x88 grid (14,080 cells) with mouse-based cell activation/deactivation
- **Real-time Simulation**: Automatic generation progression with configurable timing
- **File Management**: Save and load game states with `.gam` files
- **Scoring System**: Track generations and cell counts
- **Leaderboard**: Top 5 scores with player names, dates, and times
- **Logging System**: Comprehensive game history logging
- **User-friendly Interface**: Graphical menu system with mouse navigation

## 🎲 Game Rules

Conway's Game of Life follows these simple rules:

1. **Birth**: A dead cell with exactly 3 live neighbors becomes alive
2. **Survival**: A live cell with 2 or 3 live neighbors stays alive
3. **Death**: A live cell with fewer than 2 or more than 3 neighbors dies

## 🏗️ Project Structure

```
P6-62884-62683-63368/
├── trabFinal.asm          # Main assembly source code
├── trabFinal.exe          # Compiled executable
├── 2046SIGM.GAM          # Sample saved game file
├── log.txt               # Game history log
├── top5.txt              # Top 5 scores leaderboard
└── README.md             # This file
```

## 🚀 How to Run

### Prerequisites

- DOSBox or similar DOS emulator
- MASM (Microsoft Macro Assembler) or compatible assembler
- 8086-compatible processor or emulator

### Compilation

1. Ensure all files are in the `C:\` directory
2. Compile the assembly code:
   ```bash
   masm trabFinal.asm
   link trabFinal.obj
   ```

### Execution

1. Run the compiled executable:
   ```bash
   trabFinal.exe
   ```

## 🎮 Game Controls

### Main Menu
- **JOGAR**: Start a new game
- **CARREGAR**: Load a saved game
- **GUARDAR**: Save current game
- **TOP 5**: View leaderboard
- **CREDITOS**: View author information
- **SAIR**: Exit game

### In-Game Controls
- **Mouse Click**: Activate/deactivate cells on the grid
- **Iniciar Button**: Start simulation
- **Sair Button**: Exit to main menu

## 📁 File Formats

### .GAM Files
Game save files contain:
- Generation count (3 characters)
- Cell count (4 characters)
- Player name (7 characters)
- Grid state (14,080 bytes)

### log.txt
Game history in format: `YYYYMMDD:HHMMSS:PLAYER:GEN:CELLS`

### top5.txt
Leaderboard with columns: Generation, Cells, Player, Date, Time

## 🔧 Technical Details

- **Resolution**: 320x200 graphics mode (13h)
- **Grid Size**: 160x88 cells (14,080 total)
- **Memory**: Uses two 14,080-byte arrays for alternating generations
- **Mouse Support**: Full mouse integration for cell interaction
- **File I/O**: Direct file system access for save/load functionality

## 🎯 Game Mechanics

1. **Cell Interaction**: Click on grid cells to toggle their state
2. **Simulation**: Automatic progression through generations
3. **Scoring**: Tracks current generation and live cell count
4. **Persistence**: Save/load functionality for game states
5. **Statistics**: Automatic logging and leaderboard updates

## 📊 Scoring System

- **Generations**: Number of completed simulation cycles
- **Cells**: Current number of live cells on the board
- **Leaderboard**: Top 5 scores ranked by generation count

## 🐛 Known Issues

- Files must be located in `C:\` directory
- Requires DOS environment for execution
- Limited to 320x200 resolution

## 📝 Version History

- **v1.15**: Current version with full feature set
- Includes mouse interaction, file management, and scoring

## 🤝 Contributing

This is an academic project for the Microprocessors course. For educational purposes only.

## 📄 License

This project is created for educational purposes as part of a university course assignment.

---

**Note**: This implementation requires a DOS environment or DOSBox emulator to run properly.
