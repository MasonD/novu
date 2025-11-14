#1/usr/bin/env bash

for SERVICE_NAME in "api" "worker"
do

  cp scripts/dotenvcreate.mjs apps/$SERVICE_NAME/src/dotenvcreate.mjs
  cd apps/$SERVICE_NAME

  if [ "$SERVICE_NAME" == "worker" ]; then
    cd src/ && grep -q "IS_SELF_HOSTED" .example.env || echo -e "\nIS_SELF_HOSTED=true" >> .example.env && cd ..
  elif [ "$SERVICE_NAME" == "dashboard" ]; then
    echo -e "\nVITE_SELF_HOSTED=true" >> .env
  fi

  # Switch from PM2 cluster mode to single node process for open source builds
  if [[ "$SERVICE_NAME" =~ ^(api|worker|webhook|ws)$ ]]; then
    echo "Switching $SERVICE_NAME from PM2 cluster mode to single node process for open source"
    sed -i.bak 's/pm2-runtime start dist\/main\.js -i max/node dist\/main.js/g' Dockerfile && rm -f Dockerfile.bak
  fi

  pnpm run docker:build
  cd ../..
done
