
;****************** Game of life*******************
;*                                                *
;*      Trabalho final de Microprocessadores      *
;*                                                *
;*          Por: Tiago Monteiro 63368             *
;*               Lucas Pereira  62683             *
;*               Isaac Furtado  62884             *
;*                                                *
;*                                    Ver. 1.15   *                                               
;**************************************************


data segment
    numeroGeracoesStr db "000", 0    ;Por algum motivo nao funcionam quando offset e demasiado grande por isso ficam aqui
    numeroCelulasStr db "0000", 0
;********************** Menu ********************** 
    linhaMenu db 17 dup(20h), 0
    jogarStrMenu    db "      JOGAR      ", 0
    carregarStrMenu db "     CARREGAR    ", 0
    guardarStrMenu  db "     GUARDAR     ", 0
    top5StrMenu     db "       TOP 5     ", 0  
    creditosStrMenu db "     CREDITOS    ", 0
    sairStrMenu     db "       SAIR      ", 0 
    strMenuLength equ 18
    colunaInicioMenu equ 11
    linhaInicioMenu equ 1
;********************** Jogo ********************** 
    pedeNomeStr db "Introduza o seu nome:", 0
    nomeJogador db "       ", 0 
    nomeJogadorLength equ 7
    linhaJogo db 40 dup(20h), 0
    geracaoStrJogo db 2 dup(20h),"Geracao:000 ","Celulas:0000 ","Iniciar ","Sair", 0
    strEcraLength equ 40
    celulas db 14080 dup(0)   ;vetor com 14080 posicoes = numero de celulas
    celulas1 db 14080 dup(0)  ;geracao par - celulas e a atual, geracao impar - celulas1 e a atual
    numeroCelulas dw 0
    colunaGeracao equ 10
    linhaGeracao equ 1
    strGeracaoLenght equ 4
    strCelulasLenght equ 5
    colunaCelulas equ 22
;************** maniuplacao de ficheiros ********** 
    pedeNomeFileStr db "Introduza o nome do ficheiro:", 0
    top5file db "c:\top5.txt", 0 
    top5info db "GERACAOCELULAS JOGADOR DATA     HORA", 0dh, 0ah, 0
    top5ex db   "000    0000            00/00/00 00:00:00", 0dh, 0ah, 0 
    top5ex1 db   "000    0000            00/00/00 00:00:00", 0dh, 0ah, 0
    logfile db "c:\log.txt", 0
    gamefile db "c:\",8 dup(20h),".gam", 0  
                              
;************** informacoes do ficheiros txt ********
    enterStr db 0dh, 0ah
    ano20XX db "20"
    year  db 0, 0
    month db 0, 0
    day   db 0, 0
    
    hour db 0, 0      
    minutes db 0, 0 
    seconds db 0, 0 
    
    infLogStr db 34 dup(20h)      ;20221103:145123:JOGADOR:122:0156
    infLogStrLength equ 34

;************ Variaveis de Creditos ************    
    tiago db "Tiago Monteiro", 0 
    numTiago db "N63368", 0
    
    Lucas db "Lucas Pereira ", 0 
    numlucas db "N62683", 0  
    
    Isaac db "Isaac Furtado ", 0 
    numIsaac db "N62884", 0
    strCreditosLength equ 15
    strCreditosNLength equ 7
    colunaInicioCreditos equ 1
    linhaInicioCreditos equ 1    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax


;*********Carregar ou criar ficheiros top5.txt e log.txt*********
;Como o top5 se atualiza a base do log.txt, ambos tem que
;ser inicializados no inicio do programa
                     
                     
;carregar log.txt
    mov dx, offset logfile
    mov al, 2 ; ler/escrever
    call fOpen  
    jc createLogFile
    mov bx, ax ; move o handler do ficheiro log.txt para bx
    jmp logClose 
createLogFile:  
    xor cx, cx ;cx=0 - tipo de ficheiro a criar
    call fCreate
    mov bx, ax   
logClose:
    call fClose
    
;carregar top5file.txt
    mov dx, offset top5file
    mov al, 2 ; ler/escrever
    call fOpen  
    jc createTop5File
    mov bx, ax ; move o handler do ficheiro top5.txt para bx
    jmp top5Close 
createTop5File:  
    xor cx, cx ;cx=0 - tipo de ficheiro a criar
    call fCreate
    mov bx, ax
    mov dx, offset top5info
    mov cx, 38
    call fWrite
    mov dx, offset top5ex
    mov cx, 42
    call fWrite
    call fWrite
    call fWrite
    call fWrite
    call fWrite        
top5Close:
    call fClose    
    
;****************************************************************    
    
menu: 
    mov si, offset celulas      
    mov di, offset celulas1

   
    mov al, 13h ;modo de video: grafico 320x200
    call setVideoMode
    call apresentaMenu 
    call hideBlinkingCursor
    call escolheOpcaoMenu
    cmp cx, 6
    je sairPrograma
    jmp menu
    
sairPrograma:  
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    

;********************* funcoes do programa ***********************************

;********************************************************************
; escolheOpcaoMenu -  escolhe a opcao do menu
; input - nenhum       
; output - cx= 1-OpcaoJogar 2-OpcaoCarregar 3-OpcaoGuardar
;              4-OpcaoTop5 5-OpcaoCreditos 6-OpcaoSair
;********************************************************************
escolheOpcaoMenu proc
    call initMouse
    call showMouse

;Checking if the mouse is over the buttons.
cicloMouse:
;Checking if the mouse is in the correct position to start a certan procedure.
    call getMousePosGraphic
    cmp bx, 1            ;ve se botao da esquerda foi premido ou nao. Caso nao seja, volta ao cicloMouse para em getMousePos se voltar a ver se o botao foi premido ou nao
    jne cicloMouse       ;se o botao da esquerda foi premido. A zero flag esta ativa. Este jump nao e feito e o codigo continua
    cmp cx, 58h           ;limite lateral esquerdo
    jb cicloMouse        ;volta para ciclouMouse se a posicao clicada for inferior a 58h
    cmp cx, 0e7h              ;limite lateral direito
    ja cicloMouse        ;volta para ciclouMouse se a posicao clicada for superior a 0e7h
    cmp dx, 7h           ;limite superior do botao
    jb cicloMouse        ;volta para ciclouMouse se a posicao clicada for inferior a 8h
    cmp dx, 1fh          ;limite inferior do  botao
    jbe opcaoJogar       ;como todos os lados a ja foram verificados, se a posicao clicada for superior a 1fh, a rotina opcaoJogar e invocada
                         
    ;o processo sera o mesmo para os outros botoes
    
    cmp dx, 28h
    jb cicloMouse
    cmp dx, 3fh
    jbe opcaoCarregar
    
    
    cmp dx, 48h
    jb cicloMouse
    cmp dx, 5fh
    jbe opcaoGuardar
    
    
    cmp dx, 68h
    jb cicloMouse
    cmp dx, 7fh
    jbe opcaoTop5
    
    
    cmp dx, 88h
    jb cicloMouse
    cmp dx, 9fh
    jbe opcaoCreditos
    
    
    cmp dx, 0a8h
    jb cicloMouse
    cmp dx, 0bfh
    jbe opcaoSair
    
    
