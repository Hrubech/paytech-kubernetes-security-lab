# Politique de sécurité du dépôt

Ce dépôt contient volontairement des manifestes Kubernetes vulnérables à des fins pédagogiques.

## Utilisation autorisée

- Déploiement dans un cluster local et isolé dédié au TP.
- Analyse et correction dans le cadre de la formation.
- Tests de sécurité sur les ressources du laboratoire uniquement.

## Interdictions

- Ne pas déployer les manifestes vulnérables sur un cluster de production.
- Ne pas utiliser les identifiants de démonstration ailleurs.
- Ne pas ajouter de kubeconfig, token, clé privée ou secret réel au dépôt.
- Ne pas utiliser ce laboratoire pour tester des systèmes tiers.

## Signaler un problème

Ouvrir une issue en évitant de publier des secrets ou données sensibles. Pour une vulnérabilité affectant un composant tiers, suivre la procédure de signalement responsable du projet concerné.
