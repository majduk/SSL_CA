#CA management

Do zarządzania CA mają dostęp członkowei grupy ca_admins (w tym uzytkownik vas).

Skrypty znajdują się w katalogu /etc/ssl

##Listowanie użytkowników

Poniższy skrypt listuje wszystkie ważne certyfikaty wystawione przez CA, pojedynczy użytkownik może mieć więcej niż jeden certyfikat.
```bash
[root@vasgtw ssl]# ./list_users.sh
/C=PL/ST=Poland/O=P4/OU=CAROOT/CN=user1 Valid to: 20141016132418Z Serial: FAD0
/C=PL/ST=Poland/O=P4/OU=CAROOT/CN=user2 Valid to: 20141018085620Z Serial: FAD1
```
##Odnawianie certyfikatu użytkownika

Odnawianie certyfikatu wykonuje się w taki sam sposób jak dodawanie nowego certyfikatu dla danego użytkownika. Powoduje to nadpisanie starego certyfikatu (tak aby istniał tylko jeden i nie było wątpliwości który jest właściwy).

Starego certyfikatu nie ma potrzeby unieważniać jeżeli odnawianie wynika z tego, że stary certyfikat ekspiruje. W przeciwnym razie należy go usunąć (patrz niżej - usuwanie użytkownika)
Dodawanie użytkownika

Przykład - dodanie użytkownika test

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
            organizationName          = P4
            organizationalUnitName    = OAPI
            commonName                = test
Certificate is to be certified until Apr 22 10:50:11 2015 GMT (730 days)
Sign the certificate? [y/n]:y

1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
done
Exporting certificate...done
Certificate stored to /etc/ssl/private/users/test/test-certpack.tar.gz
Export password: 3i1Iy59GEvoBA6vK


Następnie eksportujemy spakowany plik do katalogu /etc/ssl/public

[/etc/ssl]$ sudo ./export_user.sh test
Copying Server Private Key test-certpack.tar.gz to /tmp/ssl/public...done

Następnie wysyłamy mailem spakowany plik <uzytkownik>-certpack.tar.gz z /tmp/ssl/public i usuwamy go z tego katalogu

Potem wysyłamy SMSem korzystając ze skryptu albo ręcznie hasło do certyfikatów:

sudo /etc/ssl/send_password.sh 48792237027 3i1Iy59GEvoBA6vK

Po całej operacji usuwamy plik z katalogu /tmp/ssl/public
Usuwanie użytkownika

Skrypt usuwa po jednym certyfikacie użytkownika licząc od najstarszego. Jeżeli chcemy całkowicie usunąć użytkownika to skrypt należy uruchomić tyle razy ile użytkownik ma certyfikatów.

Przykład - usuwamy użytkownika test:

/etc/ssl# sudo /etc/ssl/remove_user.sh test
Found following Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 64231 (0xfae7)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=PL, ST=Poland, L=Warsaw, O=P4, OU=OAPI, CN=OAPI 


[[mailto:CA/emailAddress=oapi@oapi.test.play.pl][CA/emailAddress=oapi@oapi.test.play.pl]]

        Validity
            Not Before: Apr 22 10:50:11 2013 GMT
            Not After : Apr 22 10:50:11 2015 GMT
        Subject: C=PL, ST=Poland, O=P4, OU=OAPI, CN=test
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

Sprawdzamy, czy znaleziony został właściwy certyfikat (czy zgadza się nazwa w polu Subject), jeżeli tak, odpowiadamy yes, co powioduje dodanie certyfikatu do listy odwołanych certyfikatów:


Revoke this certificate? [yes/no]:yes
Enter CA key password:[KORNELOWE]

Revoking certificate for user CN=test (serial FAE7)...
Using configuration from /etc/ssl/openssl.cnf
Revoking Certificate FAE7.
Data Base Updated
done
Updating CRL...
Using configuration from /etc/ssl/openssl.cnf
done
Make sure you copy the new CRL file /etc/ssl/private/ca.crl to web server and restart the web server

