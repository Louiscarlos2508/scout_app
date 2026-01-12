#!/bin/bash
# Script pour lancer l'application Flutter sur le web avec les en-têtes HTTP corrects
# pour supporter Drift/WASM
#
# Les en-têtes COOP/COEP sont nécessaires pour utiliser WebAssembly avec Drift
# Note: Ces en-têtes peuvent affecter certaines fonctionnalités comme les pop-ups

echo "Lancement de l'application Flutter sur Chrome avec support WASM..."
echo "Note: Les fichiers sqlite3.wasm et drift_worker.js doivent être dans web/"

flutter run -d chrome \
  --web-header="Cross-Origin-Opener-Policy=same-origin" \
  --web-header="Cross-Origin-Embedder-Policy=require-corp"
