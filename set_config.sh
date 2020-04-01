java_config_path=$HOME/arcus-misc/arcus-misc1/acp-java/config-arcus-integration.txt
c_config_path=$HOME/arcus-misc/arcus-misc1/acp-c/config-standard.txt

service_code=long_running_enterprise
sed -i "s/^service_code.*/service_code=$service_code/" $java_config_path
sed -i "s/^service_code.*/service_code=$service_code/" $c_config_path
