class passenger($gem_bin='/usr/bin',
                $gem_path='/var/lib/gems/1.9.1/gems',
                $passenger_version='4.0.33',
                $rubyLoc='/usr/bin/ruby1.9.1',
                $port='80',
                $mod_pass_loc='/var/lib/gems/1.9.1/gems/passenger-4.0.33/buildout/apache2/mod_passenger.so',
                $passenger_dir='/var/lib/gems/1.9.1/gems/passenger-4.0.33/',
                $serverName=undef,
                $publicPath=undef){

    if ! defined(Package['build-essential']){package{'build-essential':ensure=>installed}}
    if ! defined(Package['passenger']){package{'passenger': ensure=>'4.0.33', provider=>gem }}
    if ! defined(Package['apache2-mpm-worker']){package{'apache2-mpm-worker': ensure=>installed }}
    if ! defined(Package['apache2-threaded-dev']){package{'apache2-threaded-dev': ensure=>installed }}
    if ! defined(Package['rack']){package{'rack': provider=>gem}}
    if ! defined(Package['libcurl4-openssl-dev']){package{'libcurl4-openssl-dev':ensure=>installed}}
    if ! defined(Package['ruby1.9.1-dev']){package{'ruby1.9.1-dev': ensure=>installed}}
    

exec{'compile_passenger':
    path =>$path,
    command => "passenger-install-apache2-module -a",
    user => root,
    creates=>"/var/lib/gems/1.9.1/gems/passenger-4.0.33/buildout/apache2/mod_passenger.so",
    provider=>'shell',
    require=>[Package['rack'],Package['apache2-mpm-worker'],Package['apache2-threaded-dev'], Package['ruby1.9.1-dev']],
    logoutput => true,
}
exec{'create_logsDir':
    path=>['/sbin', '/usr/bin', '/bin', '/usr/sbin'],
    command=>'mkdir /etc/apache2/logs',
    creates=>'/etc/apache2/logs',
    require=>Exec['compile_passenger']
}
exec{'error.log':
    path=>['/sbin', '/usr/bin', '/bin', '/usr/sbin'],
    command=>'touch /etc/apache2/logs/error.log',
    creates=>'/etc/apache2/logs/error.log',
    logoutput=>true,
    require=>Exec['create_logsDir']

}->
file{"apache2.conf":
    path=>"/etc/apache2/apache2.conf",
    ensure=>file,
    content => template("passenger/apache2.erb"),
    require=>[Exec['compile_passenger']]
  }
}