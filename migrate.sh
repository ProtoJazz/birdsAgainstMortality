#!/bin/sh
set -e

echo "Running database migrations..."
bin/birdsAgainstMortality eval "BirdsAgainstMortality.Release.migrate()"
echo "Migrations completed successfully!"