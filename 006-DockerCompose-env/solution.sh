#!/bin/bash


set -e

# Loop over all .env* files in the current directory and run docker compose with each
for envfile in .env*; do
	if [[ -f "$envfile" ]]; then
		# Extract PORT from the env file (ignore comments and blank lines)
		PORT=$(grep -E '^PORT=' "$envfile" | head -n1 | cut -d'=' -f2 | tr -d '"')
        
		if [[ -n "$PORT" ]]; then
            echo ""
            echo ""
            echo ""
            echo "Using PORT: $PORT from $envfile"
            # Print the URL to access the service
			echo "Open: http://localhost:$PORT (from $envfile)"
		else
			echo "No PORT found in $envfile, skipping URL echo."
		fi
	echo "Running docker compose with $envfile"
	# Export env vars from file and run docker-compose (v1 compatible)
	set -a
	source "$envfile"
	set +a
	docker-compose up --build --remove-orphans -d
	echo "Started containers for $envfile in background."
	# Optionally, print running containers for this env
	docker-compose ps
	fi
done
