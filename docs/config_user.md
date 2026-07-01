### Configuration du user

**Objectif**

Créer un utilisateur non-root, lui donner les droits `sudo`, puis configurer sa connexion SSH par clé publique.

## 👤 Création d’un utilisateur non-root

Après la première connexion au VPS avec l’utilisateur `root`, il est recommandé de créer un utilisateur standard pour l’administration quotidienne du serveur.

Dans cet exemple, l’utilisateur créé s’appelle `deploy`.

### 1. Créer le nouvel utilisateur

```bash
adduser deploy
```

Cette commande crée un nouvel utilisateur Linux avec :

* un répertoire personnel dans `/home/deploy` ;
* un mot de passe ;
* une configuration utilisateur de base.

### 2. Ajouter l’utilisateur au groupe `sudo`

```bash
usermod -aG sudo deploy
```

Cette commande permet à l’utilisateur `deploy` d’exécuter des commandes administrateur avec `sudo`.

> L’option `-aG` signifie :
>
> * `-a` : append, ajoute l’utilisateur au groupe sans supprimer ses groupes existants ;
> * `-G` : indique le ou les groupes secondaires à ajouter.

### 3. Vérifier les groupes de l’utilisateur

```bash
groups deploy
```

Résultat attendu :

```txt
deploy : deploy sudo
```

La présence du groupe `sudo` confirme que l’utilisateur pourra exécuter des commandes administrateur.

### 4. Tester l’utilisateur

Changer temporairement d’utilisateur :

```bash
su - deploy
```

Puis tester les droits administrateur :

```bash
sudo whoami
```

Résultat attendu :

```txt
root
```

Si la commande retourne `root`, cela signifie que l’utilisateur `deploy` peut bien utiliser `sudo`.

---

## 🔐 Configuration SSH pour l’utilisateur non-root

Après avoir créé l’utilisateur, il faut lui permettre de se connecter au VPS en SSH avec une clé publique.

Dans notre cas, l’utilisateur `root` peut déjà se connecter en SSH. On va donc copier la clé publique autorisée de `root` vers le nouvel utilisateur `deploy`.

### 1. Vérifier que l’utilisateur existe

```bash
id deploy
```

Cette commande permet de vérifier que l’utilisateur `deploy` existe bien sur le système.

Résultat attendu :

```txt
uid=1000(deploy) gid=1000(deploy) groups=1000(deploy),27(sudo)
```

Le résultat peut varier légèrement selon la distribution, mais il doit bien afficher l’utilisateur `deploy`.

### 2. Créer le dossier `.ssh` de l’utilisateur

```bash
mkdir -p /home/deploy/.ssh
```

Le dossier `.ssh` contient les fichiers liés à l’authentification SSH de l’utilisateur.

L’option `-p` permet de créer le dossier uniquement s’il n’existe pas déjà.

### 3. Copier les clés autorisées de `root` vers l’utilisateur

```bash
cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
```

Cette commande copie le fichier `authorized_keys` de l’utilisateur `root` vers l’utilisateur `deploy`.

Le fichier `authorized_keys` contient les clés publiques autorisées à se connecter en SSH.

Grâce à cette copie, la même clé SSH utilisée pour se connecter en `root` pourra être utilisée pour se connecter avec l’utilisateur `deploy`.

### 4. Corriger le propriétaire du dossier `.ssh`

```bash
chown -R deploy:deploy /home/deploy/.ssh
```

Cette commande donne la propriété du dossier `.ssh` et de son contenu à l’utilisateur `deploy`.

C’est une étape obligatoire, car SSH refuse souvent la connexion si les fichiers SSH appartiennent au mauvais utilisateur.

### 5. Corriger les permissions obligatoires pour SSH

```bash
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

Ces permissions sont importantes pour la sécurité SSH :

* `700` sur le dossier `.ssh` signifie que seul l’utilisateur propriétaire peut lire, écrire et entrer dans ce dossier ;
* `600` sur le fichier `authorized_keys` signifie que seul l’utilisateur propriétaire peut lire et écrire dans ce fichier.

Si les permissions sont trop ouvertes, SSH peut refuser la connexion avec une erreur du type :

```txt
Permission denied (publickey)
```

### 6. Tester la connexion SSH avec l’utilisateur non-root

Depuis la machine locale, tester la connexion :

```bash
ssh deploy@xx.xx.xx.xxx
```

Si tout est correctement configuré, la connexion doit fonctionner sans passer par l’utilisateur `root`.

### 7. Configuration SSH locale recommandée

Sur la machine locale, il est recommandé d’ajouter une entrée propre dans le fichier :

```bash
~/.ssh/config
```

Exemple :

```sshconfig
Host {Name_config}
    HostName {IP_VPS}
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

Ensuite, la connexion peut se faire avec :

```bash
ssh {Name_config}
```

Cette configuration est aussi celle qui pourra être utilisée par VS Code Remote SSH.

---

## ✅ Bonnes pratiques

Une fois l’utilisateur non-root créé, testé et configuré avec SSH, il est recommandé de :

* se connecter au VPS avec cet utilisateur plutôt qu’avec `root` ;
* utiliser `sudo` uniquement lorsque des droits administrateur sont nécessaires ;
* vérifier que la connexion SSH fonctionne avec l’utilisateur non-root avant de modifier l’accès `root` ;
* garder l’utilisateur `root` réservé aux opérations critiques ou au bootstrap initial du serveur ;
* éviter de désactiver l’accès `root` tant que la connexion avec l’utilisateur non-root n’a pas été testée avec succès.

## 🧪 Commandes récapitulatives

À exécuter en étant connecté en `root` sur le VPS :

```bash
id deploy

mkdir -p /home/deploy/.ssh

cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys

chown -R deploy:deploy /home/deploy/.ssh

chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

Puis, depuis la machine locale :

```bash
ssh deploy@xx.xx.xx.xx.xx
```
