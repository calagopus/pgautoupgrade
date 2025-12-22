.PHONY: local attach before clean down server test up pushdev

local:
	docker build -f Dockerfile.alpine -t ghcr.io/calagopus/pgautoupgrade:local .

attach:
	docker exec -it pgauto /bin/bash

before:
	if [ ! -d "test/postgres-data" ]; then \
		mkdir test/postgres-data; \
	fi
	docker run --name pgauto -it --rm \
		--mount type=bind,source=$(abspath $(CURDIR))/test/postgres-data,target=/var/lib/postgresql/data \
		-e POSTGRES_PASSWORD=password \
		-e PGAUTO_DEVEL=before \
		ghcr.io/calagopus/pgautoupgrade:local

clean:
	docker image rm --force \
		ghcr.io/calagopus/pgautoupgrade:dev \
		ghcr.io/calagopus/pgautoupgrade:local
	docker image prune -f
	docker volume prune -f

down:
	docker container stop pgauto

server:
	if [ ! -d "test/postgres-data" ]; then \
		mkdir test/postgres-data; \
	fi
	docker run --name pgauto -it --rm --mount type=bind,source=$(abspath $(CURDIR))/test/postgres-data,target=/var/lib/postgresql/data \
		-e POSTGRES_PASSWORD=password \
		-e PGAUTO_DEVEL=server \
		ghcr.io/calagopus/pgautoupgrade:local

test:
	./test.sh

up:
	if [ ! -d "test/postgres-data" ]; then \
		mkdir test/postgres-data; \
	fi
	docker run --name pgauto -it --rm \
		--mount type=bind,source=$(abspath $(CURDIR))/test/postgres-data,target=/var/lib/postgresql/data \
		-e POSTGRES_PASSWORD=password \
		ghcr.io/calagopus/pgautoupgrade:local

pushdev:
	docker tag ghcr.io/calagopus/pgautoupgrade:local ghcr.io/calagopus/pgautoupgrade:dev
	docker push ghcr.io/calagopus/pgautoupgrade:dev
	docker image rm ghcr.io/calagopus/pgautoupgrade:dev
