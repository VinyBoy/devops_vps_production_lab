### Configuration du user

**Objectif**

Créer un utilisateur non-root

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

### 5. Bonnes pratiques

Une fois l’utilisateur non-root créé et testé, il est recommandé de :

* se connecter au VPS avec cet utilisateur plutôt qu’avec `root` ;
* configurer une clé SSH pour cet utilisateur ;
* vérifier que la connexion SSH fonctionne avant de désactiver l’accès direct à `root`.

L’utilisateur `root` doit rester réservé aux opérations critiques ou au bootstrap initial du serveur.
