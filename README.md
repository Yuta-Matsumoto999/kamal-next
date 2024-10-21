## 概要

kamal2を利用して、VPS上にNext.jsをホスティングするためのテンプレートです。<br />
契約したVPS上に、kamalコマンドを用いてデプロイすることができます。<br />
1台のVPS上に、`staging`, `production` の環境を構築することができ、`github actions`での自動デプロイにも対応しています。<br />

## できること

- ローカル環境からVPSへデプロイする
- `staging`と`production`の環境を作成し、環境ごとにデプロイする
- `staging`環境に対して、Basic認証を設定する
- `github actions`から、環境ごとに自動デプロイを行う

## 前提条件

- VPSを契約済みである
- VPSにSSHで接続できる
  - キーペアを作成し、公開鍵をVPS上にアップロード済み
- ローカルにDockerがインストールされている
- dockerHubにアカウントを作成済み
- dockerHubの`Personal Access Token`を取得済み
- 取得済みのドメインがある
- DNSに適切な設定が済んでいる

### 参考

詳しい内容については、下記を参照ください。

※ 記事を作成中です...。

## 使い方

このリポジトリをforkしてからローカルにcloneしてください。

### デプロイ設定ファイルの編集

共通のデプロイ設定ファイルを編集します。`config/deploy.yml` をご自身の環境に合わせて編集してください。<br />

```
service: # 任意のサービス名

image: # DockerHubのイメージ (dockerHubアカウント名/イメージ名)

servers:
  web:
    - # VPSのIPアドレス

registry:
  username: # dockerHubアカウント名
  password:
    - KAMAL_REGISTRY_PASSWORD

builder:
  arch: amd64
```

次に、環境ごとのデプロイ設定ファイルを編集します。最初に`staging`環境の設定です。<br />
`config/deploy.staging.yml`を編集します。

```
image: # stg用のイメージ

proxy: 
  ssl: true
  host: # stg用のドメイン
  app_port: 3001
  healthcheck:
    interval: 3
    path: /api/up
    timeout: 3

builder:
  arch: amd64
  dockerfile: ./docker/staging/Dockerfile

env:
  secret:
    - BASIC_AUTH_DISABLED
    - BASIC_AUTH_USER
    - BASIC_AUTH_PASSWORD
```

次に、環境ごとのデプロイ設定ファイルを編集します。最初に`production`環境の設定です。<br />
`config/deploy.production.yml`を編集します。

```
image: # production用のイメージ

proxy: 
  ssl: true
  host: # 本番用ドメイン
  app_port: 3000
  healthcheck:
    interval: 3
    path: /api/up
    timeout: 3

builder:
  arch: amd64
  dockerfile: ./docker/production/Dockerfile
```

### 環境変数ファイルの作成

ルートディレクトリで下記を実行します。
```
touch ./kamal/secrets-common
```

環境変数を記述します。
```
KAMAL_REGISTRY_PASSWORD=[dockerHubの Personal Access Token]
BASIC_AUTH_DISABLED=false
BASIC_AUTH_USER=[Basic認証のユーザー名]
BASIC_AUTH_PASSWORD=[Basic認証のパスワード]
```

### kamalのsetup

Dockerを使ってセットアップします。下記のコマンドを順番に実行してください。

```
alias kamal='docker run -it --rm -v "${PWD}:/workdir" -v "/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock" -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal:latest'
```

```
kamal version
```

### 初回のデプロイ

```
kamal setup
```

これでVPS上に、VPS上にDockerがインストールされ、アプリケーションがデプロイされます。

### staging環境へのデプロイ

```
kamal deploy -d staging
```

`config/deploy.staging.yml`に記述された内容でデプロイが実行されます。

### production環境へのデプロイ

```
kamal deploy -d production
```

`config/deploy.production.yml`に記述された内容でデプロイが実行されます。

## github actionsの設定

下記のアクションをトリガーにデプロイが実行されます。

- `main`へのpush
  - `staging`へのデプロイが開始されます。
- `release`
  - `production`へのデプロイが開始されます。
- `pull_request`
  - testが実行されます。

### github secretsの設定

`Environments` を利用しています。<br />
下記の環境を作成し、環境変数を登録します。<br />
- `staging`
  - BASIC_AUTH_DISABLED : false
  - BASIC_AUTH_USER : [Basic認証のユーザー名]
  - BASIC_AUTH_PASSWORD : [Basic認証のパスワード]
  - KAMAL_REGISTRY_PASSWORD : [dockerHubの Personal Access Token]
  - SSH_PRIVATE_KEY : [SSHの秘密鍵]
- `production`
  - KAMAL_REGISTRY_PASSWORD : [dockerHubの Personal Access Token]
  - SSH_PRIVATE_KEY : [SSHの秘密鍵]

