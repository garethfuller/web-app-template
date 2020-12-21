#!/usr/bin/env bash

# Init submodules and update
git submodule init && git submodule update
echo "✅ Submodules initiated\n"

# Remove initial git remotes
git remote remove origin && (cd ./api && git remote remove origin) && (cd ./web && git remote remove origin)
echo "✅ Removed initial git remotes\n"

# Add new app git remote
echo "Input new app remote: (enter to skip)"
read app_remote
if [[ -z "$app_remote" ]]; then
  echo "🚫 Skipped setting app remote\n"
elif [[ -n "$app_remote" ]]; then
  git remote add origin $app_remote
  echo "✅ Set app git remote to: $app_remote\n"
fi

# Add new api git remote
echo "Input new api remote: (enter to skip)"
read api_remote
if [[ -z "$api_remote" ]]; then
  echo "🚫 Skipped setting api remote\n"
elif [[ -n "$api_remote" ]]; then
  (cd ./api && git remote add origin $api_remote)
  sed -i '' -e 's/# //g' ./api/.github/workflows/production.yml
  echo "✅ Set api git remote to: $api_remote\n"
fi

# Add new web git remote
echo "Input new web remote: (enter to skip)"
read web_remote
if [[ -z "$web_remote" ]]; then
  echo "🚫 Skipped setting web remote\n"
elif [[ -n "$web_remote" ]]; then
  (cd ./web && git remote add origin $web_remote)
  sed -i '' -e 's/# //g' ./web/.github/workflows/production.yml
  echo "✅ Set web git remote to: $web_remote\n"
fi

# Set rails app name
echo "Input rails app module name, e.g. AppName:"
read rails_app_name
sed -i '' -e "s/AppName/$rails_app_name/g" ./api/config/application.rb
echo "✅ Set rails app name to: $rails_app_name\n"

# Set K8s namespace
echo "Input new K8s namespace:"
read namespace
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/config/database.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/deployment.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/Dockerfile
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./web/deployment.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./web/Dockerfile
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./web/package.json
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./web/.github/workflows/production.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./web/.github/workflows/rollback.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/access.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/namespace.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/network.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/services.yml
echo "✅ Set K8s namespace to: $namespace\n"

# Set docker hub username
echo "Input DockerHub username:"
read docker_username
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./web/.github/workflows/production.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./web/.github/workflows/rollback.yml
echo "✅ Set DockerHub username to: $docker_username\n"

# Set API domain
echo "Input API domain (e.g. api.app.com):"
read api_domain
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./web/deployment.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./infra/network.yml
echo "✅ Set API domain to: $api_domain\n"

# Set web domain
echo "Input web domain (e.g. app.com):"
read web_domain
sed -i '' -e "s/<WEB_DOMAIN>/$web_domain/g" ./web/.github/workflows/production.yml
sed -i '' -e "s/<WEB_DOMAIN>/$web_domain/g" ./web/.github/workflows/rollback.yml
sed -i '' -e "s/<WEB_DOMAIN>/$web_domain/g" ./infra/network.yml
sed -i '' -e "s/<WEB_DOMAIN>/$web_domain/g" ./api/deployment.yml
echo "✅ Set web domain to: $web_domain\n"

# Build images
echo "Building docker images..."
docker-compose build
echo "✅ Images built\n"

# Setup dev database
echo "Setting up development database..."
docker-compose run api rails db:setup
echo "✅ Development database setup\n"

echo "🎉 Setup complete!"
echo "Run 'docker-compose up' and visit http://localhost:3000 in your browser"
