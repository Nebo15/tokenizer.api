#!/bin/sh
# `pwd` should be /opt/gateway_api
APP_NAME="gateway_api"

if [ "${APP_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "repo_tasks" migrate!
fi;

if [ "${APP_RUN_SEED}" == "true" ]; then
  echo "[WARNING] Seeding database!"
  ./bin/$APP_NAME command "repo_tasks" seed!
fi;
