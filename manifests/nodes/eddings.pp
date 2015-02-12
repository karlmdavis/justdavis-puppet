# The configuration file for this node.
node 'eddings.justdavis.com' {
  # Install PostgreSQL.
  class { 'postgresql::server':
    listen_addresses => 'localhost',
  }

  # Add a PostgreSQL DB for the RPS Service (https://github.com/karlmdavis/rps-tourney/) to use.
  $rps_db_password='rpspassword'
  postgresql::server::db { 'rps':
    user     => 'rps',
    password => postgresql_password('rps', $rps_db_password),
    encoding => 'UTF8',
  }

  # Add a PostgreSQL DB for Sonar to use.
  $sonar_db_password='sonarpassword'
  postgresql::server::db { 'sonar':
    user     => 'sonar',
    password => postgresql_password('sonar', $sonar_db_password),
    encoding => 'UTF8',
  }

  # Install Sonar.
  $sonar_jdbc={
    url               => 'jdbc:postgresql://localhost/sonar',
    username          => 'sonar',
    password          => $sonar_db_password,
  }
  $sonar_ldap={
    url           => 'ldaps://ldap.justdavis.com',
    user_base_dn  => 'ou=people,dc=justdavis,dc=com',
  }
  class { 'maven::maven' : } ->
  class { 'sonar' :
    version      => '3.7.3',
    port         => '9000',
    context_path => '/sonar',
    jdbc         => $sonar_jdbc,
    ldap         => $sonar_ldap,
    require      => Postgresql::Server::Db['sonar'],
  }

  # Install the Oracle JDK 8, for Jenkins to use.
  class { 'jdk_oracle' :
    version      => '8',
    version_update => '31',
    version_build => '13',
    # Will be installed to '/usr/local/jdk1.8.0_31'.
    install_dir => '/usr/local',
    # Do not add it to the path or environment.
    default_java => false,
  } ->
  # Add the justdavis.com CA root to the JDK 8's truststore.
  java_ks { 'justdavis.com-ca-root:/usr/local/jdk1.8.0_31/jre/lib/security/cacerts':
    ensure       => latest,
    certificate  => '/etc/ssl/certs/justdavis.com-wildcard-ca-root.pem',
    target       => '/usr/local/jdk1.8.0_31/jre/lib/security/cacerts',
    password     => 'changeit',
    trustcacerts => true,
  }
}
