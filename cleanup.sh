#!/bin/zsh

echo "Suppression des dossiers .ipynb_checkpoints..."
find . -type d -name ".ipynb_checkpoints" -exec rm -rf {} +

echo "Suppression du cache pip..."
rm -rf ~/.cache/pip

echo "Nettoyage des caches Conda..."
conda clean --all --yes

echo "Nettoyage Docker..."
docker system prune -a --volumes --force

echo "Script terminé. Pense à redémarrer ton Codespace si possible."

df -h

# ./cleanup.sh TO RUN IT