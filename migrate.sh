#!/bin/sh
set -e

echo "Running database migrations..."
bin/birds_against_mortality eval "BirdsAgainstMortality.Release.migrate"
echo "Migrations completed successfully!"

echo "Running database seeds..."
bin/birds_against_mortality eval "BirdsAgainstMortality.Release.seed"
echo "Seeds completed successfully!"