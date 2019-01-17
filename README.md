# docker-gitlab-runner
![Docker Automated](https://img.shields.io/docker/automated/alucio/gitlab-runner-with-ecr.svg)
![Docker Build](https://img.shields.io/docker/build/alucio/gitlab-runner-with-ecr.svg)

gitlab runner with [amazone-ecr-credential-helper][amazon_ecr_credential_helper]

## 1. Set environment variables
AWS credential is required to use docker-credential-ecr-login. Below
environment variables are referenced in the `docker-compose.yml` file.

```sh
export AWS_ACCESS_KEY_ID=AKOOOOOOOOOOOOOOOOWA
export AWS_SECRET_ACCESS_KEY=exjxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5/Y
export AWS_DEFAULT_REGION=ap-northeast-2
```

## 2. Run gitlab-runner

```sh
$ docker-compose up -d
```

## 3. Register runner

```sh
$ docker-compose exec runner gitlab-runner register --env 'DOCKER_AUTH_CONFIG={"credsStore":"ecr-login"}'
Runtime platform                                    arch=amd64 os=linux pid=40 revision=7f00c780 version=11.5.1
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://gitlab.com/
Please enter the gitlab-ci token for this runner:
o6xxxxxxxxxxxxxxxxLt
Please enter the gitlab-ci description for this runner:
[65xxxxxxxx1e]: my-runner-for-using-ecr
Please enter the gitlab-ci tags for this runner (comma separated):
withecr
Registering runner... succeeded                     runner=o6xxxxxx
Please enter the executor: docker-ssh, shell, virtualbox, docker+machine, docker-ssh+machine, kubernetes, docker, ssh, parallels:
docker
Please enter the default Docker image (e.g. ruby:2.1):
ubuntu:16.04
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

This register command creates below `gitlab-runner/config.toml`:
```toml
[[runners]]
  name = "my-runner-for-using-ecr"
  url = "https://gitlab.com/"
  token = "o6xxxxxxxxxxxxxxxxLt"
  executor = "docker"
  environment = ["DOCKER_AUTH_CONFIG={\"credsStore\":\"ecr-login\"}"]
  [runners.docker]
    tls_verify = false
    image = "ubuntu:16.04"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```

## 4. docker-credential-ecr-login get
For the first time, create `AuthorizationToken` through`
docker-credential-ecr-login get` command. The generated token is stored in
`.ecr/cache.json`.

```sh
$ docker-compose exec -T runner /bin/sh -c "echo 530000000092.dkr.ecr.ap-northeast-2.amazonaws.com | docker-credential-ecr-login get"
{"ServerURL":"530000000092.dkr.ecr.ap-northeast-2.amazonaws.com","Username":"AWS","Secret":"eynR5cGUiOiJEQVRBX0tFWSI......sImV4cGlyYXRpb24iOjE1NDQzODMzMzV9"}
```

## 5. Example of `gitlab-ci.yml`

```yml
# .gitlab-ci.yml
# now you can use a docker image that belongs to your ECR
image: 530000000092.dkr.ecr.ap-northeast-2.amazonaws.com/for-build

build:
  script:
    - yarn && yarn build
```

## References
- https://github.com/awslabs/amazon-ecr-credential-helper
- https://hub.docker.com/r/pottava/amazon-ecr-credential-helper/
- https://hub.docker.com/r/dolbylabs/amazon-ecr-credential-helper/

[amazon_ecr_credential_helper]: https://github.com/awslabs/amazon-ecr-credential-helper
[gitlab_comment]: https://gitlab.com/gitlab-org/gitlab-runner/issues/1583#note_93170156
