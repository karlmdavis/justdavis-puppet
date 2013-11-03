# The configuration file for this node.
node 'eddings.justdavis.com' {
  # Install PostgreSQL.
  class { 'postgresql::server':
    listen_addresses => 'localhost',
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
}
