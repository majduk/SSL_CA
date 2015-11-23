#CA management

Do zarządzania CA mają dostęp członkowei grupy ca_admins.

Skrypty znajdują się w katalogu /etc/ssl

Pozwalaja na konfiguracje certyfikatu serwera oraz certyfikatow klientow.

##Listowanie użytkowników

Poniższy skrypt listuje wszystkie ważne certyfikaty wystawione przez CA, pojedynczy użytkownik może mieć więcej niż jeden certyfikat.
```bash
[root@vasgtw ssl]# ./list_users.sh
/C=PL/ST=Poland/O=ON/OU=CAROOT/CN=user1 Valid to: 20141016132418Z Serial: EAD0
/C=PL/ST=Poland/O=ON/OU=CAROOT/CN=user2 Valid to: 20141018085620Z Serial: EAD1
```
##Odnawianie certyfikatu użytkownika

Odnawianie certyfikatu wykonuje się w taki sam sposób jak dodawanie nowego certyfikatu dla danego użytkownika. Powoduje to nadpisanie starego certyfikatu (tak aby istniał tylko jeden i nie było wątpliwości który jest właściwy).

Starego certyfikatu nie ma potrzeby unieważniać jeżeli odnawianie wynika z tego, że stary certyfikat ekspiruje. W przeciwnym razie należy go usunąć (patrz niżej - usuwanie użytkownika)
##Dodawanie użytkownika

Przykład - dodanie użytkownika test
```bash
/etc/ssl# sudo /etc/ssl/new_user.sh test
Generating Private Key file...Generating RSA private key, 2048 bit long modulus
........................+++
.........+++
e is 65537 (0x10001)
done
Creating Certificate Request file...done
Signing Certificate Request file...
Using configuration from /etc/ssl/openssl.cnf
Enter pass phrase for /etc/ssl/private/ca.key:[PASS]
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 64231 (0xfae7)
        Validity
            Not Before: Apr 22 10:50:11 2013 GMT
            Not After : Apr 22 10:50:11 2015 GMT
        Subject:
            countryName               = PL
            stateOrProvinceName       = Poland
            organizationName          = ON
            organizationalUnitName    = CAROOT
            commonName                = test
Certificate is to be certified until Apr 22 10:50:11 2015 GMT (730 days)
Sign the certificate? [y/n]:y

1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
done
Exporting certificate...done
Certificate stored to /etc/ssl/private/users/test/test-certpack.tar.gz
Export password: <expoer pass>
```

##Usuwanie użytkownika

Skrypt usuwa po jednym certyfikacie użytkownika licząc od najstarszego. Jeżeli chcemy całkowicie usunąć użytkownika to skrypt należy uruchomić tyle razy ile użytkownik ma certyfikatów.

Przykład - usuwamy użytkownika test:
```bash
/etc/ssl# sudo /etc/ssl/remove_user.sh test
Found following Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 64231 (0xfae7)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=PL, ST=Poland, L=Warsaw, O=ON, OU=CAROOT, CN=test 

        Validity
            Not Before: Apr 22 10:50:11 2013 GMT
            Not After : Apr 22 10:50:11 2015 GMT
        Subject: C=PL, ST=Poland, O=ON, OU=CAROOT, CN=test
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (2048 bit)
                Modulus (2048 bit):
                    00:cf:f2:78:0a:97:5f:7f:84:8d:2a:53:48:22:c1:
..


                    d8:9f:47:fa:46:49:80:4b:73:d5:68:6c:c1:dc:a3:
                    f0:c1
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha1WithRSAEncryption
        29:5e:c5:f3:28:37:69:15:b3:31:3b:cf:7f:65:53:04:c7:12:
..
        ac:a0:3a:71:0b:f4:49:28:04:e4:36:61:37:d3:f4:7f:b6:d7:
        22:36:13:05
Revoke this certificate? [yes/no]:yes
```
Sprawdzamy, czy znaleziony został właściwy certyfikat (czy zgadza się nazwa w polu Subject), jeżeli tak, odpowiadamy yes, co powioduje dodanie certyfikatu do listy odwołanych certyfikatów:

```
Revoke this certificate? [yes/no]:yes
Enter CA key password:[PASS]

Revoking certificate for user CN=test (serial EAE7)...
Using configuration from /etc/ssl/openssl.cnf
Revoking Certificate EAE7.
Data Base Updated
done
Updating CRL...
Using configuration from /etc/ssl/openssl.cnf
done
Make sure you copy the new CRL file /etc/ssl/private/ca.crl to web server and restart the web server
```
Uwaga:

W przypadku kiedy pojawił sie komunikat: "done, but more certificates with CommonName=test exist": jeżeli chcemy całkowicie usunąć wszystkie certyfikaty użytkownika musimy uruchomić skrypt ponownie.

Następnie eksportujemy plik CRL do katalogu `/etc/ssl/public`
```
/etc/ssl# sudo /etc/ssl/export_crl.sh
Copying CRL ca.crl ...done
Move file from /etc/ssl/public to the server and restart the server
```
Następnie kopiujemy plik /tmp/ssl/public/ca.crl na serwer i restartujemy apache'a

##Aktualizacja Certyfikatu serwera

Uruchamiany skrypt i podajemy hasło:
```
/etc/ssl# sudo /etc/ssl/new_server.sh
Generating Private Key file...Generating RSA private key, 512 bit long modulus
................++++++++++++
.......++++++++++++
e is 65537 (0x10001)
done
Creating Certificate Request file...done
Signing Certificate Request file...
Using configuration from /etc/ssl/openssl.cnf
Enter pass phrase for /etc/ssl/private/ca.key:

Następnie eksportujemy pliki apache.* do katalogu /tmp/ssl/public

/etc/ssl# sudo /etc/ssl/export_server.sh
Copying Server Private Key apache.key ...done
Copying Server Certificate apache.crt...done
Move files from /etc/ssl/public to the server and restart the server
```
Następnie kopiujemy na serwer pliki:
```
/tmp/ssl/public/apache.crt

/tmp/ssl/public/apache.key
```

Następnie restartujemy Apache'a
