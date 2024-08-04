source .env

docker compose up --build --no-start

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com

#tag the image to be pushed
docker tag immich_server:latest ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-server:latest
docker tag immich_machine_learning:latest ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-machine-learning:latest

#push the image
docker push ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-server:latest
docker push ${acc_num}.dkr.ecr.ap-southeast-1.amazonaws.com/immich-machine-learning:latest
