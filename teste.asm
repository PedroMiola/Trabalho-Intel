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
FileNameDst			db		50	dup(0)				; Nome do arquivo a ser escrito
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
MsgSoma				db		"Soma: ", 0
MsgTotalBytes		db		"Total de Bytes: ",0
MsgSomaNumeros		db		" + 65536 :D",0 
        
SomaCol1			db		0
SomaCol2			db		0
SomaCol3			db		0
SomaCol4			db 		0
Contador			db		0
Contador2			dw		0
TotalBytes			dw 		0
;TODO		Fazer TotalBytes2 funcionar
TotalBytes2			db		0	
VetorHexa			dw		"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"
FlagErro			db		0
BufferWRWORD		db		20 dup (?)
sw_n				dw		0
sw_f				db		0
sw_m				dw		0
BufferChar			db		0
BufferPutChar		db		0

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
		call	pegaNome
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
		mov		BufferChar, dl
		mov		al, dl
		call 	putChar		
		inc		TotalBytes
		cmp		TotalBytes, 0
		je		SomaOverFlowwwwwwww
	Colunas:
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
		mov		dl, BufferChar
		add		SomaCol1, dl
		jmp		LoopLeArquivo
	Col2:
		add		Contador, 1
		mov		dl, BufferChar
		add		SomaCol2, dl
		jmp		LoopLeArquivo
	Col3:
		add		Contador, 1
		mov		dl, BufferChar
		add		SomaCol3, dl
		jmp 	LoopLeArquivo
	Col4:
		mov		Contador, 0
		mov		dl, BufferChar
		add		SomaCol4, dl
		mov		bx, FileHandleDst
		mov		dl, CR
		call    setChar
		mov		bx, FileHandleDst
		mov		dl, LF
		call    setChar
		jmp 	LoopLeArquivo

SomaOverFlowwwwwwww:
		inc		TotalBytes2
		jmp		Colunas

ErroOpenFile:
		lea		bx,MsgErroOpenFile
		call	printf_s
		mov		FlagErro,1
		jmp		Final

ErroReadFile:
		lea		bx, MsgErroReadFile
		call	printf_s
		mov		FlagErro, 1
		jmp		CloseAndFinal

ErroCreateFile:
		lea		bx, MsgErroCreateFile
		call	printf_s
		mov		FlagErro, 1
		jmp		CloseAndFinal

ErroWriteFile:
		lea 	bx, MsgErroWriteFile
		call	printf_s
		mov		FlagErro, 1
		jmp		CloseAndFinal

CloseAndFinal:
		cmp		FlagErro,1
		je		PulaEssaCoisaAqui
		mov		al, SomaCol1
		call 	putNib
		mov		al, SomaCol2
		call 	putNib
		mov		al, SomaCol3
		call 	putNib
		mov		al, SomaCol4
		call 	putNib
PulaEssaCoisaAqui:
		mov		bx, FileHandle
		call	fclose
		mov		bx, FileHandleDst
		call	fclose
		cmp		FlagErro,1
		je		Final
		lea		bx, MsgTotalBytes
		call	printf_s
		mov		ax, TotalBytes
		lea		bx,BufferWRWORD
		call	sprintf_w
		lea		bx,BufferWRWORD
		call	printf_s
		cmp		TotalBytes2, 1
		jne		PulaEsseNumero
		lea		bx, MsgSomaNumeros
		call	printf_s
PulaEsseNumero:
		lea		bx, MsgCRLF
		call	printf_s
		lea		bx,MsgSoma
		call    printf_s
		mov		al, SomaCol1
		call	printf_h
		mov		al, SomaCol2
		call	printf_h
		mov		al, SomaCol3
		call	printf_h
		mov		al, SomaCol4
		call	printf_h
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
;Fun????o Escrever um string na tela
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
;Fun????o Escrever um char na tela
;		Entra: DL -> Char a ser escrito
;--------------------------------------------------------------------
printf_c	proc	near
		mov		ah, 2
		int		21H
		ret
printf_c	endp

;
;--------------------------------------------------------------------
;Fun????o Escrever um Hexa na tela
;		Entra: AL -> Hexa a ser escrito
;--------------------------------------------------------------------
printf_h	proc	near
			mov		cl, al
			and		al, 0f0h
			and		cl, 0fh

			shr		al, 1
			shr		al, 1
			shr		al, 1
			shr		al, 1
			add		al, al
			lea		bx,VetorHexa
			and		ah, 0
			add		bx, ax
			mov		dl, [bx]
			call 	printf_c

			add		cl, cl
			lea		bx,VetorHexa
			and		ch, 0
			add		bx, cx
			mov		dl, [bx]
			call	printf_c

			mov		dl, 20h
			call	printf_c
			ret
printf_h	endp

;
;--------------------------------------------------------------------
;Fun????o: Converte um inteiro (n) para (string)
;		 sprintf(string->BX, "%d", n->AX)
;--------------------------------------------------------------------
sprintf_w	proc	near
	mov		sw_n,ax
	mov		cx,5
	mov		sw_m,10000
	mov		sw_f,0
	
