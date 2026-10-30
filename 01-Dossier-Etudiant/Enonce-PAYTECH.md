# TP — Audit et sécurisation d'un cluster Kubernetes
## Fil rouge : PAYTECH

**Public :** Master 1 Cybersécurité  
**Durée indicative :** 4 à 6 heures  
**Organisation :** binômes  
**Environnement :** cluster Kubernetes local de laboratoire  
**Évaluation :** 20 points

---

## 1. Contexte professionnel

PAYTECH est une entreprise qui fournit une plateforme web de consultation de transactions. Son application repose sur une architecture Kubernetes composée d'un frontend web, d'une API métier et d'une base PostgreSQL.

À la suite d'une revue de sécurité, l'équipe SSI suspecte plusieurs mauvaises configurations : conteneurs privilégiés, droits RBAC trop larges, absence de segmentation réseau, secrets insuffisamment protégés, ressources non limitées et images non contrôlées.

Vous intervenez comme consultants DevSecOps. Votre mission est d'auditer l'environnement, de qualifier les risques, de corriger les configurations et de démontrer que les mesures fonctionnent.

**Règle :** tous les tests doivent être réalisés uniquement sur le cluster PAYTECH fourni pour le TP.

## 2. Objectifs pédagogiques

À l'issue du TP, vous devez être capables de :
- examiner les ressources et la posture de sécurité d'un cluster ;
- repérer les risques liés aux SecurityContext ;
- appliquer le principe du moindre privilège avec RBAC ;
- segmenter les flux avec NetworkPolicy ;
- protéger les Secrets et comprendre leurs limites ;
- analyser les images et manifestes avec Trivy ;
- appliquer les Pod Security Standards ;
- produire des preuves et un rapport de remédiation.

## 3. Architecture cible

```text
                    UTILISATEUR
                         |
                   Ingress / HTTP
                         |
                 +-------+-------+
                 |               |
              FRONTEND         BACKEND
              namespace        namespace
                 |               |
                 |          TCP 5432
                 |               |
                 +----X----> DATABASE
                              namespace
                              PostgreSQL
```

Flux attendu après sécurisation :
- utilisateur → frontend : autorisé ;
- frontend → backend : autorisé uniquement si nécessaire ;
- backend → PostgreSQL : TCP/5432 autorisé ;
- frontend → PostgreSQL : interdit ;
- autres flux non nécessaires : interdits selon les règles définies.

Le laboratoire peut utiliser un accès direct par port-forward plutôt qu'un Ingress réel. Le but du TP est la sécurité Kubernetes, pas la mise en production d'un contrôleur Ingress.

## 4. Organisation du travail

Pour chaque mission :
1. observer l'état initial ;
2. identifier les éléments suspects ;
3. expliquer le risque métier et technique ;
4. proposer une correction ;
5. appliquer la correction ;
6. tester le résultat ;
7. conserver une preuve.

Ne passez pas à la mission suivante sans avoir documenté les résultats.

---

# Mission 1 — Audit initial

**Durée indicative : 35 minutes — 3 points**

### Objectif
Établir un état des lieux du cluster et identifier les mauvaises configurations.

### Travail demandé
Exécuter et interpréter les commandes suivantes :

```bash
kubectl get nodes -o wide
kubectl get namespaces
kubectl get pods -A -o wide
kubectl get deployments -A
kubectl get serviceaccounts -A
kubectl get roles,rolebindings -A
kubectl get clusterroles,clusterrolebindings
kubectl get networkpolicies -A
```

Examiner les configurations :

```bash
kubectl get pods -A -o yaml
kubectl describe pod -n frontend -l app=web
kubectl auth can-i --list -n frontend
```

Si le sélecteur ne correspond pas, identifier le Pod avec `kubectl get pods -n frontend --show-labels`, puis utiliser son nom.

### Questions
1. Quelles ressources sont exposées ou accessibles ?
2. Quels conteneurs fonctionnent en root ?
3. Que signifie `privileged: true` ?
4. Quels droits sont attribués au compte de service de l'application ?
5. Existe-t-il des politiques réseau ?
6. Pourquoi faut-il associer chaque constat à un risque métier ?

### Livrable M1
Un tableau contenant au minimum cinq constats : ressource concernée, mauvaise configuration, risque, criticité proposée et recommandation.

---

# Mission 2 — Durcissement des conteneurs

**Durée indicative : 45 minutes — 3 points**

### Objectif
Réduire les privilèges disponibles dans les conteneurs.

