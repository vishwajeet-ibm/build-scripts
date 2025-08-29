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

if [ "$validate_build_script" == true ]; then
    # Use a stable Trivy version instead of latest (better for s390x)
    TRIVY_VERSION="v0.53.0"
    wget -q https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    tar -xzf trivy_${TRIVY_VERSION#v}_Linux-s390x.tar.gz
    chmod +x trivy
    sudo mv trivy /usr/bin

    echo "Cleaning old Trivy cache..."
    sudo rm -rf /root/.cache/trivy ~/.cache/trivy

    echo "Updating Trivy DB in light mode..."
    sudo trivy fs --download-db-only --light

    echo "Executing Trivy FS scanner in light mode..."
    sudo trivy -q fs --light --timeout 30m -f json "${cloned_package}" > trivy_source_vulnerabilities_results.json
    sudo trivy -q fs --light --timeout 30m -f cyclonedx "${cloned_package}" > trivy_source_sbom_results.cyclonedx
fi

