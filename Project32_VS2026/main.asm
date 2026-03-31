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

main ENDP
END main