### Travail demandé
1. Examiner le manifeste vulnérable `03-Laboratoire/01-vulnerable/frontend-deployment.yaml`.
2. Identifier les paramètres dangereux.
3. Modifier le manifeste pour :
   - exécuter le processus avec un UID non-root ;
   - interdire l'élévation de privilèges ;
   - supprimer les capabilities non nécessaires ;
   - rendre le système de fichiers racine en lecture seule lorsque l'application le permet ;
   - définir des requests et limits CPU/mémoire ;
   - éviter le mode privilégié.
4. Déployer la version corrigée.
5. Vérifier la configuration réellement appliquée.

Commandes utiles :

```bash
kubectl get deployment -n frontend web -o yaml
kubectl get pods -n frontend
kubectl describe pod -n frontend <nom-du-pod>
kubectl exec -n frontend <nom-du-pod> -- id
```

### Questions
1. Quelle différence entre `runAsUser` et `runAsNonRoot` ?
2. À quoi sert `allowPrivilegeEscalation: false` ?
3. Pourquoi supprimer les Linux capabilities inutiles ?
4. Pourquoi un système de fichiers en lecture seule peut-il empêcher une application de démarrer ?
5. Pourquoi les limites CPU et mémoire contribuent-elles à la sécurité ?

### Livrable M2
Manifeste corrigé et preuves démontrant que le processus ne tourne pas en root et que les contrôles demandés sont actifs.

---

# Mission 3 — RBAC et moindre privilège

**Durée indicative : 40 minutes — 3 points**

### Scénario
Un développeur PAYTECH doit pouvoir consulter les Pods du namespace `frontend`. Il ne doit ni supprimer des Pods, ni consulter les Secrets, ni administrer le cluster.

### Travail demandé
1. Créer un ServiceAccount `developer` dans `frontend`.
2. Créer un Role autorisant uniquement `get`, `list` et `watch` sur les Pods.
3. Créer un RoleBinding.
4. Tester les autorisations.

Tests attendus :

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:frontend:developer -n frontend

kubectl auth can-i delete pods \
  --as=system:serviceaccount:frontend:developer -n frontend

kubectl auth can-i get secrets \
  --as=system:serviceaccount:frontend:developer -n frontend
```

Résultats attendus : `yes`, `no`, `no`.

### Questions
1. Différencier authentification et autorisation.
2. Différencier Role et ClusterRole.
3. Pourquoi un Role est-il adapté à ce besoin ?
4. Quel serait l'impact d'un rôle `cluster-admin` attribué à ce développeur ?

### Livrable M3
Les trois manifestes (ServiceAccount, Role, RoleBinding) et les résultats des tests `can-i`.

---

# Mission 4 — Segmentation réseau

**Durée indicative : 45 minutes — 3 points**

### Scénario
L'équipe SSI constate que le frontend peut tenter de joindre directement PostgreSQL. Cette communication n'est pas nécessaire et doit être bloquée.

### Travail demandé
1. Vérifier que le CNI installé prend en charge les NetworkPolicies.
2. Observer les communications initiales.
3. Créer une NetworkPolicy dans `database`.
4. Autoriser uniquement les Pods `app=api` du namespace `backend` vers les Pods `app=postgres` sur TCP/5432.
5. Vérifier que le frontend ne peut plus accéder à PostgreSQL.
6. Vérifier que l'API backend conserve l'accès nécessaire.

Commandes de diagnostic :

```bash
kubectl get pods -A --show-labels
kubectl get networkpolicies -A
kubectl describe networkpolicy -n database database-restriction
```

Les tests de connectivité doivent être exécutés depuis des Pods de test temporaires. Ne pas installer de paquet dans les conteneurs applicatifs.

### Questions
1. Pourquoi la segmentation limite-t-elle les mouvements latéraux ?
2. Une NetworkPolicy fonctionne-t-elle sans CNI compatible ?
3. Quelle différence entre `podSelector` et `namespaceSelector` ?
4. Pourquoi faut-il vérifier les labels utilisés par les politiques ?

### Livrable M4
Manifeste NetworkPolicy, matrice des flux autorisés/refusés et preuves de tests.

---

# Mission 5 — Secrets et sécurité des images

**Durée indicative : 45 minutes — 3 points**

### Partie A — Secrets

1. Examiner le Secret `database-secret`.
2. Expliquer pourquoi Base64 n'est pas du chiffrement.
3. Identifier qui peut lire le Secret via RBAC.
4. Proposer les mesures adaptées : RBAC minimal, chiffrement au repos d'etcd, rotation, gestion externe des secrets si nécessaire.
5. Ne jamais committer de secret réel dans Git.

Commandes :

```bash
kubectl get secrets -n database
kubectl describe secret database-secret -n database
kubectl auth can-i get secrets -n database
```

### Partie B — Images

Analyser les images et les manifestes avec Trivy :

```bash
trivy image --severity HIGH,CRITICAL nginx:stable
trivy config 03-Laboratoire/
```

1. Relever les vulnérabilités pertinentes.
2. Distinguer vulnérabilité détectée et exploitabilité réelle.
3. Proposer une stratégie de mise à jour.
4. Éviter les tags flottants tels que `latest` ; préférer une version maîtrisée et, lorsque possible, un digest.
5. Expliquer comment intégrer le scan dans une pipeline CI/CD.

### Questions
1. Un Secret Kubernetes est-il chiffré par défaut dans etcd ?
2. Que protège le chiffrement au repos ?
3. Pourquoi scanner les images avant leur déploiement ?
4. Pourquoi un scan ne garantit-il pas l'absence de vulnérabilité ?

### Livrable M5
Compte rendu Trivy, analyse des risques et plan de protection des secrets.

---

# Mission 6 — Politique de sécurité et validation finale

**Durée indicative : 45 minutes — 2 points**

### Travail demandé
1. Appliquer le niveau `restricted` des Pod Security Standards au namespace `frontend`.
2. Identifier et corriger les incompatibilités.
3. Créer un ResourceQuota et un LimitRange.
4. Relancer les contrôles.
5. Vérifier que les applications fonctionnent toujours.

Exemple :

```bash
kubectl label namespace frontend \
  pod-security.kubernetes.io/enforce=restricted \
  --overwrite
