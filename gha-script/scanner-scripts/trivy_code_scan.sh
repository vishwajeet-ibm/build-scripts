# #!/bin/bash -e

# validate_build_script=$VALIDATE_BUILD_SCRIPT
# cloned_package=$CLONED_PACKAGE
# cd package-cache

# if [ $validate_build_script == true ];then
# 	TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
# 	wget https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
# 	tar -xzf trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
#         chmod +x trivy
#         sudo mv trivy /usr/bin
# 	echo "Executing trivy scanner"
# 	sudo trivy -q fs --timeout 30m -f json ${cloned_package} > trivy_source_vulnerabilities_results.json
#  	#cat trivy_source_vulnerabilities_results.json
# 	sudo trivy -q fs --timeout 30m -f cyclonedx ${cloned_package} > trivy_source_sbom_results.cyclonedx
#  	#cat trivy_source_sbom_results.cyclonedx
#  fi

#!/bin/bash -e

validate_build_script=$VALIDATE_BUILD_SCRIPT
cloned_package=$CLONED_PACKAGE
cd package-cache

DOCKER_IMAGE="sankalppersi/trivy-db:latest"
TRIVY_CACHE_DIR="/root/.cache/trivy/db"

# Always create cache directory explicitly
sudo mkdir -p "$TRIVY_CACHE_DIR"

# Pull latest Trivy DB container
docker pull "$DOCKER_IMAGE"

if [ "$validate_build_script" == true ]; then
    echo "Downloading latest Trivy version..."
    TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    wget https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    tar -xf trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    chmod +x trivy
    sudo mv trivy /usr/bin

    echo "Fetching fresh Trivy DB from Docker image..."
    sudo docker run -d --name trivy-container "$DOCKER_IMAGE"
    sudo docker cp trivy-container:/trivy.db "$TRIVY_CACHE_DIR/trivy.db"
    sudo docker rm -f trivy-container

    sudo chmod -R 755 "/root/.cache/trivy"

    echo "Updating Trivy DB..."
    sudo trivy --cache-dir /root/.cache/trivy image --download-db-only

    echo "Running Trivy vulnerability scan..."
    sudo trivy -q fs --cache-dir /root/.cache/trivy --timeout 30m -f json "${cloned_package}" > trivy_source_vulnerabilities_results.json

    echo "Generating SBOM report..."
    sudo trivy -q fs --cache-dir /root/.cache/trivy --timeout 30m -f cyclonedx "${cloned_package}" > trivy_source_sbom_results.cyclonedx

    echo "SBOM file generated: trivy_source_sbom_results.cyclonedx"
fi