opcaoJogar:  
    ;mov cx, 1 
    call apagaDados
    call comecaJogo
    jmp terminaCiclo
   
opcaoCarregar:  
    ;mov cx, 2
    call carregaJogo 
    cmp bx, 0
    je semficheiro1
    call comecaJogo
    semficheiro1:
    jmp terminaCiclo  
    
opcaoGuardar:  
    ;mov cx, 3
    call  guardaJogo
    jmp terminaCiclo
    
opcaoTop5:  
    ;mov cx, 4  
    call apresentaTop5
    jmp terminaCiclo
    
opcaoCreditos:  
    ;mov cx, 5
    call apresentaCreditos
    jmp terminaCiclo
    
opcaoSair:  
    mov cx, 6
    push cx 
    call saiJogo  
    pop cx
    jmp terminaCiclo 

     
terminaCiclo:    
    
    ret
escolheOpcaoMenu endp 


;**************************************************************************
; saiJogo - Altera o conteudo do ficheiro top5 se necessario
;         - Adiciona linha ao ficheiro log com os dados do jogo no formato:
;         - 20221103:145123:NOME DO JOGADOR:122:0156
;         - data, hora, Nome do jogador, geracao e numero de celulas
;************************************************************************** 
saiJogo proc  
    call getDate 
    call getTime            ;infLogStr db 40 dup(20h)        ;20221103:145123:NOME DO JOGADOR:122:0156
                            ;infLogStrLength equ 40
                            
                            
    mov dx, offset logfile
    mov al, 1
    mov ah, 3dh
    int 21h
    mov bx, ax   
                                                      
                                                       
                                                      
    call atualizaInfLogStr 
    call atualizaLogFile
                                                                                      
                                                        
    call fclose
    
    call atualizaTop5
    
    mov cx, [bp+4+4] ; seria handler top5 = 06, cx=06 fiz isto so para verificar se ficava mesmo com o handler do top5

    
    ret
    
saiJogo endp 

;*********************************************************************************************************
; atualizaLogFile - atualiza o ficheiro top5.txt de acordo com o ultimo jogo jogado:
; input -
; output - ficheiro top5.txt atualizado se necessario
;********************************************************************************************************* 

atualizaTop5 proc
    
    mov dx, offset top5file
    mov al, 2
    
    call  fOpen
    mov bx, ax 
     
    mov si, offset InfLogStr 
    mov di, offset top5ex
    add si, 24
    
    cld                                        ;escrever a linha top5 no top5ex
    mov cx, 3                         
    rep movsb
    
    inc si
    add di, 4
    mov cx, 4
    rep movsb
    
    mov si, offset InfLogStr
    add si, 16
    add di, 4 
    
    mov cx, 7
    rep movsb
    
    inc di
    sub si, 21
    
    mov cx, 2
    rep movsb
    
    mov b.[di], "/" 
    inc di
    
    mov cx, 2
    rep movsb
    
    mov b.[di], "/"
    inc di
    
    mov cx, 2
    rep movsb
    
    inc si
    inc di
    
    mov cx, 2
    rep movsb
    
    mov b.[di], ":" 
    inc di
    
    mov cx, 2
    rep movsb
    
    mov b.[di], ":"
    inc di
    
    mov cx, 2
    rep movsb
                ;offset 213 a partir do inicio do ficheiro
    mov dx, 213
    mov al, 0       
    mov ah, 42h       
    int 21h
    
    mov dx, offset numeroCelulasStr
    mov cx, 4
    call fRead
    
    mov di, offset numeroCelulasStr 
    xor cx, cx
    mov si, offset InfLogStr
    add si, 28
    
    quinto:
    mov al, b.[si]
    cmp b.[di], al
    ja loser 
    cmp b.[di], al
    jb quarto
    inc di
    inc si
    inc cx
    cmp cx, 4
    je loser
    jmp quinto 
    
    quarto:
    sub si, cx
    xor cx, cx            
    mov dx, 171
    mov al, 0       
    mov ah, 42h       
    int 21h
    
    mov dx, offset numeroCelulasStr
    mov cx, 4
    call fRead
    
    mov di, offset numeroCelulasStr 
    xor cx, cx
    quarto1:
    mov al, b.[si]
    cmp b.[di], al
    ja quintolugar  
    cmp b.[di], al
    jb terceiro
    inc di
    inc si
    inc cx
    cmp cx, 4
    je quintolugar
    jmp quarto1
    
    terceiro:
    sub si, cx
    xor cx, cx            
    mov dx, 129
    mov al, 0       
    mov ah, 42h       
    int 21h
    
    mov dx, offset numeroCelulasStr
    mov cx, 4
    call fRead
    
    mov di, offset numeroCelulasStr 
    xor cx, cx
    terceiro1:
    mov al, b.[si]
    cmp b.[di], al
    ja quartolugar  
    cmp b.[di], al
    jb segundo
    inc di
    inc si
    inc cx
    cmp cx, 4
    je quartolugar
    jmp terceiro1
    
    segundo:
    sub si, cx
    xor cx, cx            
    mov dx, 87
    mov al, 0       
    mov ah, 42h       
    int 21h
    
    mov dx, offset numeroCelulasStr
    mov cx, 4
    call fRead
    
    mov di, offset numeroCelulasStr 
    xor cx, cx
    segundo1:
    mov al, b.[si]
    cmp b.[di], al
    ja terceirolugar  
    cmp b.[di], al
    jb primeiro
    inc di
    inc si
    inc cx
    cmp cx, 4
    je terceirolugar
    jmp segundo1
    
    primeiro:
    sub si, cx
    xor cx, cx            
    mov dx, 45
    mov al, 0       
    mov ah, 42h       
    int 21h
    
    mov dx, offset numeroCelulasStr
    mov cx, 4
    call fRead
    
    mov di, offset numeroCelulasStr 
    xor cx, cx
    primeiro1:
    mov al, b.[si]
    cmp b.[di], al
    ja segundolugar  
    cmp b.[di], al
    jb primeirolugar
    inc di
    inc si
    inc cx
    cmp cx, 4
    je segundolugar
    jmp primeiro1
    
    primeirolugar:
    xor cx, cx            
    mov dx, 38
    push dx
    mov al, 0       
    mov ah, 42h       
    int 21h
    pop dx 
    mov ax, dx
          
    mov cx, 4      
    
    jmp top5comp
    
    segundolugar: 
    xor cx, cx            
    mov dx, 80
    push dx
    mov al, 0       
    mov ah, 42h       
    int 21h
    pop dx 
    mov ax, dx
    
    mov cx, 3
    
    jmp top5comp
    
    terceirolugar:
    xor cx, cx            
    mov dx, 122
    push dx
    mov al, 0       
    mov ah, 42h       
    int 21h 
    pop dx
    mov ax, dx
    
    mov cx, 2
        
    jmp top5comp
                                            
    quartolugar:
    xor cx, cx            
    mov dx, 164
    push dx
    mov al, 0       
    mov ah, 42h       
    int 21h 
    pop dx
    mov ax, dx

    mov cx, 1 
     
    jmp top5comp                            
     
    quintolugar:
    xor cx, cx            
    mov dx, 206
    push dx
    mov al, 0       
    mov ah, 42h       
    int 21h
    pop dx
    mov ax, dx
    
    xor cx, cx
    
    top5comp:
    push cx  
    mov dx, offset top5ex1
    mov cx, 40
    call fRead
    
    push ax
    xor cx, cx            
    mov dx, ax 
    mov al, 0       
    mov ah, 42h       
    int 21h 
    pop ax
    
    mov dx, offset top5ex
    mov cx, 40
    call fWrite 
    
    pop cx
    cmp cx, 0
    je loser
    dec cx
    add ax, 42
    push cx
    push ax
    xor cx, cx            
    mov dx, ax 
    mov al, 0       
    mov ah, 42h       
    int 21h 
    pop ax
    
    mov dx, offset top5ex
    mov cx, 40
    call fRead
    
    push ax
    xor cx, cx            
    mov dx, ax 
    mov al, 0       
    mov ah, 42h       
    int 21h 
    pop ax
    
    mov dx, offset top5ex1
    mov cx, 40
    call fWrite
   
    
    pop cx
    cmp cx, 0
    je loser
    dec cx
    add ax, 42
    push cx
    push ax
    xor cx, cx            
    mov dx, ax 
    mov al, 0       
    mov ah, 42h       
    int 21h
    pop ax 
    pop cx
    jmp top5comp
    
    
    loser:
    
    call fClose
    
    ret
    
