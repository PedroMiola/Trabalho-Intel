;               Trabalho Intel
;
;Aluno:         Pedro Poli Miola   334610
;Professor:     Azambuja

        .model small
        .stack

CR					equ		0dh
LF					equ		0ah
FileHandleSaida		equ		".res"

        .data

FileName			db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer			db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle			dw		0				; Handler do arquivo
FileNameBuffer		db		150 dup (?)

MsgPedeArquivo		db		"Nome do arquivo: ", 0
MsgErroOpenFile		db		"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db		"Erro na leitura do arquivo.", CR, LF, 0
MsgCRLF				db		CR, LF, 0
        
SomaCol1			db		0
SomaCol2			db		0
SomaCol3			db		0
SomaCol4			db 		0
TotalBytes			dd 		0

        .code
        .startup


		mov		ax,ds
		mov		es,ax

		;	Pega o nome do arquivo
		call GetFileName

		;	Quebra a linha
		lea		bx,MsgCRLF
		call	printf_s

		;	Abre o arquivo
		mov		al,0
		lea		dx,FileName
		mov		ah,3dh
		int		21h
		jc		ErroOpenFile	;If (CF == 1), erro ao abrir o arquivo	

		mov		FileHandle,ax		; Salva handle do arquivo
		lea		bx,MsgCRLF
		call	printf_s		
		lea		bx,FileHandle
		call	printf_s
Final:
		.exit

ErroOpenFile:
		lea		bx,MsgErroOpenFile
		call	printf_s
		mov		al,1
		jmp		Final
;
;--------------------------------------------------------------------
;Funcao: Le o nome do arquivo do teclado
;--------------------------------------------------------------------
GetFileName	proc	near
		lea		bx,MsgPedeArquivo			; Coloca mensagem que pede o nome do arquivo
		call	printf_s

		mov		ah,0ah						; Le uma linha do teclado
		lea		dx,FileNameBuffer
		mov		byte ptr FileNameBuffer,100
		int		21h

		lea		si,FileNameBuffer+2			; Copia do buffer de teclado para o FileName
		lea		di,FileName
		mov		cl,FileNameBuffer+1
		mov		ch,0
		mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
		mov		es,ax
		rep 	movsb

		mov		byte ptr es:[di],0			; Coloca marca de fim de string
		ret
GetFileName	endp

;
;--------------------------------------------------------------------
;Função Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp


;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------