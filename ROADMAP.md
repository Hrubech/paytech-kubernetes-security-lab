# PAYTECH — Roadmap pédagogique

## Version 1 — Kubernetes Security Lab (socle)

Objectif : sécuriser les workloads et les échanges dans un cluster Kubernetes.

- [x] Scénario d'entreprise PAYTECH
- [x] Audit des configurations
- [x] Durcissement des conteneurs
- [x] RBAC et moindre privilège
- [x] NetworkPolicies
- [x] Secrets Kubernetes
- [x] Scan Trivy
- [x] Pod Security Standards
- [x] ResourceQuota et LimitRange
- [ ] Ajouter un jeu de tests automatisés reproductibles pour tous les contrôles

## Version 2 — DevSecOps CI/CD

Objectif : déplacer les contrôles de sécurité vers le pipeline de livraison.

- [ ] Créer une application PAYTECH minimale avec code source.
- [ ] Mettre en place GitLab CI/CD.
- [ ] Ajouter tests unitaires et analyse SonarQube.
- [ ] Scanner les images Docker avec Trivy.
- [ ] Générer et archiver un SBOM.
- [ ] Définir des seuils de blocage selon la sévérité et l'exploitabilité.
- [ ] Vérifier les manifestes Kubernetes avant déploiement.
- [ ] Séparer les environnements de test et de production.
- [ ] Ajouter une étape d'approbation avant déploiement.

## Version 3 — Kubernetes Policy & Supply Chain

Objectif : renforcer la gouvernance des déploiements.

- [ ] Introduire Kyverno ou Gatekeeper pour les politiques d'admission.
- [ ] Interdire les conteneurs privilégiés.
- [ ] Imposer les images provenant de registres autorisés.
- [ ] Vérifier les signatures d'images (Cosign).
- [ ] Exiger des SBOM et métadonnées de provenance.
- [ ] Définir des exceptions contrôlées et documentées.

## Version 4 — Détection et réponse

Objectif : améliorer la visibilité et la capacité de réaction.

- [ ] Activer et centraliser les Kubernetes Audit Logs.
- [ ] Construire des alertes sur les événements sensibles.
- [ ] Étudier Falco pour la détection runtime.
- [ ] Définir des scénarios d'incident et procédures de réponse.
- [ ] Produire un tableau de bord de posture de sécurité.

## Proposition de critères de maturité

| Niveau | Description |
|---|---|
| 1 — Initial | Contrôles manuels, configurations hétérogènes |
| 2 — Contrôlé | Baseline sécurité et vérifications documentées |
| 3 — Automatisé | Contrôles intégrés dans CI/CD |
| 4 — Gouverné | Politiques d'admission, signature et traçabilité |
| 5 — Surveillé | Détection runtime, audit et réponse aux incidents |

La roadmap est indicative. Chaque extension doit être accompagnée d'un objectif, d'un scénario, de critères de réussite et de preuves.