atualizaTop5 endp
;*********************************************************************************************************
; atualizaLogFile - atualiza o ficheiro log.txt com a informacao do jogo mais recente no seguinte formato:
;                   - 20221103:145123:NOME DO JOGADOR:122:0156
;                   - data, hora, Nome do jogador, geracao e numero de celulas
;                   - ter em atencao que nao ha divisao entre as atualizacoes pelo que o comprimento de cada
;                   - atualizacao e de 40 caracteres
;
;input - bx=handler do ficheiro
;********************************************************************************************************* 
atualizaLogFile proc 
    
    mov ah, 42h  ;  SEEK - set current file position.
    mov al, 2 ;origem do deslocamento end of file
    xor cx, cx
    xor dx,dx
    ;cx:dx= offset da origem ate a nova posicao do ficheiro, isto  para atualizar o ficheiro log.txt
    
    int 21h 
                                                                   
                                             
    mov dx, offset infLogStr
    mov cx, infLogStrLength 
                                              

                                                                                                                                
    call fWrite  
       
       
    ret
    
atualizaLogFile endp 

;**********************************************************************************************
; atualizaInfLogStr - atualiza a string infLogStr com a informacao do jogo no seguinte formato:
;                   - 20221103:145123:JOGADOR:122:0156
;                   - data, hora, Nome do jogador, geracao e numero de celulas
;********************************************************************************************** 
atualizaInfLogStr proc 
    
    cld ;di vai incrementando
    mov si, offset ano20XX ;onde vai comecar a copia
    mov di, offset infLogStr  ;para onde se vai copiar
    mov cx, ((offset day)+2) - offset ano20XX ; +2 para obter o numero total de caracteres a escrever
    rep movsb 
    
    mov b.[di], ':' 
    inc di
    
    mov si, offset hour
    mov cx, ((offset seconds)+2) - offset hour
    rep movsb
    
    mov b.[di], ':' 
    inc di  
    
    mov si, offset nomeJogador
    mov cx, nomeJogadorLength
    rep movsb
    
    mov b.[di], ':' 
    inc di 
    
    mov si, offset numeroGeracoesStr
    mov cx, 3 ;comprimento da string com o numero de geracoes
    rep movsb
    
    mov b.[di], ':' 
    inc di 
    
    mov si, offset numeroCelulasStr
    mov cx, 4
    rep movsb
    
    mov si, offset enterStr
    mov cx, 2
    rep movsb
      
    
    
    ret
    
atualizaInfLogStr endp     

;**********************************************************************
; getTime - get system time
; input -  
; output - coloca a hora nas variaveis: hour, minutes, seconds em ascii
;**********************************************************************        
getTime proc
    mov ah, 2ch ; ch-hora, cl-minutos, dh-segundos 
    int 21h 
    mov al, ch  ;procedimento similar ao da funcao getDate
    call hexToAscii 
    mov w. hour, ax 
    mov al, cl                   
    call hexToAscii 
    mov w. minutes, ax 
    mov al, dh                  
    call hexToAscii 
    mov w. seconds, ax

    ret
         
getTime endp              



;****************************************************************
; getDate - get system date
; input -  
; output - coloca a data nas variaveis: year, month, day em ascii
;****************************************************************           
getDate proc 
    mov ah,2ah ;cx-ano, dh-mes, dl- dia
    int 21h  
    
    add cx, 0f830h ; f830h= -2000 logo subtrai-se 2000 a 2022 ficando 22 no cx = 16h
    mov ax, cx
    call hexToAscii
    mov w.year, ax ; ax = dezenas+unidades do ano atual, exemplo: ano 2022, ax=22
    mov al, dh  ;faz-se o mesmo procedimento para o mes e o dia
    call hexToAscii
    mov w.month, ax
    mov al, dl
    call hexToAscii 
    mov w.day, ax
    
    ret 
    
getDate endp  

;****************************************************************
; hexToAscii - converte numero hex para ascii
; input - ax -numero a converter
; output - numero convertido em ax
;****************************************************************
hexToAscii proc 
    push cx
    xor ah, ah
    mov cl, 10 ; para dividir por 10 convertendo para decimal
    div cl ; al=ax/cl, ah=resto da divisao inteira
    add ax, 3030h ; 3030h='0'0' em ascii ao somar converte-se para ascii
    pop cx
    
    ret    
hexToAscii endp              



;****************************************
; apresentaMenu - Apresenta o menu do jogo
; input - nenhum
; output - menu no ecra
;****************************************
apresentaMenu proc
    push bp
         
    ;parametros necessarios para imprimir o menu no ecra
    mov dl, colunaInicioMenu
    mov dh, linhaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    
;botao Jogar 
    mov bp, offset linhaMenu
    call printStrMenu
     
    ;Definir parametros para se chamar o procedimento printStrMenu e invocar o respetivo interrupt
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset jogarStrMenu 
    call printStrMenu
    
    ;Defenir parametros para se chamar o procedimento printStrMenu e invocar o respetivo interrupt
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu 
    
    add dh, 2 
    
;o mesmo processo repete-se para os outros botoes
    
