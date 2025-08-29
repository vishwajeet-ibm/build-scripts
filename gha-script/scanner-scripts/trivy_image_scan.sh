# #!/bin/bash -e

# image_name=$IMAGE_NAME
# build_docker=$BUILD_DOCKER

# if [ $build_docker == true ];then
# 	TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
# 	wget https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
# 	tar -xzf trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
#         chmod +x trivy
#         sudo mv trivy /usr/bin
# 	echo "Executing trivy scanner"
# 	sudo trivy -q image --timeout 30m -f json ${image_name} > trivy_image_vulnerabilities_results.json
# 	sudo trivy -q image --timeout 30m -f cyclonedx ${image_name} > trivy_image_sbom_results.cyclonedx
#  fi

#!/bin/bash -e

image_name=$IMAGE_NAME
build_docker=$BUILD_DOCKER

if [ "$build_docker" == true ]; then
    # Use a stable version instead of latest
    TRIVY_VERSION="v0.53.0"
    wget https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    tar -xzf trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    chmod +x trivy
    sudo mv trivy /usr/bin

    echo "Cleaning old Trivy cache..."
    sudo rm -rf /root/.cache/trivy ~/.cache/trivy

    echo "Updating Trivy DB in light mode..."
    sudo trivy image --download-db-only --light

    echo "Executing Trivy scanner in light mode..."
    sudo trivy -q image --light --timeout 30m -f json ${image_name} > trivy_image_vulnerabilities_results.json
    sudo trivy -q image --light --timeout 30m -f cyclonedx ${image_name} > trivy_image_sbom_results.cyclonedx
fi



