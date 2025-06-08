Summary of Commands / docker Command Description
docker-compose down	# Stop and remove containers and networks.
docker-compose down --volumes	# Stop and remove containers, networks, and volumes.
docker image prune -f	# Remove dangling images.
docker system prune -a --volumes	# Remove all unused Docker resources (full cleanup).
docker ps	# List running containers.
docker ps -a	# List all containers.
docker volume ls	# List all volumes.
docker network ls	# List all networks.