;botao carregar
                                             
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha ; passa para a proxima linha
    mov bp, offset carregarStrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu
    
    add dh, 2 ; faz um intervalo de 1 linha

;botao guardar

    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset guardarStrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu
    
    add dh, 2 ; faz um intervalo de 1 linha 
    
;botao top 5

    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset top5StrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu
    
    add dh, 2 ; faz um intervalo de 1 linha
    
;botao creditos

    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset creditosStrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu 
    
    add dh,2
    
;botao sair

    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset sairStrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu
                                       
                      
    pop bp
    ret
apresentaMenu endp 


;************************************************************************
; comecaJogo - pergunta o nome ao jogador e mostra o menu de jogo no ecra
; 
;***********************************************************************
comecaJogo proc 

    
;desenhar o menu do jogo    
    mov dl,00 
    mov dh,00
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strEcraLength 
    mov bp, offset linhaJogo
    call printStrMenu
    
    mov dl,00
    inc dh ; passa para a proxima linha
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strEcraLength 
    mov bp, offset geracaoStrJogo
    call printStrMenu
    
    mov bx, 0             ;caso seja um jogo carregado
    call updateGeracao
    call updateCelulas 
    
    mov dl,00
    inc dh ; passa para a proxima linha
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strEcraLength 
    mov bp, offset linhaJogo
    call printStrMenu
   
    mov ax, 1             
                 
    escolhaCelula:               ;ativar a celula escolhida
    call getMousePosGraphic
    cmp bx, 1
    jne escolhaCelula
    cmp dx, 24                      
    jb MenuJogo
    cmp dx, 200
    jae escolhaCelula
    cmp cx, 320
    jae escolhaCelula
    cmp cx, 0
    jb escolhaCelula    ;fora da grelha do jogo
    call clickAtivaCelula
    call showMouse
    cmp ax, 1
    jne escolhaCelula
    mov bp, offset numeroGeracoesStr 
    mov byte ptr ds:[bp], 30h
    mov byte ptr ds:[bp+1], 30h
    mov byte ptr ds:[bp+2], 30h
    call updateGeracao
    mov ax, 0
    jmp escolhaCelula
    
    
    MenuJogo:
    cmp cx, 216
    ja IniciarSair
    jmp escolhaCelula
    
    IniciarSair:
    cmp cx, 276
    ja Sair 
    
    Iniciar:        ;vai se calcular o estado das celulas na proxima geracao de acordo com as atuais celulas ativas
    mov ax, 0
    
    
     
    
    celesquerda:              
    push si
    xor bx, bx
    mov cx, 160                  ;canto cima esquerda - direita->baixodir->baixo->calculo                   ax=0
    cmp ax, 0                    ;estrema esquerda - cimadir->cima->direita->baixodir->baixo->calculo       ax=multiplo de 160
    je celdireita 
    
    xor dx, dx                   ;canto cima direito - esquerda->baixoesq->baixo->calculo                   ax=159
    push ax                      ;estremadir - esquerda->cimaesq->baixoesq->cima->baixo->calculo            ax+1=multiplo de 160
    div cx                       ;canto baixo esquerda - cimadir->cima->direita->calculo                    ax=13920
    pop ax                       ;extremo baixo - esquerda->cimaesq->cimadir->cima->direita->calculo        14079>ax>13920
    cmp dx, 0                    ;canto baixo direito - esquerda->cimaesq->cima->calculo                    ax=14079
    je celcimadir
                                 ;extremo cima - esquerda->baixoesq->direita->baixodir->baixo->calculo      0<ax<159
    add si, ax
    sub si, 1
    cmp byte ptr [si], 1  
    jne celcimaesq
    inc bx
    
    celcimaesq:
    pop si
    push si
    cmp ax, 159
    jbe celbaixoesq
    

    add si, ax
    sub si, 161
    cmp byte ptr [si], 1
    jne celcimadir
    inc bx
    
    celcimadir:
    pop si
    push si
    cmp ax, 14079
    je celcima
    
    xor dx, dx
    push ax
    add ax, 1 
    div cx
    pop ax
    cmp dx, 0
    je celbaixoesq 
    
    add si, ax
    sub si, 159
    cmp byte ptr [si], 1
    jne celbaixoesq
    inc bx
           
    celbaixoesq:
    pop si
    push si
    cmp ax, 13920
    jae celcima
    
    xor dx, dx
    push ax
    div cx
    pop ax
    cmp dx, 0
    je celcima
       
    add si, ax
    add si, 159
    cmp byte ptr [si], 1
    jne celcima
    inc bx 

    celcima:
    pop si
    push si
    cmp ax, 159
    je celbaixo
    cmp ax, 159
    jb celdireita
    add si, ax
    sub si, 160
    cmp byte ptr [si], 1
    jne celdireita
    inc bx 

    celdireita:
    pop si
    push si
    cmp ax, 14079
    je calculoestado 
    
    xor dx, dx
    push ax
    add ax, 1 
    div cx
    pop ax
    cmp dx, 0
    je celbaixo
    
    add si, ax
    add si, 1
    cmp byte ptr [si], 1
    jne celbaixodir
    inc bx 
    
    celbaixodir:
    pop si
    push si
    cmp ax, 13920
    jae calculoestado
    add si, ax
    add si, 161
    cmp byte ptr [si], 1
    jne celbaixo
    inc bx

    
    celbaixo:
    pop si
    push si
    add si, ax
    add si, 160
    cmp byte ptr [si], 1
    jne calculoestado     
    inc bx  
    
    calculoestado:       ;calculo do estado da celula
    pop si
    cmp bx, 2
    jb morta
    cmp bx, 3
    ja morta 
    
    cmp bx, 2
    je mantem
    
    
    ;nasce
    push di
    add di, ax
    mov byte ptr [di], 1 ;METE-SE NUMA OUTRA VARIAVEL GLOBAL A PROXIMA GERACAO PARA NAO AFETAR O CALCULO ATUAL
    pop di
    inc ax
    cmp ax, 14080
    je proxima          ;quando percorrer todas as celulas
    jmp celesquerda
     
    mantem:
    push si
    push di
    add di, ax
    add si, ax
    mov bl, byte ptr [si]                    
    mov byte ptr [di], bl
    pop di
    pop si
    inc ax
    cmp ax, 14080
    je proxima
    jmp celesquerda
    
    morta:
    push di
    add di, ax
    mov byte ptr [di], 0
    pop di
    inc ax
    xor bx, bx
    cmp ax, 14080
    je proxima
    jmp celesquerda 
    
    proxima:           ;vai se desenhar no ecra a geracao calculada
    mov ax, 0
    mov cx, 0
    mov bx, offset numeroCelulas
    mov word ptr [bx], ax
    
    novageracao:
    push di
    add di, ax 
    cmp byte ptr [di], 1
    jne morreu   
    
    inc word ptr [bx]     
    pop di
    call ativaCelula
    inc ax
    cmp ax, 14080
    je novocalculo
    jmp novageracao
    
    morreu:
    pop di
    call desativaCelula 
    inc ax
    cmp ax, 14080
    je novocalculo
    jmp novageracao

    novocalculo:
    mov ax, di   ;troca o di e si
    mov di, si
    mov si, ax
     
    call updateCelulas
    push bx
    mov bx, 1
    call updateGeracao 
    pop bx
    push bx
    cmp word ptr [bx], 0
    je Sair
    
    pop bx
    mov bl, 1    ;bl = Numero de segundos entre geracoes (no modo compilado)
    mov al, 0 
    mov ah,2ch
    int 21h    
    add bl, dh
    cmp bl, 60
    jb pausa
    sub bl, 60 

    pausa:
    push bx
    call getMousePosGraphic
    cmp bx, 1
    jne dentroJogo1
    cmp dx, 24
    jae dentroJogo1
    cmp cx, 276
    jb dentroJogo1
    jmp Sair

    dentroJogo1:
    pop bx
    mov ah,2ch
    int 21h
    cmp dh, bl
    je Iniciar   ;inicia-se o calculo na proxima geracao
    jmp pausa  

    Sair:
    pop bx
    mov bl, 2      ;bl = Numero de segundos entre geracoes (no modo compilado)
    mov al, 0
           
    mov ah,2ch
    int 21h    
    add bl, dh
    cmp bl, 60
    jb pausaSaida  ;aqui faz je se ficheiro não existe  
    sub bl, 60 

    pausaSaida:
    mov ah,2ch
    int 21h
    cmp dh, bl  
    jne pausaSaida;aqui faz je se ficheiro não existe  
    ret
