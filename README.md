# PAYTECH — Kubernetes Security Lab

[![Kubernetes](https://img.shields.io/badge/Kubernetes-Security-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Trivy](https://img.shields.io/badge/Security-Trivy-1904DA)](https://trivy.dev/)
[![Educational](https://img.shields.io/badge/Projet-Pédagogique-success)]()

**Étude de cas pratique — Audit et sécurisation d'un cluster Kubernetes**

PAYTECH est une entreprise fictive dont la plateforme web repose sur Kubernetes. Votre équipe intervient comme consultants DevSecOps pour auditer une infrastructure volontairement mal configurée, corriger les risques et démontrer l'efficacité des mesures de sécurité.

> **Public cible :** Master Cybersécurité / formation DevOps  
> **Durée indicative :** 4 à 6 heures  
> **Organisation :** binômes  
> **Niveau :** intermédiaire

## Objectifs pédagogiques

- Auditer les ressources et configurations Kubernetes.
- Durcir les conteneurs avec `SecurityContext`.
- Appliquer le moindre privilège avec RBAC.
- Segmenter les communications avec NetworkPolicies.
- Comprendre la protection des Secrets Kubernetes.
- Analyser images et manifestes avec Trivy.
- Appliquer les Pod Security Standards et les quotas.
- Produire des preuves techniques et un rapport de remédiation.

## Parcours du TP

| Mission | Sujet | Résultat attendu |
|---|---|---|
| 1 | Audit initial | Cartographie des risques |
| 2 | Sécurité des conteneurs | Workloads durcis |
| 3 | RBAC | Permissions minimales vérifiées |
| 4 | NetworkPolicies | Flux réseau maîtrisés |
| 5 | Secrets et images | Données sensibles protégées, images analysées |
| 6 | Pod Security et ressources | Politique de sécurité appliquée |
| Final | Incident PAYTECH | Rapport et restitution |

## Architecture

```text
                  UTILISATEURS
                       |
                FRONTEND (web)
                namespace frontend
                       |
                 API BACKEND
                namespace backend
                       |
                 PostgreSQL
                namespace database

          namespace monitoring (extension)
```

Flux cible : utilisateur → frontend ; frontend → backend selon le besoin ; backend → PostgreSQL TCP/5432 ; frontend → PostgreSQL interdit.

## Démarrer

1. Lire [`l'énoncé étudiant`](01-Dossier-Etudiant/Enonce-PAYTECH.md).
2. Préparer l'environnement avec [`le guide du laboratoire`](03-Laboratoire/README-LAB.md).
3. Déployer les manifestes de `03-Laboratoire/01-vulnerable/`.
4. Réaliser les missions dans l'ordre.
5. Construire vos propres manifestes corrigés dans un répertoire de travail séparé.
6. Exécuter les vérifications et documenter les preuves.

## Prérequis

- Linux récent (Ubuntu/Debian recommandé)
- Docker
- `kubectl`
- `kind`
- Trivy
- Un CNI compatible NetworkPolicy pour la mission réseau (Calico recommandé)

Ressources conseillées : 4 vCPU, 8 Go RAM minimum, 30 Go disque ; 12 Go RAM recommandés.

## Structure du dépôt

```text
.
├── 01-Dossier-Etudiant/
│   └── Enonce-PAYTECH.md
├── 03-Laboratoire/
│   ├── 00-namespaces/
│   ├── 01-vulnerable/
│   ├── 03-verification/
│   └── README-LAB.md
├── 04-Ressources/
│   ├── Glossaire.md
│   └── References.md
├── CONTRIBUTING.md
├── ROADMAP.md
├── SECURITY.md
└── LICENSE
```

## Perspective d'évolution : vers un projet DevSecOps

Le TP initial se concentre sur la sécurité Kubernetes. Les corrigés formateur ne sont pas publiés dans ce dépôt étudiant afin de préserver l'activité d'évaluation. Une extension pourra transformer PAYTECH en chaîne DevSecOps intégrée :

1. **GitLab CI/CD** : pipeline de validation à chaque commit et avant déploiement.
2. **Trivy** : scan des images, dépendances et manifestes Kubernetes ; seuils de blocage définis.
3. **SonarQube** : analyse statique du code applicatif et qualité logicielle.
4. **Contrôles de conformité Kubernetes** : validation des manifestes et politiques d'admission.
5. **Supply chain security** : SBOM, signature et vérification de provenance des images.
6. **Observabilité sécurité** : centralisation des événements, audit Kubernetes et alertes.

Cette phase est une perspective pédagogique : elle n'est pas nécessaire pour terminer le TP de base. Voir [`ROADMAP.md`](ROADMAP.md).

## Règles de sécurité

- Utiliser exclusivement un cluster local/jetable dédié au TP.
- Ne jamais appliquer les manifestes vulnérables sur un cluster de production.
- Les identifiants présents dans le laboratoire sont fictifs et ne doivent jamais être réutilisés.
- Ne jamais publier de vrais secrets, kubeconfigs ou certificats.
- Les NetworkPolicies ne sont effectives que si le CNI les prend en charge.
- Ce laboratoire ne représente pas une plateforme de paiement réelle.

## Contributions

Les améliorations pédagogiques, corrections et propositions d'exercices sont bienvenues. Lire [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Licence

Voir [`LICENSE`](LICENSE).
