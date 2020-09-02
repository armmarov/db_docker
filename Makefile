.PHONY: mysql postgres mongo

all: network mysql postgres mongo pgadmin phpmyadmin rabbitmq

createdir:
	mkdir -p mysql/datadir && mkdir -p postgres/data && mkdir -p mongo/db
	cp config/mysql/my.cnf mysql/my.cnf

network:
	docker network create -d bridge dbnet

mysql:
	#username: root, password: docker
	docker run --name=mysql-cont --restart on-failure \
	-e MYSQL_ROOT_PASSWORD=docker \
   	--mount type=bind,src=${PWD}/mysql/my.cnf,dst=/etc/my.cnf \
   	--mount type=bind,src=${PWD}/mysql/datadir,dst=/var/lib/mysql \
	--net="dbnet" \
	-d -p 3306:3306 mysql/mysql-server:latest

mysql_cli:
	docker exec -it mysql-cont mysql -udocker -p
	#ALTER USER 'root'@'localhost' IDENTIFIED BY 'docker';
	#ALTER USER 'docker'@'%' IDENTIFIED BY 'docker';

postgres:
	#username: postgres, password: docker
	docker run --name pg-cont --restart on-failure \
	-e POSTGRES_PASSWORD=docker -d -p 5432:5432 \
	-v $(PWD)/postgres/data:/var/lib/postgresql/data \
	--net="dbnet" \
	postgres:latest

postgres_cli:
	docker exec -it pg-cont psql -h localhost -U postgres -d postgres

mongo:
	docker run --name mongo-cont --restart on-failure \
	-v ${PWD}/mongo/db:/mongodata -p 27017:27017 \
	--net="dbnet" \
	-d mongo:latest

mongo_cli:
	docker exec -it mongo-cont mongo -host localhost -port 27017

pgadmin:
	docker run --name pgadmin-cont --restart on-failure -p 5433:80 \
    	-e PGADMIN_DEFAULT_EMAIL="armmarov@gmail.com" \
    	-e PGADMIN_DEFAULT_PASSWORD="admin" \
	--net="dbnet" \
    	-d dpage/pgadmin4

phpmyadmin:
	docker run --name phpmyadmin-cont --restart on-failure -p 3307:80 \
	--net="dbnet" \
	--link mysql-cont:db \
	-d phpmyadmin/phpmyadmin:latest

rabbitmq:
	docker run --name store-rabbitmq \
		--hostname store-rabbitmq \
		--net=host \
		-d rabbitmq:3-management

