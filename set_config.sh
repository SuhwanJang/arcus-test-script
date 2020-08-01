java_config_path=$HOME/arcus-misc-enterprise/acp-java/config-arcus-integration.txt
c_config_path=$HOME/arcus-misc-community/acp-c/config-standard.txt

#service_code=long_running_enterprise
#sed -i "s/^service_code.*/service_code=$service_code/" $java_config_path
#sed -i "s/^service_code.*/service_code=$service_code/" $c_config_path

java_key_prefix=java-s001
c_key_prefix=c-s001
sed -i "s/^key_prefix.*/key_prefix=$java_key_prefix/" $java_config_path
sed -i "s/^key_prefix.*/key_prefix=$c_key_prefix/" $c_config_path
