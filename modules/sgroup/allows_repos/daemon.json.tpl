{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "insecure-registries": ["${URL_PRIVATE_DOCKER}", "${URL_DOCKER}"],
  "registry-mirrors": ["http://${URL_PRIVATE_DOCKER}","http://${URL_DOCKER}"]
}