Uwaga:

W przypadku kiedy pojawił sie komunikat: "done, but more certificates with CommonName=test exist": jeżeli chcemy całkowicie usunąć wszystkie certyfikaty użytkownika musimy uruchomić skrypt ponownie.

Następnie eksportujemy plik CRL do katalogu /etc/ssl/public

/etc/ssl# sudo /etc/ssl/export_crl.sh
Copying CRL ca.crl ...done
Move file from /etc/ssl/public to the server and restart the server

Następnie kopiujemy plik /tmp/ssl/public/ca.crl na MTA MM3 (na oba węzły ) i na mm3-node1 oraz mm3-node2 podmieniamy:

/etc/ssl/oapi-ca/ca.crl

Następnie restartujemy apache'a

Po całej operacji usuwamy plik z katalogu /tmp/ssl/public
Aktualizacja Certyfikatu serwera

Uruchamiany skrypt i podajemy hasło kornelowe.

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

Następnie kopiujemy na MTA MM3 (oba węzły) pliki:

/tmp/ssl/public/apache.crt

/tmp/ssl/public/apache.key

i podmieniamy na skopiowane pliki te które znajdują się na MTA w katalogu: /etc/ssl/oapi-ca/

Następnie restartujemy Apache'a

Po całej operacji usuwamy pliki z katalogu /tmp/ssl/public

Certyfikaty partnerów

Serwer SMP akceptuje certyfikaty w formie pliku PEM z certyfikatem i kliczem bez hasła. Przykład prawidłowego pliku:

[root@oapi1 partner-certs]# cat 'play@oneinvoice.play.naviexpert.net.pem'

Bag Attributes
    localKeyID: 9D 83 2E 54 AB 7C B9 F5 27 84 63 C7 10 73 FD D6 57 1F A2 EE
    friendlyName: play@oneinvoice.play.naviexpert.net
subject=/C=PL/ST=wielkopolskie/O=NaviExpert sp. z o.o./CN=play@oneinvoice.play.naviexpert.net
issuer=/C=PL/ST=wielkopolskie/L=Poznan/O=NaviExpert sp. z o.o./CN=NaviExpert CA 1
-----BEGIN CERTIFICATE-----
MIID2TCCAsGgAwIBAgIBBjANBgkqhkiG...
...46A99HzsHMGjuRXPn8xQ1J59aUaFLDdiX34A=
-----END CERTIFICATE-----
Bag Attributes
    localKeyID: 9D 83 2E 54 AB 7C B9 F5 27 84 63 C7 10 73 FD D6 57 1F A2 EE
    friendlyName: play@oneinvoice.play.naviexpert.net
Key Attributes: <No Attributes>
-----BEGIN PRIVATE KEY-----
MII...
...lDmhGkaDy0GdTsbEMtIDg5Cg
-----END PRIVATE KEY-----

Pliki P12 nie są akceptowane przez serwer jednak mogą być łatwo skonwertowane do właściwego formatu:

openssl pkcs12 -in file.p12 -out file.pem -nodes

Konfiguracja certyfikatu partnera:

    Zalogować się na serwer SMP (172.16.21.98)
    Załadowac plik PEM do katalogu /etc/ssl/partner-certs
    Zalogować się do bazy SMP i przejśc do tabeli services. Znaleźć id serwisu który nas interesuje
    Przejść do tabeli url_lists i dla wszystkich URLi dla który w kolumnie service_id jest id z poprzedniego punktu podać pełną ścieżkę do certyfikatu. 

Pełne zapytanie dla kroków 3 i 4 - przykład:

UPDATE url_lists SET crt_file='/etc/ssl/partner-certs/play_oapi_PresspublicaClient.pem'
WHERE service_id=(SELECT id FROM services WHERE name='PRESSPUBLICA_3')

-- MichalAjduk - 2013-04-22 
