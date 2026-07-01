# Gestion du SWAP sur un petit VPS Linux

## Objectif

Comprendre les problèmes de mémoire RAM sur un petit VPS, savoir ce qu’est le SWAP, pourquoi il est utile, et comment le configurer correctement.

Ce document est particulièrement utile pour les petits VPS avec peu de mémoire, par exemple :

```txt
1 Go RAM
2 Go RAM
4 Go RAM
```

Sur ce type de machine, certains outils comme Docker, VS Code Remote-SSH, Node.js, Ansible, Git, ou des services web peuvent rapidement consommer beaucoup de mémoire.

---

# 1. Comprendre le problème de RAM sur un petit VPS

Un VPS dispose d’une quantité limitée de mémoire vive appelée RAM.

La RAM est utilisée par :

* le système Linux ;
* les services système ;
* SSH ;
* Docker ;
* les conteneurs ;
* les bases de données ;
* les serveurs web ;
* VS Code Remote-SSH ;
* les processus Node.js, Python, PHP, etc.

Sur un petit VPS, la RAM peut se remplir très rapidement.

Exemple sur un VPS avec 2 Go de RAM :

```txt
MiB Mem :   1958.0 total,    286.1 free,   1420.9 used,    250.9 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.    330.2 avail Mem
```

Ici, le VPS possède environ 2 Go de RAM, mais seulement environ 330 Mo sont réellement disponibles.

Le problème important est :

```txt
Swap: 0
```

Cela signifie que le serveur n’a aucun espace de secours si la RAM est pleine.

---

# 2. Symptômes d’un VPS qui manque de mémoire

Quand un VPS manque de RAM, on peut observer plusieurs symptômes :

* le terminal SSH devient lent ;
* VS Code Remote-SSH met beaucoup de temps à répondre ;
* les commandes prennent du temps à s’exécuter ;
* Docker devient lent ;
* les conteneurs crashent ;
* le serveur peut tuer automatiquement certains processus ;
* des erreurs apparaissent dans les logs ;
* le VPS peut devenir difficile à administrer.

Exemples d’erreurs possibles :

```txt
Killed
```

```txt
Out of memory
```

```txt
Cannot allocate memory
```

```txt
Permission denied (publickey)
```

L’erreur `Permission denied (publickey)` n’est pas directement liée au manque de RAM, mais elle peut apparaître pendant des phases de mauvaise configuration SSH. Le manque de RAM concerne surtout les lenteurs, les processus tués, ou les services instables.

---

# 3. Vérifier l’état de la RAM

Pour afficher l’état de la mémoire :

```bash
free -h
```

Exemple :

```txt
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.4Gi       286Mi        20Mi       250Mi       330Mi
Swap:             0B          0B          0B
```

Les colonnes importantes sont :

| Colonne      | Signification                       |
| ------------ | ----------------------------------- |
| `total`      | mémoire totale disponible           |
| `used`       | mémoire utilisée                    |
| `free`       | mémoire totalement libre            |
| `buff/cache` | mémoire utilisée par le cache Linux |
| `available`  | mémoire réellement disponible       |
| `Swap`       | espace de swap disponible           |

La valeur la plus importante à regarder est souvent :

```txt
available
```

Si `available` est très bas, par exemple moins de 200 ou 300 Mo sur un VPS de 2 Go, le système peut commencer à ralentir.

---

# 4. Vérifier la charge du serveur

Pour vérifier la charge globale du VPS :

```bash
uptime
```

Exemple :

```txt
12:55:18 up 1:00, 1 user, load average: 0.47, 1.13, 1.14
```

Le `load average` représente la charge moyenne du système.

Sur un VPS avec 1 vCPU :

```txt
load average supérieur à 1.00 = serveur potentiellement chargé
```

Sur un VPS avec 2 vCPU :

```txt
load average supérieur à 2.00 = serveur potentiellement chargé
```

Pour voir les processus en direct :

```bash
top
```

ou :

```bash
htop
```

Si `htop` n’est pas installé :

```bash
sudo apt update
sudo apt install htop -y
```

---

# 5. Identifier les processus qui consomment la RAM

Afficher les processus qui consomment le plus de mémoire :

```bash
ps aux --sort=-%mem | head -15
```

Afficher les processus qui consomment le plus de CPU :

```bash
ps aux --sort=-%cpu | head -15
```

Exemple de processus lourds :

```txt
.vscode-server
node
docker
mysqld
postgres
php-fpm
MainThread
typescript-language-server
eslint
```

Avec VS Code Remote-SSH, il est fréquent de voir plusieurs processus Node.js ou `MainThread` consommer beaucoup de mémoire.

---

# 6. Qu’est-ce que le SWAP ?

Le SWAP est un espace sur le disque utilisé comme mémoire de secours.

Quand la RAM est presque pleine, Linux peut déplacer temporairement certaines données de la RAM vers le SWAP.

On peut voir le SWAP comme une extension de secours de la mémoire.

## RAM vs SWAP

| Élément | Vitesse     | Rôle                          |
| ------- | ----------- | ----------------------------- |
| RAM     | très rapide | mémoire principale            |
| SWAP    | plus lent   | mémoire de secours sur disque |

