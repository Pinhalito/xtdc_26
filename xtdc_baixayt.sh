#!/bin/bash
#
#######################
#    ^...^  `^...^´   #
#   /_o,o_\ /_O,O_\   #
#   |):::(| |):::(|   #
# ====" "=====" "==== #
#         TdC         #
#      1998-2026      #
#######################
#
# Toca das Corujas
# Códigos Binários,
# Funções de Onda e
# Teoria do Orbital Molecular Inc.
# Unidade Barão Geraldo CX
#
# 2026_11_22_13_35_40


export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

cd "$HOME/Vídeos" || exit 1
URL="$(xclip -selection clipboard -o | tr -d '\r\n')"

# Remove espaços no início e no final.
URL="${URL#"${URL%%[![:space:]]*}"}"
URL="${URL%"${URL##*[![:space:]]}"}"

# Verifica se o conteúdo parece ser uma URL válida
# ou uma ID de vídeo com 11 caracteres.
if [[ ! "$URL" =~ ^https?://[^[:space:]]+$ &&
      ! "$URL" =~ ^[A-Za-z0-9_-]{11}$ ]]; then

    echo "Erro: o clipboard não contém uma URL ou ID válida." && notify-send -t 3000 -i dialog-information "URL INVÁLIDA"
    echo "Conteúdo encontrado: $URL"
    exit 1
fi

# Se o clipboard contiver somente uma ID, transforma em URL do YouTube.
if [[ "$URL" =~ ^[A-Za-z0-9_-]{11}$ ]]; then
    URL="https://www.youtube.com/watch?v=$URL"
fi

# Menu de opções
echo
echo "URL/ID detectada:"
echo "$URL"
echo
echo "Escolha o tipo de download:"
echo
echo "1) MP4"
echo "2) MP3"
echo "0) Cancelar"
echo
read -rp "Digite uma opção: " OPCAO

case "$OPCAO" in

    1)
        yt-dlp \
            -f "bv*[height<=720][vcodec^=avc1][ext=mp4]+ba[acodec^=mp4a][ext=m4a]/b[height<=720][ext=mp4]" \
            --merge-output-format mp4 \
            --recode-video mp4 \
            --postprocessor-args "VideoConvertor:-c:v libx264 -preset veryfast -crf 25 -c:a aac -b:a 128k -pix_fmt yuv420p -movflags +faststart" \
            "$URL"
        ;;
        
    2)
        yt-dlp \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        "$URL"
        ;;

    0)
        echo "Operação cancelada."
        exit 0
        ;;

    *)
        echo "Erro: opção inválida."
        exit 1
        ;;

esac
