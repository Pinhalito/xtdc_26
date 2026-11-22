#!/bin/bash
#
#######################
#    ^...^  `^...^´   #
#   / o,o \ / O,O \   #
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
# 2026_11_16_20_38_22


# Impede a execução com sh
if [ -z "${BASH_VERSION:-}" ]; then
    echo "Execute este script com Bash:"
    echo "bash $0"
    exit 1
fi

RAIZ="$(pwd)"
ARQUIVO_TUDO="$RAIZ/todos_desktop.txt"

criar_tudo_desktop() {
    : > "$ARQUIVO_TUDO"

    while IFS= read -r -d '' arquivo; do
        caminho_relativo="${arquivo#$RAIZ/}"

        printf '=== ARQUIVO: %s ===\n' "$caminho_relativo" >> "$ARQUIVO_TUDO"
        cat -- "$arquivo" >> "$ARQUIVO_TUDO"
        printf '\n\n' >> "$ARQUIVO_TUDO"

    done < <(
        find "$RAIZ" \
            -type f \
            -name "*.desktop" \
            ! -path "$ARQUIVO_TUDO" \
            -print0
    )

    echo "Criado: $ARQUIVO_TUDO"
}

# Recria os arquivos usando o todos_desktop.txt da raiz
recriar_arquivos() {
    if [ ! -f "$ARQUIVO_TUDO" ]; then
        echo "Erro: o arquivo todos_desktop.txt não existe na raiz."
        return 1
    fi

    local nome_arquivo=""
    local conteudo=""
    local linha
    local caminho_completo

    while IFS= read -r linha || [ -n "$linha" ]; do

        if [[ "$linha" =~ ^===\ ARQUIVO:\ (.*)\ ===$ ]]; then

            # Salva o arquivo anterior
            if [ -n "$nome_arquivo" ]; then
                caminho_completo="$RAIZ/$nome_arquivo"

                mkdir -p -- "$(dirname -- "$caminho_completo")"
                printf '%s' "$conteudo" > "$caminho_completo"

                echo "Recriado: $nome_arquivo"
            fi

            nome_arquivo="${BASH_REMATCH[1]}"
            conteudo=""

        else
            conteudo+="$linha"$'\n'
        fi

    done < "$ARQUIVO_TUDO"

    # Salva o último arquivo
    if [ -n "$nome_arquivo" ]; then
        caminho_completo="$RAIZ/$nome_arquivo"

        mkdir -p -- "$(dirname -- "$caminho_completo")"
        printf '%s' "$conteudo" > "$caminho_completo"

        echo "Recriado: $nome_arquivo"
    fi
}

xtdc_confia_todos(){
    dica="- Marca todos .desktop do diretório como confiáveis"
    local raiz="${1:-$RAIZ}"
    local achou=0
    while IFS= read -r -d '' f; do
        chmod +x -- "$f"
        local hash
        hash=$(sha256sum -- "$f" | awk '{print $1}')
        gio set -t string "$f" metadata::xfce-exe-checksum "$hash"
        echo "OK: $f"
        achou=1
    done < <(find "$raiz" -name '*.desktop' -print0)
    [[ $achou -eq 0 ]] && echo "Nenhum .desktop encontrado em $raiz"
}   

recria_links(){
    find . -type l -exec sh -c '
for link do
    dir=$(dirname "$link")
    nome=$(basename "$link")
    printf "%s\n" "$nome" >> "$dir/.hidden"
done
' sh {} +
}


# Menu principal
echo "Selecione a opção:"
echo "1 - Criar todos_desktop.txt com os desktop"
echo "2 - Recriar arquivos a partir de todos_desktop.txt"

read -r -p "Opção: " opcao

case "$opcao" in
    1)
        criar_tudo_desktop
        ;;

    2)
        recriar_arquivos
        recria_links
        xtdc_confia_todos
        ;;
    *)
        echo "Opção inválida."
        exit 1
        ;;
esac

echo "Operação concluída."
