.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode : DWORD

INCLUDE irvine32.inc

.data
.code

DrawP PROC
; Player drawing cards procedure
DrawP ENDP

DrawD PROC
; Draw dealer cards procedure
DrawD ENDP

ShowPCards PROC
; show player cards procedure
ShowPCards ENDP

ShowDCards PROC
; show dealer cards procedure
ShowDCards ENDP

PTurn PROC
; main procedure for player turn
PTurn ENDP

DTurn PROC
; procedure for dealer turn
; dealer will stand on soft 17
; for this case
DTurn ENDP

Score PROC
; determine winner: player or dealer
Score ENDP

main PROC
	call Randomize ; irvine32 procedure to generate a new seed for a random number generator
	call DrawPCards ; get first 2 player cards
	call DrawPCards
	call DrawDCards ; get first 2 dealer cards
	call DrawDCards
	call PTurn ; player turn
	call DTurn ; dealer turn
	call ShowDCards ; show dealer cards using procedure
	call Score ; determine if player or dealer won
main ENDP
END main