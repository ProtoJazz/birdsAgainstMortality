#!/bin/sh
set -e

echo "Running database migrations..."
bin/birds_against_mortality eval "BirdsAgainstMortality.Release.migrate()"
echo "Migrations completed successfully!"