sw_do:
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
	mov		sw_n,dx
	
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
	dec		cx
	cmp		cx,0
	jnz		sw_do

	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:

	mov		byte ptr[bx],0
	ret		
sprintf_w	endp

;
;--------------------------------------------------------------------
;Fun????o	Le um caractere do arquivo identificado pelo HANLDE BX
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
;Fun????o recebe um char ASCII e coloca seu valor em Hexa em arquivo
;Entra: Bx-> File Handle
;		al-> Char ASCII
;Sai:	CF-> 0 se deu certo
;--------------------------------------------------------------------
putChar	proc	near
		mov		BufferPutChar, al
		and		al, 0f0h
		

		shr		al, 1
		shr		al, 1
		shr		al, 1
		shr		al, 1
		add		al, al
		lea		bx,VetorHexa
		and		ah, 0
		add		bx, ax
		mov		dl, [bx]
		mov		bx, FileHandleDst
		call 	setChar
		jc		ErroPutChar
		
		mov		al, BufferPutChar
		and		al, 0fh
		add		al, al
		lea		bx,VetorHexa
		and		ah, 0
		add		bx, ax
		mov		dl, [bx]
		mov		bx, FileHandleDst
		call	setChar

ErroPutChar:
		ret
putChar	endp

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
; Fun????o para colora um nibble no arquivo
; Entra BX->filehandle
;		al->char
;--------------------------------------------------------------------
putNib	proc	near
	mov		BufferPutChar, al
	cmp		Contador, 3
	jne		PulaEssaParadaAqui
	mov		bx, FileHandleDst
	mov		dl, 30h
	call	setChar
	mov		al, BufferPutChar
	shr		al, 1
	shr		al, 1
	shr		al, 1
	shr		al, 1
	add		al, al
	lea		bx,VetorHexa
	and		ah, 0
	add		bx, ax
	mov		dl, [bx]
	mov		bx, FileHandleDst
	call 	setChar
	jc		ErroPutChar
	mov		bx, FileHandleDst
	mov		dl, CR
	call    setChar
	mov		bx, FileHandleDst
	mov		dl, LF
	call    setChar
	mov		Contador,0
	jmp 	ParteDois

PulaEssaParadaAqui:
	inc		Contador
	mov		bx, FileHandleDst
	mov		dl, 30h
	call	setChar
	mov		al, BufferPutChar
	shr		al, 1
	shr		al, 1
	shr		al, 1
	shr		al, 1
	add		al, al
	lea		bx,VetorHexa
	and		ah, 0
	add		bx, ax
	mov		dl, [bx]
	mov		bx, FileHandleDst
	call 	setChar
	jc		ErroPutChar

ParteDois:
	cmp		Contador, 3
	jne		PulaEssaParadaAqui1
	mov		bx, FileHandleDst
	mov		dl, 30h
	call	setChar
	mov		al, BufferPutChar
	and		al, 0fh
	add		al, al
	lea		bx,VetorHexa
	and		ah, 0
	add		bx, ax
	mov		dl, [bx]
	mov		bx, FileHandleDst
	call	setChar
	mov		bx, FileHandleDst
	mov		dl, CR
	call    setChar
	mov		bx, FileHandleDst
	mov		dl, LF
	call    setChar
	mov		Contador,0
	jmp 	ACABOUUUU

PulaEssaParadaAqui1:
	inc		Contador
	mov		bx, FileHandleDst
	mov		dl, 30h
	call	setChar
	mov		al, BufferPutChar
	and		al, 0fh
	add		al, al
	lea		bx,VetorHexa
	and		ah, 0
	add		bx, ax
	mov		dl, [bx]
	mov		bx, FileHandleDst
	call	setChar
ACABOUUUU:
	ret
putNib	endp
;
;--------------------------------------------------------------------
;Fun????o	Abre o arquivo cujo nome est?? no string apontado por DX
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
;Fun????o Cria o arquivo cujo nome est?? no string apontado por DX
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

;
;--------------------------------------------------------------------
;Fun????o pra pegar o nome do arquivo saida
;--------------------------------------------------------------------
pegaNome	proc	near
LoopPegaNome:
	lea		bx, FileName
	mov		cx,	Contador2
	add		bx, cx
	mov		al, [bx]
	cmp		al, 0
	je		FimPegaNome
	cmp		al,	2eh
	je		FimPegaNome
	lea		bx, FileNameDst
	mov		cx,	Contador2
	add		bx, cx
	mov		[bx], al
	inc		Contador2
	jmp		LoopPegaNome

FimPegaNome:
	lea		bx, FileNameDst
	mov		cx,	Contador2
	add		bx,	cx
	mov		[bx], 2eh
	inc		bx
	mov		[bx], 52h
	inc		bx
	mov		[bx], 65h
	inc		bx
	mov		[bx], 73h
	ret
pegaNome	endp
;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------