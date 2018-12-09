# docker-gitlab-runner
[amazone-ecr-credential-helper][amazon_ecr_credential_helper] 를 사용하는 gitlab-runner Docker Image

## environment 셋팅
docker-credential-ecr-login 을 사용하기위해 AWS credential 이 필요. `docker-compose.yml` 에서 아래 environment 를 필요로 함.

```sh
export AWS_ACCESS_KEY_ID=AKOOOOOOOOOOOOOOOOWA
export AWS_SECRET_ACCESS_KEY=exjxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5/Y
export AWS_DEFAULT_REGION=ap-northeast-2
```

## gitlab-runner 실행

```sh
$ docker-compose up -d
```

## runner 등록
```sh
$ docker-compose exec runner gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=40 revision=7f00c780 version=11.5.1
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://gitlab.com/
Please enter the gitlab-ci token for this runner:
o6xxxxxxxxxxxxxxxxLt
Please enter the gitlab-ci description for this runner:
[65xxxxxxxx1e]: my-runner-for-using-ecr
Please enter the gitlab-ci tags for this runner (comma separated):

Registering runner... succeeded                     runner=o6xxxxxx
Please enter the executor: docker-ssh, shell, virtualbox, docker+machine, docker-ssh+machine, kubernetes, docker, ssh, parallels:
docker
Please enter the default Docker image (e.g. ruby:2.1):
ubuntu:16.04
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

## config.toml 파일 수정
Text 에디터로 `gitlab-runner/config.toml` 설정 파일을 열어 `[[runners]]` section 에 `DOCKER_AUTH_CONFIG` 추가

```diff
 [[runners]]
   url = "https://gitlab.com/"
   executor = "docker"
+  environment = [
+    'DOCKER_AUTH_CONFIG={"credsStore":"ecr-login"}',
+  ]
   [runners.docker]
```

또는 아래와 같이 특정 registry 에 한정하여 설정 할 수 있음

```diff
 [[runners]]
   url = "https://gitlab.com/"
   executor = "docker"
+  environment = [
+    'DOCKER_AUTH_CONFIG={"credHelpers":{"530000000092.dkr.ecr.ap-northeast-2.amazonaws.com":"ecr-login"}',
+  ]
   [runners.docker]
```

## docker-credential-ecr-login get
최초 1회 `docker-credential-ecr-login get` 명령어를 통해 `AuthorizationToken` 을 생성. 생성된 토큰은 `/root/.ecr/cache.json` 에 저장됨.

```sh
$ docker-compose exec -T runner /bin/sh -c "echo 530000000092.dkr.ecr.ap-northeast-2.amazonaws.com | docker-credential-ecr-login get"
{"ServerURL":"530000000092.dkr.ecr.ap-northeast-2.amazonaws.com","Username":"AWS","Secret":"eynR5cGUiOiJEQVRBX0tFWSI......sImV4cGlyYXRpb24iOjE1NDQzODMzMzV9"}
```

## references
- https://github.com/awslabs/amazon-ecr-credential-helper
- https://hub.docker.com/r/pottava/amazon-ecr-credential-helper/
- https://hub.docker.com/r/dolbylabs/amazon-ecr-credential-helper/

[amazon_ecr_credential_helper]: https://github.com/awslabs/amazon-ecr-credential-helper
