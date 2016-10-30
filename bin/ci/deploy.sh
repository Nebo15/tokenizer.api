#!/bin/bash
# Deploy container to a Heroku.
# You need to specify $HEROKU_API_KEY before using this script.

# Find mix.exs inside project tree.
# This allows to call bash scripts within any folder inside project.
PROJECT_DIR=$(git rev-parse --show-toplevel)
if [ ! -f "${PROJECT_DIR}/mix.exs" ]; then
    echo "[E] Can't find '${PROJECT_DIR}/mix.exs'."
    echo "    Check that you run this script inside git repo or init a new one in project root."
fi

# Extract project name and version from mix.exs
PROJECT_NAME=$(sed -n 's/.*app: :\([^, ]*\).*/\1/pg' "${PROJECT_DIR}/mix.exs")
PROJECT_VERSION=$(sed -n 's/.*@version "\([^"]*\)".*/\1/pg' "${PROJECT_DIR}/mix.exs")

echo "Logging in into Heroku";
heroku plugins:install heroku-container-registry
heroku login
heroku container:login

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  if [ "$TRAVIS_BRANCH" == "$RELEASE_BRANCH" ]; then
    docker tag "${PROJECT_NAME}:${PROJECT_VERSION}" "registry.heroku.com/${PROJECT_NAME}/web"
  fi;

  if [[ "$MAIN_BRANCHES" =~ "$TRAVIS_BRANCH" ]]; then
    docker push "registry.heroku.com/${PROJECT_NAME}/web"
  fi;
fi;
