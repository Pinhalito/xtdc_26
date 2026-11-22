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
# 2026_11_18_19_06_38

# Impede a execução com sh
if [ -z "${BASH_VERSION:-}" ]; then
    echo "Execute este script com Bash:"
    echo "bash $0"
    exit 1
fi

ROOT="$(pwd)"
LISTA="todos_sl.txt"

echo "1) Buscar links simbólicos e criar $LISTA"
echo "2) Recriar links a partir de $LISTA"
read -r -p "Escolha: " opcao

case "$opcao" in
  1)
    : > "$LISTA"
    while IFS= read -r -d '' link; do
      destino=$(readlink -- "$link") || continue
      printf '%s\t%s\n' "$link" "$destino" >> "$LISTA"
    done < <(find "$ROOT" -type l -print0)

    echo "Lista criada: $LISTA"
    ;;

  2)
    if [[ ! -f "$LISTA" ]]; then
      echo "Não encontrei $LISTA."
      exit 1
    fi

    while IFS=$'\t' read -r link destino; do
      [[ -z "$link" ]] && continue

      mkdir -p -- "$(dirname -- "$link")"
      if [[ -e "$link" || -L "$link" ]]; then
        echo "Já existe; ignorado: $link"
      else
        ln -s -- "$destino" "$link" && echo "Criado: $link -> $destino"
      fi
    done < "$LISTA"
    ;;

  *)
    echo "Opção inválida."
    exit 1
    ;;
esac
