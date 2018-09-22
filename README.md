## kerberos-and-docker
Examples of Dockerfiles with Kerberos and other things


## Build image
```
$ docker build -t image .
```

## GO
```
$  docker run -d --name some-application image
```

## Exposing external port
```
$ docker run -d --name some-application -p 8080:8080 image
```

## Using external files
```
$  docker run -d --name some-application --net=host -v /etc/krb5.conf:/etc/krb5.conf -v /etc/security/keytabs/pirulito.keytab:/etc/security/keytabs/pirulito.keytab -p 8080:8080 image

```
