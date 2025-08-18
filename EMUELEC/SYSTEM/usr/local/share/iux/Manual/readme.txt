Translation:
A classic bulldozer game from the 386 era, and the first PC game I played in my childhood, holds great commemorative significance for me. Therefore, I ported it here to share with everyone, as a way to revisit my childhood memories.
Function Description:
The game is adapted to the miniplus driver, with sound simulating the effect of a PC speaker, creating a nostalgic feel.
All expansion levels provided by the digger official website are included, and users can also design their own levels by referring to the instructions.
Official website: http://www.digger.org/index.html
Added dynamic switching and operations to adjust game speed and difficulty.
Operation Instructions:
A/B/X/Y: Fire shells
Select: Switch between normal/hard mode (the overall screen style will also change)
Start: Pause the game
L1/R1: Speed up/slow down the game
L2: Toggle sound effects on/off
R2: Toggle background music on/off
F1: Exit the game
Custom Level Instructions:
To add your own levels, refer to the level file definitions in the /storage/game/digger directory (actually text files that can be opened with any text editor). The first two bytes of each file are fixed as " N" (the first character is a space). The remaining content consists of 150 bytes (10 rows × 15 columns) per map, with a total of 8 maps. Including the file terminator, the total size is 1203 bytes.
Character representations of map elements:
Space: Unexcavated area
V: Vertically excavated tunnel
H: Horizontally excavated tunnel
C: Diamond location
B: Money bag location
Credits: Amai, 2022-10-31