openssl pkcs12 -in cert.p12 -out cert.pem -nodes -passin pass:
openssl pkcs12 -in key.p12 -out key.pem -nodes -passin pass:
openssl rsa -in key.pem -out key.unencrypted.pem
cat cert.pem key.unencrypted.pem > apns.pem
rm cert.pem
rm key.pem
rm key.unencrypted.pem

