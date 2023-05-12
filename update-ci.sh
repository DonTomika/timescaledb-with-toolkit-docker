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
    cat << EOF >> .github/workflows/ci.yml
  build_$dir:
    name: $dir
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v3
      
      - name: Log in to Docker Hub
        uses: docker/login-action@f4ef78c080cd8ba55a85445d5b36e214a81df20a
        with:
          username: \${{ secrets.DOCKER_USERNAME }}
          password: \${{ secrets.DOCKER_PASSWORD }}
      
      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@9ec57ed1fcdbf14dcef7dfbe97b2010124a938b7
        with:
          images: dontomika/timescaledb-with-toolkit
          tags: $dir
      
      - name: Build and push Docker image
        uses: docker/build-push-action@3b5e8027fcad23fda98b2e3ac259d8d67585f671
        with:
          context: ./$dir
          file: ./$dir/Dockerfile
          push: true
          tags: \${{ steps.meta.outputs.tags }}
          labels: \${{ steps.meta.outputs.labels }}

EOF
  fi
done