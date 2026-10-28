# ⚡ ESP32-C3 Local MQTT System & IoT MQTT Panel

Un ecosistema IoT completo e ultra-veloce a **latenza zero (< 5ms)** per **ESP32-C3** con Broker MQTT locale (**NanoMQ**) e supporto nativo per l'app mobile **IoT MQTT Panel** (iOS & Android).

![ESP32-C3](https://img.shields.io/badge/ESP32--C3-UltraFast-blue?style=for-the-badge&logo=espressif)
![IoT MQTT Panel](https://img.shields.io/badge/App-IoT%20MQTT%20Panel-orange?style=for-the-badge)
![Broker NanoMQ](https://img.shields.io/badge/Broker-NanoMQ%20v0.19-green?style=for-the-badge)
![Latency Zero](https://img.shields.io/badge/Latency-%3C5ms-brightgreen?style=for-the-badge)

---

## 📱 Configurazione dell'App "IoT MQTT Panel"

L'intero sistema è pronto per essere controllato direttamente dal tuo smartphone tramite l'app **IoT MQTT Panel**.

### 1. Connessione al Broker
Apri l'app **IoT MQTT Panel** sul tuo smartphone e aggiungi una nuova connessione:

- **Connection Name**: `ESP32 NanoMQ`
- **Broker Web/IP address**:
  - Se usi l'Hotspot dell'iPhone: **`172.20.10.13`**
  - Se sei sulla rete Wi-Fi di casa: **`192.168.25.212`**
- **Port**: **`1883`**
- **Network Protocol**: `TCP`
- **Client ID**: lascia vuoto o imposta `Phone_Client`
- **Username / Password**: lascia vuoti (accesso libero abilitato)

> [!IMPORTANT]
> **Sbloccare il Firewall di Windows**:  
> Affinché lo smartphone possa comunicare con il PC sulla porta 1883, esegui **`sblocca_firewall.bat`** presente sul tuo Desktop (richiede 1 clic su "Sì" per autorizzare).

---

### 2. Creazione dei Widget nell'App

Nel pannello della tua app puoi aggiungere i seguenti widget:

#### 💡 1. Switch Widget (Interruttore ON/OFF LED)
- **Nome**: `LED ESP32`
- **Topic di Pubblicazione** (*Topic to publish*): `riky_esp32/commands`
- **Payload ON**: `ON`
- **Payload OFF**: `OFF`
- **Topic di Ricezione Stato** (*Topic to subscribe*): `riky_esp32/led`
*(Lo switch si aggiornerà in tempo reale sia quando premi il pulsante sull'app sia quando la scheda cambia stato)*

#### ⚡ 2. Button Widget (Lampeggio Rapido 3x)
- **Nome**: `Lampeggia 3x`
- **Topic**: `riky_esp32/commands`
- **Payload**: `BLINK:3:150`

#### 📶 3. Text / Progress Widget (Segnale Wi-Fi RSSI)
- **Nome**: `Segnale Wi-Fi`
- **Topic to subscribe**: `riky_esp32/rssi`

#### ⏱️ 4. Text Widget (Tempo di Attività Uptime)
- **Nome**: `Uptime`
- **Topic to subscribe**: `riky_esp32/uptime`

---

## 📁 Struttura del Progetto

```
esp32-mqtt-broker/
│
├── esp32_mqtt/
│   └── esp32_mqtt.ino           # Firmware ESP32-C3 multi-topic per IoT MQTT Panel
│
├── server/
│   ├── dashboard/               # Web Dashboard opzionale (HTML5/WebSocket)
│   ├── bin/                     # Broker NanoMQ portatile
│   ├── config/                  # Configurazione NanoMQ (TCP 1883 + WS 8083)
│   ├── avvia_server.bat         # Avvia solo il broker
│   ├── ascolta_messaggi.bat     # Monitor CLI dei pacchetti
│   └── invia_comando.bat        # Menu comandi da terminale
│
├── avvia_tutto.bat              # 🔥 Avvia il broker NanoMQ e mostra gli IP locali
├── carica_su_esp32.bat          # 🔥 Compila e carica su ESP32-C3 senza IDE
├── sblocca_firewall.bat         # 🛡️ Sblocca la porta 1883 per far connettere l'app del telefono
├── invia_su_github.bat          # 🚀 Sincronizza tutto su GitHub
├── .gitignore
└── README.md
```

---

## 📡 Tabella Topic MQTT

| Topic | Tipo Payload | Direzione | Descrizione |
|---|---|---|---|
| `riky_esp32/commands` | Testo (`ON`, `OFF`, `TOGGLE`, `BLINK:3:150`) | App ➔ ESP32 | Invia comandi di controllo |
| `riky_esp32/led` | Testo (`ON` o `OFF`) | ESP32 ➔ App | Stato retained per Switch Widget |
| `riky_esp32/rssi` | Testo (es. `-55 dBm`) | ESP32 ➔ App | Potenza segnale Wi-Fi per widget testo |
| `riky_esp32/uptime` | Testo (es. `120 s`) | ESP32 ➔ App | Tempo di attività per widget testo |
| `riky_esp32/telemetry` | JSON completo | ESP32 ➔ Broker | Telemetria strutturata ogni 3 secondi |
| `riky_esp32/status` | JSON completo | ESP32 ➔ Broker | Stato scheda e Last Will and Testament |

---

## 💻 Licenza & Repository
Repository GitHub: [https://github.com/curtoriccardo-dev/ProgettoEsp32c3.git](https://github.com/curtoriccardo-dev/ProgettoEsp32c3.git)  
Sviluppato da Riccardo Curto.