comecaJogo endp
                                                                                                                                                              
              
;****************************************************************************************
; pedeNomeJogador - Pede o nome do jogador escrevendo-o no ecra                                                   
;  
;****************************************************************************************              
pedeNomeJogador proc 
     
;parametros para escrever a string pedeNomeStr
    mov dl, 10
    mov dh, 8 
    mov bl, 0f0h
    mov cx, 21
    mov bp, offset pedeNomeStr
    call printStrMenu 
   
;parametros para escrever a string nomejogador 
    mov ax, 7 ;comprimento da string nomeJogador
    mov dl, 12
    mov dh, 10
    mov bl, 0fh
    mov ch, 15
    mov bp, offset nomeJogador   
    call specialscanf
    
    ret 
    
pedeNomeJogador endp 

;****************************************************************************************
; clickAtivaCelula - Ativa a celula escolhida                                                   
; Input - si- offset to arraycelulas cx-Posicao Horizontal, dx-Posicao Vertical
; Output - Celula verde na sua posicao 
;****************************************************************************************
clickAtivaCelula proc
     
          
          
    push ax
    
    mov ax, 2
	int 33h
    
    mov ah, 0dh
    int 10h
    cmp al, 0Ah
    je jaclicada
   
    
    push cx
    push dx                     
    shr cx, 1
    shr dx, 1
    sub dx, 12
    mov ax, 160
    push dx
    mul dx
    pop dx 
    add ax, cx 
    
    push si
    add si, ax
    mov byte ptr [si], 1        ;converteu se as cordenadas do pixel para o numero de celula que foi colocado em ax 
    pop si
    
    add dx, 12                  ;converte-se cx e dx para as coordenas do pixel superior esquerdo da celula
    shl dx, 1
    shl cx, 1
    
    
    mov al, 0Ah
    mov ah, 0ch
    int 10h
    inc cx
    int 10h
    inc dx
    int 10h
    dec cx
    int 10h 
    
    mov bx, offset numeroCelulas   
    inc word ptr [bx] 
    call updateCelulas
     
    
    jmp clickativa
    
    jaclicada: 
    
    push cx
    push dx
                         
    shr cx, 1
    shr dx, 1
    sub dx, 12
    mov ax, 160
    push dx
    
    mul dx
    pop dx 
    add ax, cx 
    
    push si
    add si, ax
    mov byte ptr [si], 0        ;converteu se as cordenadas do pixel para o numero de celula que foi colocado em ax 
    pop si
    
    add dx, 12                  ;converte-se cx e dx para as coordenas do pixel superior esquerdo da celula
    shl dx, 1
    shl cx, 1
    
    
    mov al, 0
    mov ah, 0ch
    int 10h
    inc cx
    int 10h
    inc dx
    int 10h
    dec cx
    int 10h 
    
    mov bx, offset numeroCelulas   
    dec word ptr [bx] 
    call updateCelulas
    
  
     
    clickativa:
    
    call showMouse
    
    mov bl, 1     
    mov al, 0
           
    mov ah,2ch
    int 21h    
    add bl, dh
    cmp bl, 60
    jb esperaentreclicks 
    sub bl, 60 

    esperaentreclicks:
    mov ah,2ch
    int 21h
    cmp dh, bl  
    jne esperaentreclicks
    
    pop dx
    pop cx
    pop ax
    
    ret       
clickAtivaCelula endp


;****************************************
; desativaCelula - desativa uma celula
; input - ax- numero de celula
; output - celula desativada
;**************************************** 
desativaCelula proc
    push cx
    push ax
    xor dx, dx
    mov cx, 160
    div cx 
    mov cx, ax
    mov ax, dx
    mov dx, cx
    mov cx, ax
    add dx, 12
    shl dx, 1
    shl cx, 1
    mov al, 00
    mov ah, 0ch
    int 10h
    inc cx 
    int 10h
    inc dx
    int 10h
    dec cx
    int 10h
    pop ax 
    pop cx
    ret    
desativaCelula endp


;****************************************
; ativaCelula - ativa uma celula
; input - ax- numero de celula
; output - celula ativada
;****************************************
ativaCelula proc
    push cx              
    push ax
    xor dx, dx
    mov cx, 160
    div cx 
    mov cx, ax
    mov ax, dx
    mov dx, cx
    mov cx, ax
    add dx, 12
    shl dx, 1
    shl cx, 1
    mov al, 0Ah 
    mov ah, 0ch
    int 10h
    inc cx 
    int 10h
    inc dx
    int 10h
    dec cx
    int 10h  
    pop ax  
    pop cx
    ret
ativaCelula endp

;****************************************
; updateGeracao - escreve o valor da geracao no ecra
; input - bx = 1-incrementa a geracao
; output - geracoes no ecra
;****************************************     
updateGeracao proc
    
  
  cmp bx, 1
  jne ger_axzero
  mov bl, 39h
  mov cl, 30h
  
  
  mov bp, offset numeroGeracoesStr
                                               
  cmp byte ptr ds:[bp+2], bl
  je incdezenas
  inc byte ptr ds:[bp+2]
  jmp ger_axzero
  
  incdezenas:
  cmp byte ptr ds:[bp+1], bl
  je inccentenas
  mov byte ptr ds:[bp+2], cl                                                              
  inc byte ptr ds:[bp+1]
  jmp ger_axzero 
                         
  inccentenas: 
  cmp byte ptr ds:[bp], bl
  je ger_axzero
  mov byte ptr ds:[bp+2], cl
  mov byte ptr ds:[bp+1], cl
  inc byte ptr ds:[bp]
  jmp ger_axzero
  
  
   
  ger_axzero: 
  mov dl, colunaGeracao
  mov dh, linhaGeracao
  mov bl, 0f0h
  mov cx, strGeracaoLenght
  mov bp, offset numeroGeracoesStr
  call printStrMenu
  
                     
  ret
   