Le SWAP est donc beaucoup plus lent que la RAM, mais il permet d’éviter que le système plante quand la RAM est pleine.

---

# 7. Pourquoi ajouter du SWAP sur un petit VPS ?

Sur un petit VPS, le SWAP permet de :

* éviter les crashs liés au manque de mémoire ;
* éviter que Linux tue des processus importants ;
* stabiliser Docker ;
* améliorer la stabilité de VS Code Remote-SSH ;
* garder un accès SSH plus fiable ;
* absorber les pics temporaires de mémoire.

Le SWAP ne remplace pas une vraie augmentation de RAM.

Si le VPS utilise constamment le SWAP, cela signifie que la machine manque réellement de mémoire.

Mais pour un petit VPS, avoir 1 à 2 Go de SWAP est souvent une bonne pratique.

---

# 8. Taille recommandée du SWAP

Recommandation simple pour un VPS :

| RAM du VPS | Swap recommandé |
| ---------- | --------------- |
| 1 Go RAM   | 1 à 2 Go swap   |
| 2 Go RAM   | 2 Go swap       |
| 4 Go RAM   | 2 à 4 Go swap   |
| 8 Go RAM   | 2 à 4 Go swap   |

Pour un petit VPS de 2 Go utilisé avec Docker ou VS Code Remote-SSH, une bonne valeur est :

```txt
2 Go de SWAP
```

---

# 9. Créer un fichier SWAP de 2 Go

Les commandes suivantes créent un fichier de swap de 2 Go.

À exécuter sur le VPS :

```bash
sudo fallocate -l 2G /swapfile
```

Cette commande crée un fichier vide de 2 Go à l’emplacement :

```txt
/swapfile
```

Corriger les permissions :

```bash
sudo chmod 600 /swapfile
```

Cette permission est obligatoire pour la sécurité. Seul `root` doit pouvoir lire et écrire ce fichier.

Transformer le fichier en espace SWAP :

```bash
sudo mkswap /swapfile
```

Activer le SWAP :

```bash
sudo swapon /swapfile
```

Vérifier :

```bash
free -h
```

ou :

```bash
swapon --show
```

Résultat attendu :

```txt
NAME      TYPE  SIZE USED PRIO
/swapfile file    2G   0B   -2
```

---

# 10. Rendre le SWAP permanent

Après un redémarrage, le SWAP doit être automatiquement réactivé.

Pour cela, il faut ajouter le fichier SWAP dans `/etc/fstab`.

Commande :

```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Vérifier que la ligne a bien été ajoutée :

```bash
cat /etc/fstab
```

Tu dois voir une ligne comme :

```txt
/swapfile none swap sw 0 0
```

---

# 11. Commandes complètes pour créer un SWAP de 2 Go

Version complète :

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Puis vérifier :

```bash
free -h
swapon --show
```

---

# 12. Régler le comportement du SWAP avec `swappiness`

Linux possède un paramètre appelé `swappiness`.

Ce paramètre indique à quel point le système est prêt à utiliser le SWAP.

Valeur possible :

```txt
0 à 100
```

Plus la valeur est haute, plus Linux utilise facilement le SWAP.

Plus la valeur est basse, plus Linux préfère garder les données en RAM.

Voir la valeur actuelle :

```bash
cat /proc/sys/vm/swappiness
```

Sur un serveur, une valeur raisonnable est souvent :

```txt
10
```

Cela signifie :

```txt
Utilise le SWAP seulement quand c’est vraiment nécessaire.
```

Changer temporairement la valeur :

```bash
sudo sysctl vm.swappiness=10
```

Rendre le réglage permanent :

```bash
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

Appliquer :

```bash
sudo sysctl -p
```

Vérifier :

```bash
cat /proc/sys/vm/swappiness
```

---

# 13. Régler la pression sur le cache avec `vfs_cache_pressure`

Linux utilise aussi de la mémoire pour le cache du système de fichiers.

Le paramètre `vfs_cache_pressure` influence la manière dont Linux libère ce cache.

Voir la valeur actuelle :

```bash
cat /proc/sys/vm/vfs_cache_pressure
```

Valeur par défaut fréquente :

```txt
100
```

Pour un petit VPS, on peut garder cette valeur par défaut.

Il n’est pas nécessaire de modifier ce paramètre au début.

---

# 14. Vérifier si le SWAP est utilisé

Commande :

```bash
free -h
```

Exemple :

```txt
Swap:          2.0Gi       120Mi       1.9Gi
```

Ou :

```bash
swapon --show
```

Exemple :

```txt
NAME      TYPE SIZE USED PRIO
/swapfile file   2G 120M   -2
```

Si le SWAP est utilisé légèrement, ce n’est pas grave.

Si le SWAP est utilisé massivement en permanence, par exemple :

```txt
Swap utilisé : 1.8G / 2G
```

alors le VPS manque vraiment de RAM.

Dans ce cas, il faut envisager :

* réduire les services ;
* couper des extensions VS Code Remote ;
* arrêter des conteneurs Docker ;
* augmenter la taille du VPS ;
* passer à 4 Go de RAM minimum.

