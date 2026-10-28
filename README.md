# ⚡ ESP32 Local MQTT System (Zero-Latency)

Un sistema completo, ultra-veloce e pronto all'uso per la comunicazione bidirezionale tra **ESP32** (ESP32-C3 / Standard / S3) e un **Broker MQTT Locale (NanoMQ)** su rete Wi-Fi.

---

## 🚀 Caratteristiche Principali

- **Latenza Zero (< 5ms)**: Risparmio energetico Wi-Fi disattivato (`WiFi.setSleep(false)`) e ricezione istantanea dei comandi.
- **Riconnessione Non Bloccante**: Niente blocchi o freeze del microcontroller in caso di disconnessione Wi-Fi o MQTT.
- **Broker Locale Portable (NanoMQ)**: Nessuna installazione richiesta, consuma meno di 10MB di RAM ed è già pronto con script di avvio a 1 clic.
- **Strumenti CLI inclusi**: Script per monitorare la telemetria in tempo reale e inviare comandi (ON/OFF) all'ESP32.

---

## 📁 Struttura del Progetto

```
esp32-mqtt-broker/
├── esp32_mqtt/
│   └── esp32_mqtt.ino        # Firmware ottimizzato per ESP32-C3
├── server/
│   ├── avvia_server.bat      # Avvia il broker MQTT e mostra l'IP locale
│   ├── ascolta_messaggi.bat  # Monitor telemetria in tempo reale
│   ├── invia_comando.bat     # Menu per inviare comandi ON/OFF/testo
│   ├── bin/                  # Binari standalone NanoMQ
│   └── config/               # Configurazione NanoMQ
├── carica_su_github.bat      # Script automatico per caricare su GitHub
├── .gitignore
└── README.md
```

---

## 🛠️ Come Usarlo in 3 Passi

### 1. Avvia il Broker MQTT Locale
Fai doppio clic su `server/avvia_server.bat`.  
La finestra mostrerà l'indirizzo IP locale del tuo computer (es. `192.168.25.212`) e avvierà il broker sulla porta `1883`.

### 2. Configura e Carica il Firmware sull'ESP32
Apri `esp32_mqtt/esp32_mqtt.ino` con **Arduino IDE** (oppure caricalo da terminale):
```cpp
const char* ssid = "NomeTuoWiFi";
const char* password = "TuaPassword";
const char* mqtt_server = "192.168.25.212"; // Inserisci l'IP del tuo PC
```
Carica lo sketch sulla scheda (**ESP32C3 Dev Module**).

> [!IMPORTANT]
> **Stessa Rete Wi-Fi**: L'ESP32 e il computer DEVONO essere connessi alla stessa rete.  
> Se usi l'hotspot dell'iPhone, ricordati di abilitare **"Ottimizza compatibilità"** nelle impostazioni dell'hotspot (l'ESP32 supporta solo i 2.4 GHz).

### 3. Invia Comandi e Ricevi Telemetria
- Esegui `server/ascolta_messaggi.bat` per vedere in diretta i dati inviati dall'ESP32 sul topic `riky_esp32/telemetry`.
- Esegui `server/invia_comando.bat` per accendere (`ON`) o spegnere (`OFF`) il LED dell'ESP32.

---

## 📡 Topic MQTT Utilizzati

| Topic | Direzione | Descrizione |
|---|---|---|
| `riky_esp32/telemetry` | ESP32 ➔ Broker | Telemetria (uptime, RSSI, contatore, IP) |
| `riky_esp32/status` | ESP32 ➔ Broker | Stato dispositivo (`online`, `LED: ON`, `LED: OFF`) |
| `riky_esp32/commands` | Broker ➔ ESP32 | Ricezione comandi immediati (`ON`, `OFF`) |

---

## 🛡️ Firewall di Windows (Porta 1883)
Se l'ESP32 non riesce a connettersi al broker locale, sblocca la porta 1883 aprendo **PowerShell come Amministratore**:
```powershell
New-NetFirewallRule -DisplayName "MQTT Broker 1883" -Direction Inbound -LocalPort 1883 -Protocol TCP -Action Allow
```
