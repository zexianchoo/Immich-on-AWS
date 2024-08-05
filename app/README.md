# unfortunately, there is no easy way to build and push docker image to ecr (unless we use dind or kaniko).

## Hence, we opt for clickops as a simple solution.

There is a `build_and_push.sh`. It is to be run on a terminal where you have exported the credentials for ur AWS, and to fill up .env with the creentials.

