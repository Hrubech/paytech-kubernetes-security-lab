# Préparation du laboratoire PAYTECH

## 1. Pré-requis

- Linux avec Docker opérationnel
- kubectl
- kind
- Trivy
- 4 vCPU, 8 Go RAM minimum (12 Go recommandés)

Vérifier :
```bash
docker version
kubectl version --client
kind version
trivy --version
```

## 2. Créer un cluster local

Créer un cluster Kind de base :
```bash
kind create cluster --name paytech
kubectl cluster-info --context kind-paytech
kubectl get nodes
```

**Important :** le réseau par défaut de Kind ne garantit pas l'application des NetworkPolicies. Pour la mission 4, installer un CNI compatible (par exemple Calico) en suivant la documentation officielle correspondant à la version de Kubernetes/Kind utilisée, ou utiliser un cluster de formation préconfiguré avec un CNI compatible. Vérifier ensuite le comportement réel par un test de connectivité.

Ne pas installer à l'aveugle un manifeste CNI d'une version non compatible. Préparer et valider l'environnement avant la séance.

## 3. Déployer l'état initial

Depuis le dossier `03-Laboratoire` :
```bash
kubectl apply -f 00-namespaces/
kubectl apply -f 01-vulnerable/
kubectl get pods -A
```

Les images peuvent prendre quelques minutes à télécharger.

## 4. Déployer les corrections

Les étudiants créent leurs propres manifestes corrigés à partir des constats et exigences de l'énoncé. Les solutions de référence ne sont pas distribuées dans ce dépôt public.

## 5. Nettoyage

```bash
kind delete cluster --name paytech
```

## 6. Dépannage

- Pod `ImagePullBackOff` : vérifier la connectivité au registre et le nom/tag d'image.
- Pod `CrashLoopBackOff` : consulter `kubectl logs` et `kubectl describe pod`.
- NetworkPolicy sans effet : vérifier le CNI et les labels.
- `kubectl auth can-i --as` refusé : vérifier les droits d'impersonation de l'utilisateur de test.
- Pod refusé après activation de `restricted` : examiner les événements et le SecurityContext.
