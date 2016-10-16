#!/bin/sh
# `pwd` should be /opt/tokenizer_api
APP_NAME="tokenizer_api"

if [ "${APP_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "${APP_NAME}_tasks" migrate!
fi;

if [ "${APP_RUN_SEED}" == "true" ]; then
  echo "[WARNING] Seeding database!"
  ./bin/$APP_NAME command "${APP_NAME}_tasks" seed!
fi;
