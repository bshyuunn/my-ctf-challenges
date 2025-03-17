all: build-contracts start-challenge-server

start-challenge-server:
	docker compose up --build -d

build-contracts:
	cd build/src/contracts && forge build