updateGeracao endp

;****************************************
; updateCelulas - escreve o valor da Celulas 
; input - 
; output - celulas no ecra
;****************************************  
updateCelulas proc 
    
    push ax
    push bx
    push cx
    push dx
    
    xor ax, ax 
    xor dx, dx
    mov bx, offset numeroCelulas
    mov bp, offset numeroCelulasStr
    mov ax, word ptr [bx]
    
    mov byte ptr ds:[bp], 30h
    mov byte ptr ds:[bp+1], 30h
    mov byte ptr ds:[bp+2], 30h
    mov byte ptr ds:[bp+3], 30h
    
    cmp ax, 1000
    jb ccentenas
    mov bx, 1000
    div bx
    cmp ax, 9
    jbe dentrolimites
    
    mov byte ptr ds:[bp], 39h
    mov byte ptr ds:[bp+1], 39h
    mov byte ptr ds:[bp+2], 39h
    mov byte ptr ds:[bp+3], 39h
    jmp acima9999
    
    dentrolimites:
    add ax, 30h
    mov byte ptr ds:[bp], al
    mov ax, dx
    ccentenas:
    xor dx, dx
    cmp ax, 100
    jb cdezenas
    mov bx, 100
    div bx
    add ax, 30h
    mov byte ptr ds:[bp+1], al
    mov ax, dx
    cdezenas:
    xor dx, dx
    cmp ax, 10
    jb cunidades
    mov bx, 10
    div bx
    add ax, 30h
    mov byte ptr ds:[bp+2], al
    mov ax, dx
    cunidades:
    add ax, 30h
    mov byte ptr ds:[bp+3], al
     
    mov dl, colunaCelulas
    mov dh, linhaGeracao
    mov bl, 0f0h
    mov cx, strCelulasLenght
    mov bp, offset numeroCelulasStr
    call printStrMenu 
     
    acima9999:  
    
    pop dx
    pop cx 
    pop bx 
    pop ax
    
     
    ret
    
updateCelulas endp

;****************************************
; apagaDados - apaga os dados relacionados com o jogo e pede o novo nome
; input - 
; output - 
;****************************************
apagaDados proc
    mov bp, offset nomeJogador
    mov cx, bp
    add cx, 15

    apagaNome:
    mov byte ptr ds:[bp], 20h
    inc bp
    cmp bp, cx
    jne apagaNome 
    
    mov al,13H
    call setVideoMode        
    call hideBlinkingCursor
    call initMouse
    call showMouse 
    
    call pedeNomeJogador 
      
    mov al,13H
    call setVideoMode
    call hideBlinkingCursor
    call initMouse
    call showMouse
    
    xor cx, cx
    mov bx, offset numeroCelulas
    mov bp, offset numeroCelulasStr
    
    mov word ptr [bx], 0
    cmp byte ptr ds:[bp+3], 30h   
    jne clearCelulas
    cmp byte ptr ds:[bp+2], 30h
    jne clearCelulas
    cmp byte ptr ds:[bp+1], 30h
    jne clearCelulas
    cmp byte ptr ds:[bp], 30h
    jne clearCelulas    
    
;se o numero de celulas for diferente de 0 indica que houve um jogo anterior 
;que e necessario passar as celulas vivas a mortas = 0
;o que e feito na label clearCelulas
    
    jmp primeiroJogo
       
   
    clearCelulas:
    push si
    add si, cx
    mov byte ptr [si], 0
    pop si
    inc cx
    cmp cx, 14080
    jne clearCelulas
    
    primeiroJogo:
    mov byte ptr ds:[bp], 30h   ; 30h - char '0'
    mov byte ptr ds:[bp+1], 30h
    mov byte ptr ds:[bp+2], 30h
    mov byte ptr ds:[bp+3], 30h
                
              
    mov bp, offset numeroGeracoesStr
    mov byte ptr ds:[bp], 30h
    mov byte ptr ds:[bp+1], 30h
    mov byte ptr ds:[bp+2], 30h
    
    ret
    
apagaDados endp  

;****************************************
; guardaJogo - Guarda num ficheiro .gam o numero de geracoes, celulas, nome de jogador e o estado do tabuleiro. 
; input - 
; output - ficheiro .gam do jogo
;****************************************
guardaJogo proc
    
    push si
   
    call getDate 
    call getTime
    
    cld                                  ;guardara o jogo com o formato horas|minutos|4 primeiro caracteres do nome (8 caracteres ao todo para caber no modo compilado) 
    call atualizaInfLogStr
    mov di, offset gamefile
    add di, 3
    mov si, offset infLogStr
    add si, 9
    mov cx, 4                                           ;20221103:145123:JOGADOR:122:0156
    rep movsb
                        
    add si, 3                   
    mov cx, 4  
    rep movsb
    
    
    mov dx, offset gameFile
    xor cx, cx
    
    call fCreate
    mov bx, ax
     
     
    mov dx, offset numeroGeracoesStr
    mov cx, 3
    
    call fWrite
    
    mov dx, offset numeroCelulasStr
    mov cx, 4 
    
    call fWrite
    
    mov dx, offset nomeJogador
    mov cx, 7
    
    call fWrite
     
    pop si 
    mov dx, si
    mov cx, 14080
    
    call fWrite
    
    call fClose
     
    ret
    
guardaJogo endp
               
               
;****************************************
; guardaJogo - Carrega um ficheiro .gam com numero de geracoes, celulas, nome de jogador e o estado do tabuleiro de um jogo guardado. 
; input - 
; output - continuacao de um jogo guardado
;****************************************
carregaJogo proc
    
    
    mov al,13H
    call setVideoMode        
    call hideBlinkingCursor
    call initMouse
    call showMouse
    
    
    mov dl, 7
    mov dh, 8 
    mov bl, 0f0h
    mov cx, 29
    mov bp, offset pedeNomeFileStr
    call printStrMenu
    
    
    mov ax, 8 
    mov dl, 7
    mov dh, 10
    mov bl, 0fh
    mov bp, offset gamefile
    add bp, 3   
    call specialscanf
    
    mov al,13H
    call setVideoMode
    call hideBlinkingCursor
    call initMouse
    call showMouse
    
    mov bx, 0
    mov al, 0
    mov dx, offset gamefile
    
    call fOpen
    jc semficheiro
    
    mov bx, ax
    mov dx, offset numeroGeracoesStr
    mov cx, 3
    
    call fRead
    
    
    mov dx, offset numeroCelulasStr
    mov cx, 4 
    
    call fRead
    
    mov dx, offset NomeJogador
    mov cx, 7
    
    call fRead
    
     
    mov dx, si
    mov cx, 14080
    
    call fRead
    
    call fClose
   
    
    mov bx, 0
    call updateGeracao
    mov ax, 0
    mov bx, offset numeroCelulas 
    mov word ptr [bx], 0
     
    carregarGrelha:
    push si
    add si, ax 
    cmp byte ptr [si], 1
    jne carCelDes   
    
    inc word ptr [bx]     
    pop si
    call ativaCelula
    inc ax
    cmp ax, 14080
    je grelhaCarregada
    jmp carregarGrelha
    
    carCelDes:
    pop si
    call desativaCelula 
    inc ax
    cmp ax, 14080
    je grelhaCarregada
    jmp carregarGrelha
    
    grelhaCarregada:
    call updateCelulas 
    
    mov bx, 1
      
    semficheiro:            ;limpar o gamefile para futuro uso
    mov bp, offset gamefile
    add bp, 3  
    
    mov cx, 0
    limparfilenome:
    mov byte ptr    ds[bp], 20h
    inc bp
    inc cx
    cmp cx, 8
    jb limparfilenome
       
      
    ret

