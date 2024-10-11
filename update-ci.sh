cat << EOF > .github/workflows/ci.yml
name: Publish Docker images

on:
  push:
    branches:
      - 'master'

jobs:
EOF

for dir in *; do
  if [ -d "$dir" ]; then
    jobid="${dir//./-}"
    cat << EOF >> .github/workflows/ci.yml
  build_$jobid:
    name: $dir
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v4
      
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: \${{ secrets.DOCKER_USERNAME }}
          password: \${{ secrets.DOCKER_PASSWORD }}
      
      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: dontomika/timescaledb-with-toolkit
          tags: $dir
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: ./$dir
          file: ./$dir/Dockerfile
          push: true
          tags: \${{ steps.meta.outputs.tags }}
          labels: \${{ steps.meta.outputs.labels }}

EOF
  fi
done