---

# 15. Supprimer un SWAP

Si tu veux supprimer le SWAP :

Désactiver le SWAP :

```bash
sudo swapoff /swapfile
```

Supprimer le fichier :

```bash
sudo rm /swapfile
```

Éditer `/etc/fstab` :

```bash
sudo nano /etc/fstab
```

Supprimer la ligne :

```txt
/swapfile none swap sw 0 0
```

Vérifier :

```bash
free -h
swapon --show
```

---

# 16. Modifier la taille du SWAP

Pour passer de 2 Go à 4 Go, il vaut mieux recréer le fichier.

Désactiver l’ancien SWAP :

```bash
sudo swapoff /swapfile
```

Supprimer l’ancien fichier :

```bash
sudo rm /swapfile
```

Créer un nouveau fichier de 4 Go :

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Vérifier :

```bash
free -h
swapon --show
```

Si la ligne `/etc/fstab` existe déjà, il n’est pas nécessaire de la rajouter.

---

# 17. Cas particulier : VS Code Remote-SSH

VS Code Remote-SSH peut être très gourmand sur un petit VPS.

Quand on se connecte avec VS Code, un serveur distant est installé dans :

```txt
~/.vscode-server
```

Ce serveur peut lancer plusieurs processus :

```txt
node
.vscode-server
typescript-language-server
eslint
MainThread
```

Sur un VPS de 2 Go, ces processus peuvent consommer plusieurs centaines de Mo, voire plus d’1 Go.

Pour voir ces processus :

```bash
ps aux | grep -E "vscode|code-|MainThread" | grep -v grep
```

Pour nettoyer le serveur VS Code distant :

```bash
rm -rf ~/.vscode-server
rm -rf ~/.vscode-remote
```

Si des anciens serveurs VS Code tournent avec l’utilisateur `root` :

```bash
sudo rm -rf /root/.vscode-server
sudo rm -rf /root/.vscode-remote
```

Pour tuer les processus VS Code Remote :

```bash
pkill -f ".vscode-server"
```

Ou pour tuer ceux lancés par `root` :

```bash
sudo pkill -u root -f ".vscode-server"
sudo pkill -u root -f "code-"
```

---

# 18. Cas particulier : Docker

Docker peut aussi consommer beaucoup de RAM, surtout avec :

* bases de données ;
* WordPress ;
* Nginx ;
* PHP-FPM ;
* Redis ;
* PostgreSQL ;
* MySQL/MariaDB ;
* Elasticsearch ;
* containers Node.js.

Voir les conteneurs actifs :

```bash
docker ps
```

Voir leur consommation :

```bash
docker stats
```

Voir l’espace disque utilisé par Docker :

```bash
docker system df
```

Nettoyage prudent :

```bash
docker system prune
```

Attention : cette commande supprime les objets Docker non utilisés.

---

# 19. Bonnes pratiques pour un petit VPS

Pour un VPS de 1 à 2 Go de RAM :

* ajouter 1 à 2 Go de SWAP ;
* éviter de lancer trop de conteneurs Docker ;
* éviter VS Code Remote-SSH en permanence ;
* coder plutôt en local et déployer ensuite ;
* surveiller régulièrement `free -h` ;
* surveiller les processus avec `top` ou `htop` ;
* éviter les extensions VS Code Remote inutiles ;
* redémarrer les services trop gourmands si nécessaire ;
* augmenter la taille du VPS si le swap est constamment utilisé.

---

# 20. Commandes de diagnostic rapides

Afficher la mémoire :

```bash
free -h
```

Afficher le SWAP :

```bash
swapon --show
```

Afficher la charge :

```bash
uptime
```

Afficher les processus en direct :

```bash
top
```

ou :

```bash
htop
```

Afficher les plus gros consommateurs de RAM :

```bash
ps aux --sort=-%mem | head -15
```

Afficher les plus gros consommateurs de CPU :

```bash
ps aux --sort=-%cpu | head -15
```

Afficher l’espace disque :

```bash
df -h
```

Afficher les inodes :

```bash
df -ih
```

---

# 21. Résumé simple

La RAM est la mémoire rapide du VPS.

Le SWAP est une mémoire de secours stockée sur le disque.

Sans SWAP, un petit VPS peut devenir instable quand la RAM est pleine.

Avec un SWAP de 2 Go, un VPS de 2 Go devient plus stable, surtout avec Docker ou VS Code Remote-SSH.

Cependant, le SWAP est plus lent que la RAM.

Donc :

```txt
SWAP = sécurité et stabilité
RAM = performance
```

Si le serveur utilise constamment beaucoup de SWAP, il faut augmenter les ressources du VPS.

---

# 22. Installation recommandée pour un petit VPS

Pour un VPS de 2 Go de RAM :

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Vérification finale :

```bash
free -h
swapon --show
cat /proc/sys/vm/swappiness
```

Résultat attendu :

```txt
Swap disponible : environ 2 Go
Swappiness : 10
```

Le VPS est maintenant mieux protégé contre les ralentissements et les crashs liés au manque de mémoire.
