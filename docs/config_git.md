### Connexion entre le VPS et gihtub

**Objectif**

>**Pouvoir cloner un repo git sur un VPS **


## 🔐 Configuration de Git avec une clé SSH GitHub

L’objectif de cette étape est de permettre au VPS de communiquer avec GitHub en SSH.

Cela permet ensuite de cloner un repository privé ou public avec une URL SSH du type :

```bash
git@github.com:username/repository.git
```

Cette méthode est plus propre qu’une authentification par mot de passe, car GitHub utilise une paire de clés SSH :

```txt
clé privée  → reste sur le VPS
clé publique → ajoutée sur GitHub
```

> ⚠️ La clé privée ne doit jamais être partagée, copiée dans un README, envoyée à quelqu’un ou pushée dans un repository Git.

---

## 1. Installer Git et OpenSSH

Sur le VPS, installer les paquets nécessaires :

```bash
sudo apt update
sudo apt install -y git openssh-client
```

Vérifier l’installation de Git :

```bash
git --version
```

Vérifier que le client SSH est disponible :

```bash
ssh -V
```

---

## 2. Configurer son identité Git

Configurer le nom utilisé dans les commits :

```bash
git config --global user.name "Votre Nom"
```

Configurer l’adresse email utilisée dans les commits :

```bash
git config --global user.email "votre-email@example.com"
```

Vérifier la configuration :

```bash
git config --global --list
```

Exemple de résultat attendu :

```txt
user.name=Votre Nom
user.email=votre-email@example.com
```

---

## 3. Vérifier les clés SSH existantes

Avant de créer une nouvelle clé, vérifier si une clé SSH existe déjà :

```bash
ls -la ~/.ssh
```

Si des fichiers comme ceux-ci existent déjà, une clé est peut-être déjà présente :

```txt
id_ed25519
id_ed25519.pub
id_rsa
id_rsa.pub
```

Les fichiers importants sont :

```txt
id_ed25519      → clé privée
id_ed25519.pub  → clé publique
```

---

## 4. Générer une nouvelle clé SSH

Générer une clé SSH de type `ed25519` :

```bash
ssh-keygen -t ed25519 -C "vps-github"
```

Le terminal demande ensuite où enregistrer la clé :

```txt
Enter file in which to save the key (/home/deploy/.ssh/id_ed25519):
```

Appuyer sur `Entrée` pour accepter l’emplacement par défaut.

Ensuite, le terminal demande une passphrase :

```txt
Enter passphrase:
```

Pour un usage manuel, il est recommandé d’utiliser une passphrase.

Pour un serveur de déploiement automatisé, il est possible de laisser vide, mais cela signifie que la sécurité dépend fortement de la sécurité du VPS.

---

## 5. Vérifier les permissions SSH

Appliquer des permissions propres sur le dossier `.ssh` :

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

Ces permissions signifient :

```txt
~/.ssh              → accessible uniquement par l’utilisateur
id_ed25519          → clé privée lisible uniquement par l’utilisateur
id_ed25519.pub      → clé publique lisible
```

---

## 6. Afficher la clé publique

Afficher la clé publique à copier sur GitHub :

```bash
cat ~/.ssh/id_ed25519.pub
```

Exemple de format :

```txt
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... vps-github
```

Il faut copier toute la ligne.

> ⚠️ Ne jamais copier le fichier `id_ed25519`.
>
> Il faut uniquement copier le fichier `id_ed25519.pub`.

---

## 7. Ajouter la clé SSH sur GitHub

Deux options sont possibles.

---

### Option A — Ajouter la clé au compte GitHub

Cette option permet au VPS d’accéder aux repositories autorisés par le compte GitHub.

Sur GitHub :

```txt
GitHub
→ Profile picture
→ Settings
→ SSH and GPG keys
→ New SSH key
```

Remplir les champs :

```txt
Title : VPS production
Key type : Authentication Key
Key : coller la clé publique
```

Puis cliquer sur :

```txt
Add SSH key
```

---

### Option B — Ajouter une Deploy Key au repository

Cette option est souvent plus propre pour un VPS de déploiement.

Elle permet de donner accès à un seul repository au lieu de donner accès au compte GitHub entier.

Sur GitHub :

```txt
Repository
→ Settings
→ Deploy keys
→ Add deploy key
```

Remplir les champs :

```txt
Title : VPS deploy key
Key : coller la clé publique
```

Si le VPS doit seulement cloner ou pull le repository, ne pas cocher :

```txt
Allow write access
```

Si cette option est cochée, le VPS pourra aussi push sur le repository.

Pour un serveur de production, il est recommandé d’utiliser une deploy key en lecture seule.

---

## 8. Tester la connexion SSH avec GitHub

Depuis le VPS :

```bash
ssh -T git@github.com
```

Lors de la première connexion, SSH peut demander de confirmer l’empreinte du serveur :

```txt
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Répondre :

```txt
yes
```

Si la connexion fonctionne, GitHub affiche un message du type :

```txt
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

Ce message est normal.

Il signifie que l’authentification SSH fonctionne.

---

## 9. Cloner le repository avec SSH

Sur GitHub, copier l’URL SSH du repository.

Elle ressemble à ceci :

```bash
git@github.com:username/repository.git
```

Puis, sur le VPS :

```bash
git clone git@github.com:username/repository.git
```

Exemple :

```bash
git clone git@github.com:votre-user/devops-vps-bootstrap.git
```

---

## 10. Vérifier le remote Git

Entrer dans le repository :

```bash
cd repository
```

Vérifier l’URL du remote :

```bash
git remote -v
```

Résultat attendu :

```txt
origin  git@github.com:username/repository.git (fetch)
origin  git@github.com:username/repository.git (push)
```

Si le remote commence par `git@github.com`, le repository utilise bien SSH.

---

## Résumé des commandes

```bash
sudo apt update
sudo apt install -y git openssh-client

git config --global user.name "Votre Nom"
git config --global user.email "votre-email@example.com"

ssh-keygen -t ed25519 -C "vps-github"

chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

cat ~/.ssh/id_ed25519.pub

ssh -T git@github.com

git clone git@github.com:username/repository.git
```

---

## Bonnes pratiques

* Générer la clé SSH avec l’utilisateur non-root, par exemple `deploy`.
* Ne jamais générer la clé GitHub depuis `root`, sauf cas particulier.
* Ne jamais partager la clé privée.
* Ne jamais push le dossier `.ssh`.
* Utiliser une deploy key si le VPS doit accéder à un seul repository.
* Utiliser une clé SSH de compte GitHub si le VPS doit accéder à plusieurs repositories.
* Tester la connexion SSH avant d’automatiser un déploiement.
