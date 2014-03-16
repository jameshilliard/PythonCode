# $Id: security_methods.tcl,v 1.17.16.1 2008/01/24 20:56:22 manderson Exp $
#
########################################
#  Security Method Definitions
########################################
# None
set None(EncryptionMethod) None
set None(ApAuthMethod) Open
set None(NetworkAuthMethod) None
set None(KeyId) 1
set None(KeyType) ascii

# WEP-Open-40
set WEP-Open-40(EncryptionMethod) WEP
set WEP-Open-40(ApAuthMethod) Open
set WEP-Open-40(NetworkAuthMethod) None
set WEP-Open-40(KeyId) 1

# WEP-Open-128
set WEP-Open-128(EncryptionMethod) WEP
set WEP-Open-128(ApAuthMethod) Open
set WEP-Open-128(NetworkAuthMethod) None
set WEP-Open-128(KeyId) 1

# WEP-SharedKey-40
set WEP-SharedKey-40(EncryptionMethod) WEP
set WEP-SharedKey-40(ApAuthMethod) SharedKey
set WEP-SharedKey-40(NetworkAuthMethod) None
set WEP-SharedKey-40(KeyId) 1

# WEP-SharedKey-128
set WEP-SharedKey-128(EncryptionMethod) WEP
set WEP-SharedKey-128(ApAuthMethod) SharedKey
set WEP-SharedKey-128(NetworkAuthMethod) None
set WEP-SharedKey-128(KeyId) 1

# WPA-EAP-TLS
set WPA-EAP-TLS(EncryptionMethod) TKIP 
set WPA-EAP-TLS(ApAuthMethod) Open
set WPA-EAP-TLS(NetworkAuthMethod) EAP/TLS 
set WPA-EAP-TLS(KeyId) 1 
set WPA-EAP-TLS(KeyType) ascii 

# WPA2-LEAP
set WPA2-LEAP(EncryptionMethod) AES-CCMP
set WPA2-LEAP(ApAuthMethod) Open
set WPA2-LEAP(NetworkAuthMethod) LEAP 
set WPA2-LEAP(KeyId) 1 
set WPA2-LEAP(KeyType) ascii 

# LEAP
set LEAP(EncryptionMethod) WEP
set LEAP(ApAuthMethod) Open
set LEAP(NetworkAuthMethod) LEAP
set LEAP(KeyId) 1 
set LEAP(KeyType) ascii 

# WPA-LEAP
set WPA-LEAP(EncryptionMethod) TKIP 
set WPA-LEAP(ApAuthMethod) Open
set WPA-LEAP(NetworkAuthMethod) LEAP 
set WPA-LEAP(KeyId) 1 
set WPA-LEAP(KeyType) ascii 

# DWEP-EAP-TTLS-GTC
set DWEP-EAP-TTLS-GTC(EncryptionMethod) WEP 
set DWEP-EAP-TTLS-GTC(ApAuthMethod) Open
set DWEP-EAP-TTLS-GTC(NetworkAuthMethod) EAP/TTLS-GTC 
set DWEP-EAP-TTLS-GTC(KeyId) 1 
set DWEP-EAP-TTLS-GTC(KeyType) ascii 

# DWEP-EAP-TLS
set DWEP-EAP-TLS(EncryptionMethod) WEP 
set DWEP-EAP-TLS(ApAuthMethod) Open
set DWEP-EAP-TLS(NetworkAuthMethod) EAP/TLS 
set DWEP-EAP-TLS(KeyId) 1 
set DWEP-EAP-TLS(KeyType) ascii 

# WPA2-EAP-FAST
set WPA2-EAP-FAST(EncryptionMethod) AES-CCMP
set WPA2-EAP-FAST(ApAuthMethod) Open
set WPA2-EAP-FAST(NetworkAuthMethod) EAP/FAST 
set WPA2-EAP-FAST(KeyId) 1 
set WPA2-EAP-FAST(KeyType) ascii 

# WPA2-PEAP-MSCHAPV2
set WPA2-PEAP-MSCHAPV2(EncryptionMethod) AES-CCMP
set WPA2-PEAP-MSCHAPV2(ApAuthMethod) Open
set WPA2-PEAP-MSCHAPV2(NetworkAuthMethod) PEAP/MSCHAPv2 
set WPA2-PEAP-MSCHAPV2(KeyId) 1 
set WPA2-PEAP-MSCHAPV2(KeyType) ascii 

# WPA2-EAP-TTLS-GTC
set WPA2-EAP-TTLS-GTC(EncryptionMethod) AES-CCMP 
set WPA2-EAP-TTLS-GTC(ApAuthMethod) Open
set WPA2-EAP-TTLS-GTC(NetworkAuthMethod) EAP/TTLS-GTC 
set WPA2-EAP-TTLS-GTC(KeyId) 1 
set WPA2-EAP-TTLS-GTC(KeyType) ascii 

