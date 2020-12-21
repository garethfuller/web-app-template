#!/usr/bin/env bash

# Init submodules and update
git submodule init && git submodule update
echo "✅ Submodules initiated"

# Remove initial git remotes
git remote remove origin && (cd ./api && git remote remove origin) && (cd ./front && git remote remove origin)
echo "✅ Removed initial git remotes"

# Add new api git remote
echo "Input new api remote: (enter to skip)"
read api_remote
if [[ -z "$api_remote" ]]; then
  echo "🚫 Skipped setting api remote"
elif [[ -n "$api_remote" ]]; then
  (cd ./api && git remote add origin $api_remote)
  sed -i '' -e 's/# //g' ./api/.github/workflows/production.yml
  echo "✅ Set api git remote to: $api_remote"
fi

# Add new front git remote
echo "Input new front remote: (enter to skip)"
read front_remote
if [[ -z "$front_remote" ]]; then
  echo "🚫 Skipped setting front remote"
elif [[ -n "$front_remote" ]]; then
  (cd ./front && git remote add origin $front_remote)
  sed -i '' -e 's/# //g' ./front/.github/workflows/production.yml
  echo "✅ Set front git remote to: $front_remote"
fi

# Set rails app name
echo "Input rails app module name, e.g. AppName:"
read rails_app_name
sed -i '' -e "s/AppName/$rails_app_name/g" ./api/config/application.rb
echo "✅ Set rails app name to: $rails_app_name"

# Set K8s namespace
echo "Input new K8s namespace:"
read namespace
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/config/database.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/deployment.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./api/Dockerfile
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./front/deployment.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./front/Dockerfile
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./front/package.json
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./front/.github/workflows/production.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./front/.github/workflows/rollback.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/access.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/namespace.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/network.yml
sed -i '' -e "s/<NAMESPACE>/$namespace/g" ./infra/services.yml
echo "✅ Set K8s namespace to: $namespace"

# Set docker hub username
echo "Input DockerHub username:"
read docker_username
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./front/.github/workflows/production.yml
sed -i '' -e "s/<DOCKER_USERNAME>/$docker_username/g" ./front/.github/workflows/rollback.yml
echo "✅ Set DockerHub username to: $namespace"

# Set API domain
echo "Input API domain (e.g. api.app.com):"
read api_domain
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./api/.github/workflows/production.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./api/.github/workflows/rollback.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./front/deployment.yml
sed -i '' -e "s/<API_DOMAIN>/$api_domain/g" ./infra/network.yml
echo "✅ Set API domain to: $api_domain"

# Set front domain
echo "Input frontend domain (e.g. app.com):"
read front_domain
sed -i '' -e "s/<FRONT_DOMAIN>/$front_domain/g" ./front/.github/workflows/production.yml
sed -i '' -e "s/<FRONT_DOMAIN>/$front_domain/g" ./front/.github/workflows/rollback.yml
sed -i '' -e "s/<FRONT_DOMAIN>/$front_domain/g" ./infra/network.yml
sed -i '' -e "s/<FRONT_DOMAIN>/$front_domain/g" ./api/deployment.yml
echo "✅ Set frontend domain to: $front_domain"

# Build images
echo "Building docker images..."
docker-compose build
echo "✅ Images built"

# Setup dev database
echo "Setting up development database..."
docker-compose run -d db && docker-compose run api rails db:setup
echo "✅ Development database setup"

echo "🎉 Setup complete!"
echo "Run 'docker-compose up' and visit http://localhost:3000 in your browser"
