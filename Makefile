build:
	docker build -t "webtp3/docker" .

publish: build
	docker push webtp3/docker