# WPA2-EAP-TLS
set WPA2-EAP-TLS(EncryptionMethod) AES-CCMP 
set WPA2-EAP-TLS(ApAuthMethod) Open
set WPA2-EAP-TLS(NetworkAuthMethod) EAP/TLS 
set WPA2-EAP-TLS(KeyId) 1 
set WPA2-EAP-TLS(KeyType) ascii 

# WPA2-PSK
set WPA2-PSK(EncryptionMethod) AES-CCMP 
set WPA2-PSK(ApAuthMethod) Open
set WPA2-PSK(NetworkAuthMethod) PSK 
set WPA2-PSK(KeyId) 1 

# DWEP-EAP-FAST
set DWEP-EAP-FAST(EncryptionMethod) WEP 
set DWEP-EAP-FAST(ApAuthMethod) Open
set DWEP-EAP-FAST(NetworkAuthMethod) EAP/FAST 
set DWEP-EAP-FAST(KeyId) 1 
set DWEP-EAP-FAST(KeyType) ascii 

# DWEP-PEAP-MSCHAPV2
set DWEP-PEAP-MSCHAPV2(EncryptionMethod) WEP
set DWEP-PEAP-MSCHAPV2(ApAuthMethod) Open
set DWEP-PEAP-MSCHAPV2(NetworkAuthMethod) PEAP/MSCHAPv2 
set DWEP-PEAP-MSCHAPV2(KeyId) 1 
set DWEP-PEAP-MSCHAPV2(KeyType) ascii 

# WPA-EAP-TTLS-GTC
set WPA-EAP-TTLS-GTC(EncryptionMethod) TKIP 
set WPA-EAP-TTLS-GTC(ApAuthMethod) Open
set WPA-EAP-TTLS-GTC(NetworkAuthMethod) EAP/TTLS-GTC 
set WPA-EAP-TTLS-GTC(KeyId) 1 
set WPA-EAP-TTLS-GTC(KeyType) ascii 

# WPA-PSK
set WPA-PSK(EncryptionMethod) TKIP 
set WPA-PSK(ApAuthMethod) Open
set WPA-PSK(NetworkAuthMethod) PSK 
set WPA-PSK(KeyId) 1 

# WPA-EAP-FAST
set WPA-EAP-FAST(EncryptionMethod) TKIP 
set WPA-EAP-FAST(ApAuthMethod) Open
set WPA-EAP-FAST(NetworkAuthMethod) EAP/FAST 
set WPA-EAP-FAST(KeyId) 1 
set WPA-EAP-FAST(KeyType) ascii 

# WPA-PEAP-MSCHAPV2
set WPA-PEAP-MSCHAPV2(EncryptionMethod) TKIP
set WPA-PEAP-MSCHAPV2(ApAuthMethod) Open
set WPA-PEAP-MSCHAPV2(NetworkAuthMethod) PEAP/MSCHAPv2 
set WPA-PEAP-MSCHAPV2(KeyId) 1 
set WPA-PEAP-MSCHAPV2(KeyType) ascii 

# Combination Methods (WPA/WPA2 with alternate cyper)

# WPA-PSK-AES
set WPA-PSK-AES(EncryptionMethod) AES-CCMP
set WPA-PSK-AES(ApAuthMethod) Open
set WPA-PSK-AES(NetworkAuthMethod) PSK
set WPA-PSK-AES(KeyId) 1

# WPA-PEAP-MSCHAPV2-AES
set WPA-PEAP-MSCHAPV2-AES(EncryptionMethod) AES-CCMP
set WPA-PEAP-MSCHAPV2-AES(ApAuthMethod) Open
set WPA-PEAP-MSCHAPV2-AES(NetworkAuthMethod) PEAP/MSCHAPv2
set WPA-PEAP-MSCHAPV2-AES(KeyId) 1
set WPA-PEAP-MSCHAPV2-AES(KeyType) ascii

# WPA2-PEAP-MSCHAPV2-TKIP
set WPA2-PEAP-MSCHAPV2-TKIP(EncryptionMethod) TKIP
set WPA2-PEAP-MSCHAPV2-TKIP(ApAuthMethod) Open
set WPA2-PEAP-MSCHAPV2-TKIP(NetworkAuthMethod) PEAP/MSCHAPv2
set WPA2-PEAP-MSCHAPV2-TKIP(KeyId) 1
set WPA2-PEAP-MSCHAPV2-TKIP(KeyType) ascii