carregaJogo endp  

;****************************************
; apresentaCreditos - Le o ficheiro top5.txt e apresenta o seu conteudo
; input - 
; output - Top 5 no ecra
;****************************************    
apresentaTop5 proc
    mov al,13h
    call setVideoMode        ;clear screen
    call hideBlinkingCursor
    
    ; Input - cx-Numero de bytes a escrever, bp-String, dl/dh-Coordenadas, bl-Atributos
    mov dl, colunaInicioMenu
    mov dh, linhaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset top5StrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu 
    
    mov dx, offset top5file
    mov al, 2
    
    call fOpen
    mov bx, ax
    
    push bx
    mov dh, 5
    mov dl, 0
    mov bl, 0fh
    mov cx, 36
    mov bp, offset top5info 
    call printStrMenu
    
    pop bx
    xor cx, cx
    mov dx, 38
    mov al, 0
    mov ah, 42h
    int 21h
    
    mov dx, offset top5ex
    mov cx, 40
    
    call fRead
    
    push bx
    mov dh, 6 
    mov dl, 0
    mov bl, 0fh
    mov cx, 40 
    mov bp, offset top5ex 
    call printStrMenu
    
    pop bx
    xor cx, cx
    mov dx, 2
    mov al, 1
    mov ah, 42h
    int 21h
    
    mov dx, offset top5ex
    mov cx, 40
    
    call fRead
    
    push bx
    mov dh, 7 
    mov dl, 0
    mov bl, 0fh
    mov cx, 40 
    mov bp, offset top5ex 
    call printStrMenu
    
    pop bx
    xor cx, cx
    mov dx, 2
    mov al, 1
    mov ah, 42h
    int 21h
    
    mov dx, offset top5ex
    mov cx, 40
    
    call fRead
    
    push bx
    mov dh, 8 
    mov dl, 0
    mov bl, 0fh
    mov cx, 40 
    mov bp, offset top5ex 
    call printStrMenu
    
    pop bx
    xor cx, cx
    mov dx, 2
    mov al, 1
    mov ah, 42h
    int 21h
    
    mov dx, offset top5ex
    mov cx, 40
    
    call fRead
    
    push bx
    mov dh, 9 
    mov dl, 0
    mov bl, 0fh
    mov cx, 40 
    mov bp, offset top5ex 
    call printStrMenu
    
    pop bx
    xor cx, cx
    mov dx, 2
    mov al, 1
    mov ah, 42h
    int 21h
    
    mov dx, offset top5ex
    mov cx, 40
    
    call fRead
    
    push bx
    mov dh, 10
    mov dl, 0
    mov bl, 0fh
    mov cx, 40 
    mov bp, offset top5ex 
    call printStrMenu 
    
    pop bx
              
    call fClose
              
    mov bl, 10 ; Numero de segundos
    mov al, 0 
    
    mov ah,2ch
    int 21h;neste cado - tamos a colocar os segundoes em dh    
    add bl, dh
    cmp bl, 60
    jb countdowntop5
    sub bl, 60 
    
    countdowntop5:
    ;caso passe os 10 segundos
    mov ah,2ch
    int 21h
    cmp dh, bl;quer dizer que já passaram todos os segundoes de bl
    je sairTop5 ;saida via espera

    ;caso se prima uma key
    mov ah,01h
    int 16h;le key do buffer
    cmp al,00;Como quase todas as key dão diferente de 0, saimos via keystroke
    jne sairTop5Key ;saida via keystroke
    jmp countdowntop5 
    
    ;limpamos para tirar a key que foi introduzida para sair do top5
    sairTop5Key: ;clear buffer
    mov ah,00h
    int 16h 
    
    sairTop5: 
   
              
    ret          
              
apresentaTop5 endp


;****************************************
; apresentaCreditos - Apresenta os creditos
; input - nenhum
; output - creditos no ecra
;****************************************
apresentaCreditos proc
    mov al,13h
    call setVideoMode        ;clear screen
    call hideBlinkingCursor
    
    ; Input - cx-Numero de bytes a escrever, bp-String, dl/dh-Coordenadas, bl-Atributos
    mov dl, colunaInicioMenu
    mov dh, linhaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength 
    mov bp, offset linhaMenu
    call printStrMenu
     
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha 
    mov bp, offset creditosStrMenu 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0f0h ; fundo branco, letra preta
    mov cx, strMenuLength
    inc dh ; passa para a proxima linha
    mov bp, offset linhaMenu
    call printStrMenu   
    
    add dh, 2 ; faz um intervalo de 1 linha 
    ;String de Tiago e o seu número no ecra
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosLength 
    mov bp, offset tiago 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosNLength
    inc dh ; passa para a proxima linha 
    mov bp, offset numtiago 
    call printStrMenu
    
    add dh, 2 ; faz um intervalo de 1 linha 

    ;String de Isaac e o seu número no ecra
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosLength 
    mov bp, offset Isaac 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosNLength
    inc dh ; passa para a proxima linha 
    mov bp, offset numIsaac 
    call printStrMenu
    
    add dh, 2 ; faz um intervalo de 1 linha 

    ;String de Lucas e o seu número no ecra    
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosLength 
    mov bp, offset Lucas 
    call printStrMenu
    
    mov dl, colunaInicioMenu
    mov bl, 0fh
    mov cx, strCreditosNLength
    inc dh ; passa para a proxima linha 
    mov bp, offset numLucas 
    call printStrMenu    
    
    mov bl, 10 ; Numero de segundos
    mov al, 0
    
    ;Temporizador para saida dos créditos
    mov ah,2ch
    int 21h;neste cado - tamos a colocar os segundoes em dh    
    add bl, dh
    cmp bl, 60
    jb countdown
    sub bl, 60 

    countdown:
    ;caso passe os 10 segundos
    mov ah,2ch
    int 21h
    cmp dh, bl;quer dizer que já passaram todos os segundoes de bl
    je sairCreditos ;saida via espera

    ;caso se prima uma key
    mov ah,01h
    int 16h;le key do buffer
    cmp al,00;Como quase todas as key dão diferente de 0, saimos via keystroke
    jne sairCreditosKey ;saida via keystroke
    jmp countdown 
    
    ;limpamos para tirar a key que foi introduzida para sair dos créditos
    sairCreditosKey: ;clear buffer
    mov ah,00h
    int 16h
     
    sairCreditos:
      
    ret    
