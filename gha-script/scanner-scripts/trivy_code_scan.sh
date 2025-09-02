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
TRIVY_CACHE_DIR="$HOME/.cache/trivy/db"

# Always create cache directory
mkdir -p "$TRIVY_CACHE_DIR"

docker pull "$DOCKER_IMAGE"

if [ "$validate_build_script" == true ]; then
    # Download latest Trivy binary
    wget https://github.com/aquasecurity/trivy/releases/download/v0.45.0/trivy_0.45.0_Linux-S390X.tar.gz
    tar -xf trivy_0.45.0_Linux-S390X.tar.gz
    chmod +x trivy
    sudo mv trivy /usr/bin

    echo "Fetching fresh Trivy DB from Docker image..."
    sudo docker run -d --name trivy-container "$DOCKER_IMAGE"
    sudo docker cp trivy-container:/trivy.db "$TRIVY_CACHE_DIR/trivy.db"
    sudo docker rm -f trivy-container

    sudo chmod -R 755 "$TRIVY_CACHE_DIR"

    echo "Running Trivy vulnerability scan..."
    sudo trivy -q fs --skip-db-update --timeout 30m -f json "${cloned_package}" > trivy_source_vulnerabilities_results.json

    echo "Generating SBOM report..."
    sudo trivy -q fs --skip-db-update --timeout 30m -f cyclonedx "${cloned_package}" > trivy_source_sbom_results.cyclonedx

    echo "SBOM file generated: trivy_source_sbom_results.cyclonedx"
fi


