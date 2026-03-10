# Situation_Pro_2

## Sommaire

- [Présentation du besoin métier](#présentation-du-besoin-métier)
- [Présentation de l'architecture](#présentation-de-l'architecture)
- [Modélisation UML](#modélisation-uml)
- [Modélisation de la base de données](#modélisation-de-la-base-bdd)
- [Plan de sauvegarde de la base de données](#plan-sauvegarde-bdd)
- [Maquette](#maquette)


## Présentation du besoin métier

### Contexte

WoodyCraft est une entreprise qui vend des puzzles en ligne. Elle dispose déjà d'une application web (SP1) et souhaite aujourd'hui se doter d'une **application mobile d'administration** pour piloter son activité au quotidien.

### Problématique

L'administrateur de WoodyCraft n'a actuellement **aucun outil mobile** pour gérer les commandes, le catalogue et les stocks en temps réel. Cela ralentit les opérations et peut entraîner des erreurs (ruptures de stock non détectées, commandes non traitées, etc.).

### Objectif

Développer une **application mobile administrative** permettant à l'administrateur de gérer efficacement :

- Les commandes clients
- Le catalogue de puzzles
- Les niveaux de stock

### Acteurs

Administrateur : Utilisateur principal de l'application
Client : Passe des commandes via l'application web existante 
Système : API RESTful partagée avec l'application web

### Besoins fonctionnels

#### Gestion du catalogue
- Ajouter, modifier et supprimer des puzzles
- Mettre à jour les informations : prix, description, image

#### Gestion des commandes
- Consulter les commandes en attente
- Valider, marquer comme expédiée ou supprimer une commande
- Voir le détail d'une commande (articles, adresse, paiement)

#### Gestion des stocks
- Visualiser les niveaux de stock par puzzle
- Modifier les quantités
- Recevoir des alertes en cas de stock bas

#### Authentification
- Accès sécurisé réservé aux administrateurs autorisés

####  Tableau de bord
- Vue centralisée : commandes en attente, alertes stock, statistiques de ventes

### Contraintes techniques

- Application développée à partir d'une **base existante** fournie par le professeur
- Accès aux données via une **API RESTful** partagée avec l'app web
- Base de données **commune** avec la SP1
- Versioning via **GitLab**

### Bénéfices attendus

- Gain de temps dans le traitement des commandes
- Meilleure visibilité sur les stocks en temps réel
- Réduction des erreurs de gestion
- Pilotage de l'activité depuis n'importe où via mobile