apresentaCreditos endp



;****************************************************************************************
; printStrMenu - Escreve uma string no menu do jogo                                                   
; Input - cx-Numero de bytes a escrever, bp-String, dl/dh-Coordenadas, bl-Atributos
; Output - string no ecra 
;****************************************************************************************
printStrMenu proc
    push ax
    push bx

    mov al, 1 ; tipo de escrita: string tem atributos (cor)
    xor bh, bh  ; bh=0, numero da pagina  

    mov ah, 13h 
    int 10h

    pop bx
    pop ax
    ret
printStrMenu endp

;********************* funcoes de mouse ********************** 



; ****************************************************
; initMouse - Initialize Mouse
;
; Input:Nothing
;
; Output:
; AX- 0000h if Error; FFFFh if Detected
; BX=number of mouse buttons
; Destroys:Nothing
;
initMouse proc
	mov ax,00
	int 33h
	ret
endp 


; ****************************************************
; showMouse - Show Mouse Pointer
;
; Input: Nothing
;
; Output: Nothing
;
showMouse proc
	push ax
	mov ax, 1
	int 33h
	pop ax
	ret
endp


; ****************************************************
; getMousePos - Get Mouse Position and Button pressed
; Input: Nothing
;Output:
; 	BX- Button pressed (1 - botao da esquerda, 2 - botao da direita e  3 - ambos os botoes)
; 	CX- horizontal position (column)
; 	DX- Vertical position (row)
; Destroys: Nothing else
;
getMousePos proc
	push ax
	mov ax,03h
	int 33h
	pop ax
	ret
getMousePos endp

; *******************************************************************************
; getMousePosGraphic - Get Mouse Position and Button pressed (if in Graphic mode)
; Input: Nothing
;Output:
; 	BX- Button pressed (1 - botao da esquerda, 2 - botao da direita e  3 - ambos os botoes)
; 	CX- horizontal position (column)
; 	DX- Vertical position (row)
; Destroys: Nothing else
;
getMousePosGraphic proc
	push ax
	mov ax,03h
	int 33h
	shr cx, 1
	pop ax
	ret
getMousePosGraphic endp

    
    
;********************* funcoes de modo de modo de video ********************** 


;**************************************
; setVideoMode - Ativa o modo de video        
; Parametros: ah-Modo de Video 
;**************************************
;Setting the video mode.
setVideoMode proc
    push ax

    mov ah,00
    Int 10h

    pop ax
    ret
setVideoMode endp 

;**************************************************
; hideBlinkingCursor -Esconde o cursor intermitente
; input - nenhum
; output - esconde o cursor
;**************************************************
;Hiding the blinking cursor.
HideBlinkingCursor proc
push cx

mov ch, 32
mov ah, 1
int 10h

pop cx
ret
HideBlinkingCursor endp
    
    
;********************* funcoes de manipulacao de ficheiros *******************

        
    
;*****************************************************************************
; fCreate - Cria um ficheiro                                                          
; Parametros: dx-Nome, cx-Atributos                                         
; Retorno: CF-Sucesso/Insucesso(0/1), ax-Handler(CF=0)/Codigo de Erro(CF=1)
;*****************************************************************************
fCreate proc
       
    mov ah, 3Ch
    int 21h
        
    ret    
fCreate endp 


;*****************************************************************************
; fOpen - Abre um ficheiro                                                          
; Parametros: dx-Nome, al-Tipo de acesso(0-R, 1-W, 2-R/W)                   
; Retorno: CF-Sucesso/Insucesso(0/1), ax-Handler(CF=0)/Codigo de Erro(CF=1) 
;*****************************************************************************
fOpen proc

    mov ah, 3Dh
    int 21h

    ret
fOpen endp


;*******************************************************************
; fRead - Le o numero de bytes pedidos de um ficheiro para um buffer  
; Parametros: bx-Handler, cx-Numero de bytes a ler, dx-Buffer 
;*******************************************************************
fRead proc
push ax
mov ah, 3Fh
int 21h
inc dx
pop ax
ret
fRead endp 


;********************************************************************
; fWrite - Escreve o numero de bytes pedidos num ficheiro de um buffer      
; Parametros: bx-Handler, cx-Numero de bytes a escrever, dx-Buffer 
;********************************************************************
fWrite proc
push ax
mov ah, 40h
int 21h
pop ax
ret
fWrite endp 


;**************************
; fClose - Fecha o ficheiro       
;* Parametros: bx-Handler 
;**************************
fClose proc
push ax
mov ah, 3Eh
int 21h
pop ax
ret
fClose endp


;****************************************************************************************
; specialscanf - le uma string escrevendo-a no ecra, compativel com a tecla backspace para                                                   
;                apagar  o que foi escrito 

; input - ax, tamanho da caixa de texto (limite 255)
; output - caixa de texto para escrever o que guardara numa string escolhida apontada em bp 
;**************************************************************************************** 
specialscanf proc 
 
push ax ;comprimento da string                 
mov ax, 0
mov cx, 0
            
L2:
;Ve se o utilizador precionou o enter. Se precionou sai do programa
call ci
cmp al, 0Dh
je nomeEnter

;Jump to notbs se nao for um backspace
cmp al, 08h ; 8h - char backspace
jne notbs

cmp cx, 0 ;se for o primeiro caracter da string nao acontece nada 
je L2

xor ch, ch;ch = 0
dec cx
dec bp                               
mov al, 20h  ;20h - char ' '
mov byte ptr ds:[bp], al   ;coloca um espaco em branco no lugar do caracter apagado
sub bp, cx
inc cx ; numero de bytes a escrever no ecra  
call printStrMenu
dec cx
add bp, cx
jmp L2

notbs:
mov ch, al ; caracter lido
pop ax  ;comprimento da string
push ax
cmp cl, al
je L2
mov al, ch
xor ch, ch
mov byte ptr ds:[bp], al ;coloca o caracter lido na string pretendida
inc cx ;numero de bytes a escrever no ecra
inc bp 
sub bp, cx ;posicao da qual a string vai ser escrita
call printStrMenu
add bp, cx ;proxima posicao de leitura do teclado para a string
jmp L2 

nomeEnter:
pop ax
ret

specialscanf endp


;****************************************************************************************
; ci - recebe input do teclado sem eco
; output - al fica com o caracter
;****************************************************************************************     
ci proc
    mov ah, 7 
    int 21h
    ret
ci endp
  
        
end start ; set entry point and stop the assembler.SSS