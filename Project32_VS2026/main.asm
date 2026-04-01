INCLUDE irvine32.inc

.data
; cards for player and dealer
; Note: usually in blackjack, the player
; and the dealer will not have more than 5 cards each
pCardArray DWORD 0,0,0,0,0
dCardArray DWORD 0,0,0,0,0
cardArray DWORD 13 DUP (1,2,3,4,5,6,7,8,9,10,10,10,10) ; card values

; player and dealer scores
playerCount DWORD 0
playerScore DWORD 0
dealerCount DWORD 0
dealerScore DWORD 0

; string messages to help with output and gameplay
playerTurnMessage BYTE "Your turn: ",0 ; player turn
playerActionMSG BYTE "Hit or stand (h/s)?: ",0 ; player can hit or stand
dealerTurnMessage BYTE "Dealer's turn:",0 ; dealers turn
winMessage BYTE "You win!",0 ; player wins
loseMessage BYTE "Dealer wins :(",0 ; player loses, dealer wins
pushMessage BYTE "Push (draw)",0 ; push (draw)

.code

Draw PROC
	; get a random card procedure (1-13)
	mov eax,13 ; 13 possible card values
	call RandomRange ; irvine32 procedure, puts a random integer into eax from range 0 to eax-1
	inc eax ; 0 isnt a possible value, so add 1 to eax so we have values 1-13
	mov ecx,eax ; move result to ecx use in determining value (if ace or face card)
	ret
Draw ENDP

Value PROC
	; get card value, input is placed in ecx (moved there in Draw proc)
	mov eax,ecx ; get input from ecx from Draw proc
	cmp eax,1 ; if ace card jump to ace label
	je ace
	cmp eax,11 ; if not a face card
	jb standard
	cmp eax,12 ; jump to faceCard label if greater or equal to 12
	jge faceCard
standard: ; regular card
	mov eax,ecx ; move result to eax
	ret ; return eax
faceCard: ; face card
	mov eax,10 ; move 10 (face card value) to eax
	ret ; return eax
ace: ; ace
	mov eax,11 ; move 11 (will update ace logic later) to eax
	ret ; return
Value ENDP

DrawP PROC
	; Player drawing cards procedure
	call Draw ; get random card value
	push eax ; push eax to save state
	mov ecx,eax
	call Value ; get card value
	add playerScore,eax ; add value to players score
	pop eax ; pop eax to retrieve previous values
	lea ebx, pCardArray ; get address of array into ebx
	mov eax, playerCount ; move count into eax
	shl eax, 2 ; multiply by 4 since array is DWORD
	add ebx, eax ; add value to ebx
	mov [ebx], eax ; move eax into ebx
	inc playerCount ; increase the player count of cards
	ret ; return
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
	call DrawP ; get first 2 player cards
	call DrawP
	call DrawD ; get first 2 dealer cards
	call DrawD
	call PTurn ; player turn
	call DTurn ; dealer turn
	call ShowDCards ; show dealer cards using procedure
	call Score ; determine if player or dealer won
main ENDP
END main