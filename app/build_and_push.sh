source .env

docker compose up --build --no-start

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com

# #tag the image to be pushed
docker tag ghcr.io/immich-app/immich-server:release ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-ecr-immich-app-dev:latest
docker tag ghcr.io/immich-app/immich-machine-learning:release ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-ecr-immich-ml-dev:latest

#push the image
docker push ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-ecr-immich-app-dev:latest
docker push ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-ecr-immich-ml-dev:latest
