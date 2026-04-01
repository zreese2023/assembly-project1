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
	; NOTE: RandomRange was not taught in class, so i consulted the internet/AI for the documentation
	; on how to get random numbers in MASM with the irvine library.
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
	mov ebx,playerCount
	mov pCardArray[ebx*4],eax
	inc playerCount ; increase the player count of cards
	ret ; return
DrawP ENDP

DrawD PROC
	; Draw dealer cards procedure, same logic as DrawP proc
	call Draw ; get random number
	push eax ; save eax
	mov ecx,eax ; move ecx to eax for Value proc
	call Value ; get card value
	add dealerScore,eax ; add value to dealers score
	pop eax ; retrieve eax
	mov ebx,dealerCount
	mov dCardArray[ebx*4],eax
	inc dealerCount ; increase count of dealer cards
	ret ; return
DrawD ENDP

ShowPCards PROC
	; show player cards procedure
	mov edx, OFFSET playerTurnMessage ; load players turn message address to edx for WriteString
	call WriteString ; print players turn message
	call Crlf ; new line
	mov ecx,playerCount ; load number of player cards to ecx for loop
	mov esi,0
L1: ; loop to print players cards
	mov eax,pCardArray[esi*4] ; get player card into eax
	call WriteDec ; print playerc ard
	mov al,' ' ; print a space
	call WriteChar
	inc esi ; move to next element in array
	loop L1 ; loop

	call Crlf ; new line
	mov eax,playerScore ; print the current total
	call WriteDec
	ret ; return
ShowPCards ENDP

ShowDCards PROC
	; show dealer cards procedure
	mov edx, OFFSET dealerTurnMessage ; address of dealer turn msg into edx
	call WriteString
	call Crlf ; new line
	mov ecx,dealerCount ; load player cards to ecx
	mov esi,0 ; track index of array
L1: ; loop to print dealer cards
	mov eax,dCardArray[esi*4] ; dealer card array 
	call WriteDec ; print card
	mov al,' ' ; print a space
	call WriteChar
	inc esi ; move to next index
	loop L1

	call Crlf ; new line
	mov eax,dealerScore
	call WriteDec ; print dealer score
	ret
ShowDCards ENDP

PTurn PROC
	; main procedure for player turn
L1:
	call ShowPCards ; print player cards
	call Crlf ; new line
	call ShowDCards ; show dealers cards
	call Crlf
	mov edx, OFFSET playerActionMSG ; prompt player to hit or stand
	call WriteString ; print
	call ReadChar ; use read char to block program until input received
	cmp al,'h' ; hit
	je hit
	cmp al,'H'
	je hit
	cmp al,'s' ; stand
	je stand
	cmp al,'S'
	je stand
	jmp L1
hit: ; if player hits
	call DrawP ; player draws card
	cmp playerScore,21 ; if greater than 21 player loses
	jg bust
	jmp L1
stand: ; proc ends if player stands, no more actions
	ret
bust: ; if player gets more than 21
	mov edx,OFFSET loseMessage
	call WriteString ; print loss message
	call Crlf ; new line
	call ReadKey
	exit ; exit program
PTurn ENDP

DTurn PROC
; procedure for dealer turn
; dealer will stand on soft 17
L1: ; main loop
	cmp dealerScore,17 ; stands on 17
	jge stand
	call DrawD ; if less than 17 dealer hits
	jmp L1 ; loop
stand:
	cmp dealerScore,21 ; if dealer over 21, player wins
	jg bust
	ret
bust: ; dealer over 21
	mov edx,OFFSET winMessage ; print win message
	call WriteString
	call Crlf
	call ReadKey
	exit
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
	INVOKE ExitProcess,0
main ENDP
END main