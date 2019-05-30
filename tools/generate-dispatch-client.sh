#!/usr/bin/env bash

# Start services so we can fetch OpenAPI schema
(cd ../ && docker-compose up -d nsqd redis dispatch)
sleep 3

# Generate client
docker run --network=host --rm -v "${PWD}/../":/local openapitools/openapi-generator-cli generate -i http://localhost:3001 -g typescript-node -o /local/shared/dispatch-client

# Stop services
(cd ../ && docker-compose down)

# Patch errors in generated client code
(find ../shared -name "*.ts" -type f -print0 | xargs -0 sed -i '' 's/ClientResponse/ServerResponse/g')
(find ../shared -name "*.ts" -type f -print0 | xargs -0 sed -i '' "s/import Promise = require('bluebird');//g")
echo "Dispatch Client Generated!"

# Copy contents of shared folder into all services
./sync-shared.sh
