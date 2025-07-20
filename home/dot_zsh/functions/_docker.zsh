#!/bin/zsh
# Docker-related functions

# Docker compose up detached
dcu() {
    docker-compose up -d
}

# Docker compose down
dcd() {
    docker-compose down
}

# Docker compose logs
dcl() {
    local service="$1"
    if [[ -z "$service" ]]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$service"
    fi
}

# Docker compose restart
dcr() {
    local service="$1"
    if [[ -z "$service" ]]; then
        docker-compose restart
    else
        docker-compose restart "$service"
    fi
}

# Docker compose build
dcb() {
    local service="$1"
    if [[ -z "$service" ]]; then
        docker-compose build
    else
        docker-compose build "$service"
    fi
}

# Docker compose exec
dce() {
    local service="$1"
    local command="$2"
    if [[ -z "$service" ]] || [[ -z "$command" ]]; then
        echo "Usage: dce <service> <command>"
        return 1
    fi
    docker-compose exec "$service" "$command"
}

# Docker compose exec bash
dcb() {
    local service="$1"
    if [[ -z "$service" ]]; then
        echo "Usage: dcb <service>"
        return 1
    fi
    docker-compose exec "$service" bash
}

# Docker compose exec sh
dcs() {
    local service="$1"
    if [[ -z "$service" ]]; then
        echo "Usage: dcs <service>"
        return 1
    fi
    docker-compose exec "$service" sh
}

# Docker ps with format
dps() {
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
}

# Docker ps all with format
dpsa() {
    docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
}

# Docker images with format
dim() {
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
}

# Docker system prune
dsp() {
    docker system prune -f
}

# Docker system prune all
dspa() {
    docker system prune -a -f
}

# Docker volume prune
dvp() {
    docker volume prune -f
}

# Docker network prune
dnp() {
    docker network prune -f
}

# Docker container prune
dcp() {
    docker container prune -f
}

# Docker image prune
dip() {
    docker image prune -f
}

# Docker exec bash
deb() {
    local container="$1"
    if [[ -z "$container" ]]; then
        echo "Usage: deb <container>"
        return 1
    fi
    docker exec -it "$container" bash
}

# Docker exec sh
des() {
    local container="$1"
    if [[ -z "$container" ]]; then
        echo "Usage: des <container>"
        return 1
    fi
    docker exec -it "$container" sh
}

# Docker logs follow
dlf() {
    local container="$1"
    if [[ -z "$container" ]]; then
        echo "Usage: dlf <container>"
        return 1
    fi
    docker logs -f "$container"
}

# Docker logs tail
dlt() {
    local container="$1"
    local lines="${2:-100}"
    if [[ -z "$container" ]]; then
        echo "Usage: dlt <container> [lines]"
        return 1
    fi
    docker logs --tail="$lines" "$container"
}

# Docker stop all
dsa() {
    docker stop "$(docker ps -q)"
}

# Docker rm all stopped
dra() {
    docker rm "$(docker ps -aq)"
}

# Docker rmi all
dria() {
    docker rmi "$(docker images -q)"
}

# Docker build with tag
dbt() {
    local tag="$1"
    local path="${2:-.}"
    if [[ -z "$tag" ]]; then
        echo "Usage: dbt <tag> [path]"
        return 1
    fi
    docker build -t "$tag" "$path"
}

# Docker run interactive
dri() {
    local image="$1"
    if [[ -z "$image" ]]; then
        echo "Usage: dri <image>"
        return 1
    fi
    docker run -it "$image"
}

# Docker run detached
drd() {
    local image="$1"
    local name="$2"
    if [[ -z "$image" ]]; then
        echo "Usage: drd <image> [name]"
        return 1
    fi
    if [[ -n "$name" ]]; then
        docker run -d --name "$name" "$image"
    else
        docker run -d "$image"
    fi
}

# Docker inspect format
dif() {
    local container="$1"
    local format="$2"
    if [[ -z "$container" ]] || [[ -z "$format" ]]; then
        echo "Usage: dif <container> <format>"
        return 1
    fi
    docker inspect -f "$format" "$container"
}

# Docker stats
dst() {
    docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}"
}
