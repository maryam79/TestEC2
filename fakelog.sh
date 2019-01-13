#! /bin/bash

sudo yum install git -y
sudo git clone https://github.com/kiritbasu/Fake-Apache-Log-Generator.git
cd Fake-Apache-Log-Generator/
sudo pip install -r requirements.txt
python apache-fake-log-gen.py
sudo mkdir -p /var/log/apache/
sudo python apache-fake-log-gen.py -n 0 -o LOG -p /var/log/apache/ &
cd ..
sudo yum install java-1.8.0 -y
sudo yum remove java-1.7.0-openjdk -y
sudo rpm --import  https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > test << EOF
[logstash-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" 
EOF
sudo cp test /etc/yum.repos.d/logstash.repo
sudo yum install logstash -y
Instance_ID=`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/instance-id | cut -d'-' -f 2 `
Instance_IP= `/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/public-ipv4`
cat > test2 << EOF
input {
    file {
       path => "/var/log/apache/*"
    }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
    remove_field => "message"
  }
  date {
    match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
    locale => en
    remove_field => ["timestamp"]
  }
  geoip {
    source => "clientip"
  }
  useragent {
    source => "agent"
    target => "useragent"
  }
}

output {
    amazon_es {
      hosts => "search-logstash-test-ozryzwxu4moxzcge2iov5rjzf4.ap-southeast-2.es.amazonaws.com"
      port => "443"
      region => "ap-southeast-2"
      index => "$Instance_ID"
      document_type => "apache"
      manage_template => false
    }
}
EOF
sudo cp test2  /etc/logstash/conf.d/logstash.conf
cd /usr/share/logstash/
sudo bin/logstash-plugin install logstash-output-amazon_es
sudo bin/logstash -f /etc/logstash/conf.d/logstash.conf &