# WPA2-EAP-TLS-TKIP
set WPA2-EAP-TLS-TKIP(EncryptionMethod) TKIP
set WPA2-EAP-TLS-TKIP(ApAuthMethod) Open
set WPA2-EAP-TLS-TKIP(NetworkAuthMethod) EAP/TLS
set WPA2-EAP-TLS-TKIP(KeyId) 1
set WPA2-EAP-TLS-TKIP(KeyType) ascii

# WPA2-PSK-TKIP
set WPA2-PSK-TKIP(EncryptionMethod) TKIP
set WPA2-PSK-TKIP(ApAuthMethod) Open
set WPA2-PSK-TKIP(NetworkAuthMethod) PSK
set WPA2-PSK-TKIP(KeyId) 1

# CCKM *-PEAP-MSCHAPv2-*

set WPA-CCKM-PEAP-MSCHAPv2-TKIP(EncryptionMethod) TKIP
set WPA-CCKM-PEAP-MSCHAPv2-TKIP(ApAuthMethod) Open
set WPA-CCKM-PEAP-MSCHAPv2-TKIP(NetworkAuthMethod) PEAP/MSCHAPv2

set WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP(ApAuthMethod) Open
set WPA-CCKM-PEAP-MSCHAPv2-AES-CCMP(NetworkAuthMethod) PEAP/MSCHAPv2

set WPA2-CCKM-PEAP-MSCHAPv2-TKIP(EncryptionMethod) TKIP
set WPA2-CCKM-PEAP-MSCHAPv2-TKIP(ApAuthMethod) Open
set WPA2-CCKM-PEAP-MSCHAPv2-TKIP(NetworkAuthMethod) PEAP/MSCHAPv2

set WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP(ApAuthMethod) Open
set WPA2-CCKM-PEAP-MSCHAPv2-AES-CCMP(NetworkAuthMethod) PEAP/MSCHAPv2

# CCKM *-EAP-TLS-*

set WPA-CCKM-TLS-TKIP(EncryptionMethod) TKIP
set WPA-CCKM-TLS-TKIP(ApAuthMethod) Open
set WPA-CCKM-TLS-TKIP(NetworkAuthMethod) EAP/TLS

set WPA-CCKM-TLS-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA-CCKM-TLS-AES-CCMP(ApAuthMethod) Open
set WPA-CCKM-TLS-AES-CCMP(NetworkAuthMethod) EAP/TLS

set WPA2-CCKM-TLS-TKIP(EncryptionMethod) TKIP
set WPA2-CCKM-TLS-TKIP(ApAuthMethod) Open
set WPA2-CCKM-TLS-TKIP(NetworkAuthMethod) EAP/TLS

set WPA2-CCKM-TLS-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA2-CCKM-TLS-AES-CCMP(ApAuthMethod) Open
set WPA2-CCKM-TLS-AES-CCMP(NetworkAuthMethod) EAP/TLS

# CCKM *-LEAP-*
set WPA-CCKM-LEAP-TKIP(EncryptionMethod) TKIP
set WPA-CCKM-LEAP-TKIP(ApAuthMethod) Open
set WPA-CCKM-LEAP-TKIP(NetworkAuthMethod) LEAP

set WPA-CCKM-LEAP-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA-CCKM-LEAP-AES-CCMP(ApAuthMethod) Open
set WPA-CCKM-LEAP-AES-CCMP(NetworkAuthMethod) LEAP

set WPA2-CCKM-LEAP-TKIP(EncryptionMethod) TKIP
set WPA2-CCKM-LEAP-TKIP(ApAuthMethod) Open
set WPA2-CCKM-LEAP-TKIP(NetworkAuthMethod) LEAP

set WPA2-CCKM-LEAP-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA2-CCKM-LEAP-AES-CCMP(ApAuthMethod) Open
set WPA2-CCKM-LEAP-AES-CCMP(NetworkAuthMethod) LEAP

# CCKM *-EAP-FAST-*

set WPA-CCKM-FAST-TKIP(EncryptionMethod) TKIP
set WPA-CCKM-FAST-TKIP(ApAuthMethod) Open
set WPA-CCKM-FAST-TKIP(NetworkAuthMethod) EAP/FAST

set WPA-CCKM-FAST-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA-CCKM-FAST-AES-CCMP(ApAuthMethod) Open
set WPA-CCKM-FAST-AES-CCMP(NetworkAuthMethod) EAP/FAST

set WPA2-CCKM-FAST-TKIP(EncryptionMethod) TKIP
set WPA2-CCKM-FAST-TKIP(ApAuthMethod) Open
set WPA2-CCKM-FAST-TKIP(NetworkAuthMethod) EAP/FAST

set WPA2-CCKM-FAST-AES-CCMP(EncryptionMethod) AES-CCMP
set WPA2-CCKM-FAST-AES-CCMP(ApAuthMethod) Open
set WPA2-CCKM-FAST-AES-CCMP(NetworkAuthMethod) EAP/FAST