```

Attention : le niveau `restricted` impose plusieurs exigences, notamment sur les privilèges, les capabilities, les utilisateurs et les profils seccomp. Vérifiez la conformité des Pods et non uniquement celle du manifeste.

### Questions
1. Quelle différence entre Pod Security Standards et RBAC ?
2. À quoi servent ResourceQuota et LimitRange ?
3. Pourquoi une politique de sécurité doit-elle être testée avant son déploiement global ?

### Livrable M6
Manifestes, preuves de conformité et synthèse de validation.

---

# 5. Incident final PAYTECH

**Durée : 90 minutes — inclus dans le temps de restitution ou en extension**

Le SOC reçoit une alerte concernant le Pod frontend. L'investigation révèle :
- un conteneur exécuté en root ;
- des permissions excessives ;
- une communication possible vers PostgreSQL ;
- un accès injustifié à des informations sensibles ;
- une image présentant des vulnérabilités.

### Votre mission
En équipe, vous devez :
1. qualifier les risques ;
2. prioriser les actions ;
3. corriger les configurations ;
4. vérifier les flux réseau ;
5. contrôler les autorisations ;
6. analyser les images ;
7. présenter les preuves de sécurisation.

**Restitution orale : 10 minutes par groupe.**

Votre présentation doit expliquer ce qui était vulnérable, pourquoi c'était dangereux, ce qui a été corrigé et comment vous avez vérifié la correction.

---

# 6. Livrables finaux

Chaque binôme remet :
- le tableau d'audit initial ;
- les manifestes YAML corrigés ;
- les résultats des tests RBAC ;
- la matrice des flux réseau ;
- le rapport Trivy ;
- les preuves Pod Security / ressources ;
- un rapport de synthèse avant/après ;
- une présentation orale.

## 7. Barème sur 20

| Critère | Points |
|---|---:|
| Audit et identification des vulnérabilités | 3 |
| Durcissement des conteneurs | 3 |
| RBAC et moindre privilège | 3 |
| NetworkPolicies | 3 |
| Secrets et sécurité des images | 3 |
| Pod Security et gestion des ressources | 2 |
| Tests, preuves et restitution | 3 |
| **Total** | **20** |

## 8. Critères de réussite

Un travail est considéré comme validé si :
- les constats sont expliqués et hiérarchisés ;
- les manifestes sont cohérents ;
- les permissions interdites sont effectivement refusées ;
- les flux réseau non autorisés sont bloqués ;
- les applications restent fonctionnelles ;
- les preuves sont reproductibles ;
- les limites des outils sont correctement expliquées.
