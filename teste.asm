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
Contador			db		0
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
		
LoopLeArquivo:
		mov		bx, FileHandle
		mov		ah, 3fh
		mov 	cx, 1
		lea		dx, FileBuffer
		int 	21H
		jc		ErroReadFile
		cmp		ax, 0
		jz		CloseAndFinal
		inc		TotalBytes
		cmp		Contador,0
		jz		SomaColuna1
		cmp		Contador,1
		jz 		SomaColuna2
		cmp		Contador,2
		jz 		SomaColuna3
		cmp		Contador,3
		jz 		SomaColuna4

SomaColuna1:
		inc		Contador
		add		SomaCol1, FileBuffer
		jmp		LoopLeArquivo
SomaColuna2:
		inc		Contador
		add		SomaCol2, FileBuffer
		jmp		LoopLeArquivo
SomaColuna3:
		inc		Contador
		add		SomaCol3, FileBuffer
		jmp		LoopLeArquivo
SomaColuna4:
		mov		Contador, 0
		add		SomaCol4, FileBuffer
		jmp		LoopLeArquivo

ErroOpenFile:
		lea		bx,MsgErroOpenFile
		call	printf_s
		mov		al,1
		jmp		Final

ErroReadFile:
		lea		bx, MsgErroReadFile
		call	printf_s
		mov		al, 1
		jmp		CloseAndFinal

CloseAndFinal:
		mov		bx, FileHandle
		mov		ah, 3eh
		int		21h
		jmp		Final
Final:
		lea		bx,SomaCol1
		call	printf_s
		lea 	bx, MsgCRLF
		call	printf_s
		lea		bx,SomaCol2
		call	printf_s
		lea 	bx, MsgCRLF
		call	printf_s
		lea		bx,SomaCol3
		call	printf_s
		lea 	bx, MsgCRLF
		call	printf_s
		lea		bx,SomaCol4
		call	printf_s
		lea 	bx, MsgCRLF
		call	printf_s
		.exit
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