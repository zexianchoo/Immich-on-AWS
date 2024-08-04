# unfortunately, there is no easy way to build and push docker image to ecr (unless we use dind or kaniko).

## Hence, we opt for clickops as a simple solution.


```
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin .dkr.ecr.ap-southeast-1.amazonaws.com
#tag the image to be pushed
docker tag change-assessment .dkr.ecr.ap-southeast-1.amazonaws.com/change-assessment:latest
#push the image
docker push .dkr.ecr.ap-southeast-1.amazonaws.com/change-assessment:latest

```
docker compose up 
