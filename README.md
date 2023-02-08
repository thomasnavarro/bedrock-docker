# Docker Blueprint - Bedrock

## Pré-requis
- [Docker](https://docs.docker.com/desktop/install/mac-install/)
- [Mkcert](https://github.com/FiloSottile/mkcert)

Installer mkcert :
```sh
$ brew install mkcert
$ brew install nss # si vous utilisez Firefox
```

## Configuration
### Variables d'environnement
<details>
<summary>1. Pour Docker (obligatoire)</summary>

Copiez `.env.example` dans la racine du projet vers `.env` et modifiez vos préférences.

Exemple :
```ini
COMPOSE_PROJECT_NAME="myapp"
DOMAIN="myapp.local"
DB_HOST="mysql" # nom du service docker
DB_NAME="myapp"
DB_ROOT_PASSWORD="password"
DB_TABLE_PREFIX="wp_"
```
</details>

<details>
<summary>2. Pour WordPress (obligatoire)</summary>

Modifiez `./src/.env.example` selon vos besoins. Lors de la commande `composer create-project` décrite ci-dessous, un `./src/.env` sera créé.

```ini
DB_NAME="myapp" # nom du service docker
DB_USER="root"
DB_PASSWORD="password"

# Optionally, you can use a data source name (DSN)
# When using a DSN, you can remove the DB_NAME, DB_USER, DB_PASSWORD, and DB_HOST variables
# DATABASE_URL="mysql://database_user:database_password@database_host:database_port/database_name"

# Optional variables
DB_HOST="mysql"
# DB_PREFIX="wp_"

WP_ENV="development"
WP_HOME="https://myapp.local"
WP_SITEURL="${WP_HOME}/wp"
WP_DEBUG_LOG=/path/to/debug.log

# Generate your keys here: https://roots.io/salts.html
AUTH_KEY="generateme"
SECURE_AUTH_KEY="generateme"
LOGGED_IN_KEY="generateme"
NONCE_KEY="generateme"
AUTH_SALT="generateme"
SECURE_AUTH_SALT="generateme"
LOGGED_IN_SALT="generateme"
NONCE_SALT="generateme"
```
</details>

### Utiliser HTTPS avec un domaine personnalisé
1.Créer un certificat SSL :
```sh
$ cd ./build/bin
$ sh create-cert.sh
```
Ce script va créer des certificats de développement de confiance en local. Il ne nécessite aucune configuration.

2.Assurez-vous que votre fichier `/etc/hosts` a un enregistrement pour les domaines utilisés.
```sh
$ sudo nano /etc/hosts
```

Ajoutez votre domaine comme ceci :
```ini
127.0.0.1   myapp.local
```

Continuez sur l'étape d'installation ci-dessous

## Installation

```sh
$ docker compose run --rm composer install
$ docker compose up -d
$ docker compose exec wordpress /srv/wordpress-install.sh
```

🚀 Cliquez sur le lien dans la console (du style https://myapp.local/b11ae1ee/f2a28f1584-492c743fef-59ceb1453a) ou ouvrez https://myapp.local dans votre navigateur !

## Services

### phpMyAdmin
phpMyAdmin est installé comme un service dans docker compose.

🚀 Ouvrez http://localhost:8082/ dans votre navigateur

### Mailhog
Mailhog est installé comme un service dans docker compose.

🚀 Ouvrez http://localhost:8025/ dans votre navigateur

Ajouter ceci dans votre thème pour que le service fonctionne correctement :

```php
add_action('phpmailer_init', function ($php_mailer) {
    $php_mailer->Host = 'mailhog';
    $php_mailer->Port = 1025;
    $php_mailer->IsSMTP();
}, 10);
```

## Outils
Pour ouvrir une session bash au conteneur wordpress :
```sh
$ docker compose exec wordpress bash
```

### Composer
```sh
# Met à jour les plugins/themes
$ docker compose run composer update
```

### WP-CLI
```sh
# Change les urls en bdd
$ docker compose exec wordpress bash
$ wp search-replace https://olddomain.com https://newdomain.com --allow-root
```

### Commandes utiles
Lorsque vous apportez des modifications au Dockerfile, utilisez :

```sh
$ docker compose up -d --force-recreate --build
```

Vous pouvez ajouter ses alias à votre `.bashrc` ou `.zshrc` : [Voir les alias](./build/bin/docker-aliases.sh)
