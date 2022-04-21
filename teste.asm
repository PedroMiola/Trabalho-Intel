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

FileName			db		256 dup (?)				; Nome do arquivo a ser lido
FileNameDst			db		"resultado .txt", 0		; Nome do arquivo a ser escrito
FileBuffer			db		0 						; Buffer de leitura do arquivo
FileHandle			dw		0						; Handler do arquivo de leitura
FileHandleDst		dw		0						; Handler do arquivo de saida
FileNameBuffer		db		150 dup (?)

MsgPedeArquivo		db		"Nome do arquivo: ", 0
MsgErroOpenFile		db		"Erro na abertura do arquivo.", CR, LF, 0
MsgErroReadFile		db		"Erro na leitura do arquivo.", CR, LF, 0
MsgErroCreateFile	db		"Erro na criacao do arquivo", CR, LF, 0
MsgErroWriteFile	db		"Erro na escrita do arquivo", CR, LF, 0
MsgCRLF				db		CR, LF, 0
        
SomaCol1			db		0
SomaCol2			db		0
SomaCol3			db		0
SomaCol4			db 		0
Contador			db		0
TotalBytes			dw 		0
;TODO		Fazer TotalBytes2 funcionar
TotalBytes2			db		0	
VetorHexa			dw		"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"

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
		lea		dx,FileName
		call 	fopen
		jc		ErroOpenFile		;If (CF == 1), erro ao abrir o arquivo	
		mov		FileHandle,ax		; Salva handle do arquivo
		;	Cria o arquivo de saida
		lea		dx, FileNameDst
		call	fcreate
		jc		ErroCreateFile
		mov		FileHandleDst, ax
		
LoopLeArquivo:
		mov		bx, FileHandle
		call	getChar
		jc		ErroReadFile
		cmp		ax, 0
		jz		CloseAndFinal
		cmp		Contador, 0
		je		Col1
		cmp		Contador, 1
		je		Col2
		cmp		Contador, 2
		je		Col3
		cmp		Contador, 3
		je 		Col4
	Col1:
		add		Contador, 1
		add		SomaCol1, dl
		jmp		LoopLeArquivo
	Col2:
		add		Contador, 1
		add		SomaCol2, dl
		jmp		LoopLeArquivo
	Col3:
		add		Contador, 1
		add		SomaCol3, dl
		jmp 	LoopLeArquivo
	Col4:
		mov		Contador, 0
		add		SomaCol4, dl
		jmp 	LoopLeArquivo

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

ErroCreateFile:
		lea		bx, MsgErroCreateFile
		call	printf_s
		mov		al, 1
		jmp		CloseAndFinal

ErroWriteFile:
		lea 	bx, MsgErroWriteFile
		call	printf_s
		mov		al, 1
		jmp		CloseAndFinal

CloseAndFinal:
		mov		bx, FileHandle
		call	fclose
		mov		bx, FileHandleDst
		call	fclose
		jmp		Final
Final:
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

;
;--------------------------------------------------------------------
;Função Escrever um char na tela
;		Entra: DL -> Char a ser escrito
;--------------------------------------------------------------------
printf_c	proc	near
		mov		ah, 2
		int		21H
		ret
printf_c	endp

;
;--------------------------------------------------------------------
;Função Escrever um Hexa na tela
;		Entra: BL -> Hexa a ser escrito
;--------------------------------------------------------------------
printf_h	proc	near
			mov		al, bl
			and		al, 0f0h
			and		bl, 0fh
			add		al, al
			lea		cx,VetorHexa
			add		cx, al
			mov		dl, [cx]
			call printf_c
			add		bl, bl
			lea		cx,VetorHexa
			add		cx, bl
			mov		dl, [cx]
			call	printf_c
printf_h	endp

;
;--------------------------------------------------------------------
;Função	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp

;
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
;--------------------------------------------------------------------
;Função	Abre o arquivo cujo nome está no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   AX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	ret
fopen	endp

;
;--------------------------------------------------------------------
;Função Cria o arquivo cujo nome está no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   AX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	ret
fcreate	endp

;
;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp


;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------