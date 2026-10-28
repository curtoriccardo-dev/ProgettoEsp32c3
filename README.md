# ⚡ ESP32-C3 Local MQTT System & Real-Time Dashboard (v2.1)

Un ecosistema IoT professionale, completo e ultra-veloce a **latenza zero (< 5ms)** per **ESP32-C3** (e compatibili ESP32 / S3), abbinato a un **Broker MQTT Locale Portable (NanoMQ)** e a una **Web Dashboard moderna con WebSockets**.

![ESP32-C3 MQTT](https://img.shields.io/badge/ESP32--C3-UltraFast-blue?style=for-the-badge&logo=espressif)
![Broker NanoMQ](https://img.shields.io/badge/Broker-NanoMQ%20v0.19-green?style=for-the-badge)
![Latency Zero](https://img.shields.io/badge/Latency-%3C5ms-brightgreen?style=for-the-badge)
![WebSockets](https://img.shields.io/badge/Web-Dashboard%20Realtime-orange?style=for-the-badge)

---

## 🌟 Principali Novità e Miglioramenti (v2.1)

- 🌐 **Web Dashboard Interattiva (Zero Dipendenze)**:
  - Si apre in qualunque browser senza installare Node.js né server web.
  - Connessione bidirezionale in tempo reale via **WebSockets (`ws://localhost:8083/mqtt`)**.
  - Interruttore animato del LED con feedback di stato istantaneo.
  - Indicatore di segnale Wi-Fi (RSSI), memoria RAM residua (Heap), uptime e contatore pacchetti.
  - **Console Live**: Monitor dei pacchetti MQTT in transito con invio comandi personalizzati.
- ⚡ **Misuratore di Latenza Ping/Pong Sub-Millisecondo**:
  - Il broker invia un token su `riky_esp32/ping` e l'ESP32 risponde all'istante su `riky_esp32/pong`, misurando il tempo esatto di andata e ritorno (Round-Trip Time).
- 🛡️ **MQTT LWT (Last Will and Testament)**:
  - Se l'ESP32 viene scollegato o perde alimentazione, il broker notifica all'istante lo stato `"offline"` alla dashboard.
- 💡 **Motore Comandi & Lampeggio Non-Bloccante**:
  - Supporto per comandi: `ON`, `OFF`, `TOGGLE`, `BLINK:<volte>:<intervallo>`, `STATUS`, `REBOOT`.
  - Motore di lampeggio gestito con macchina a stati (`millis()`), senza congelare il loop del microcontrollore.
- 🚀 **1-Click Flasher Diretto (`carica_su_esp32.bat`)**:
  - Compila e carica il codice direttamente sull'ESP32-C3 via CLI senza bisogno di aprire Arduino IDE o configurare manualmente parametri del chip.
- 🏷️ **mDNS Auto-Discovery**:
  - La scheda annuncia la propria presenza sulla rete locale come `esp32-riky.local`.

---

## 📁 Struttura del Progetto

```
esp32-mqtt-broker/
│
├── esp32_mqtt/
│   └── esp32_mqtt.ino           # Firmware C++ ottimizzato per ESP32-C3
│
├── server/
│   ├── dashboard/
│   │   ├── index.html           # Web Dashboard moderna (HTML5/CSS3/JS)
│   │   └── mqtt.min.js          # Libreria MQTT WebSocket offline
│   ├── bin/
│   │   ├── nanomq.exe           # Broker MQTT nativo ultra-leggero
│   │   ├── nanomq_cli.exe       # Utility CLI pub/sub
│   │   ├── nngcat.exe
│   │   └── libwinpthread-1.dll
│   ├── config/
│   │   └── nanomq.conf          # Configurazione TCP (1883) e WebSocket (8083)
│   ├── apri_dashboard.bat       # Avvia la Web Dashboard nel browser
│   ├── avvia_server.bat         # Avvia solo il broker NanoMQ
│   ├── ascolta_messaggi.bat     # Monitor CLI in tempo reale
│   └── invia_comando.bat        # Menu interattivo invio comandi
│
├── avvia_tutto.bat              # 🔥 1-CLICK: Avvia Broker + Dashboard insieme
├── carica_su_esp32.bat          # 🔥 1-CLICK: Compila e carica su ESP32-C3
├── invia_su_github.bat          # 🔥 1-CLICK: Sincronizza tutto su GitHub
├── .gitignore
└── README.md
```

---

## 🚀 Guida Rapida all'Uso

### 1. Avvia il Sistema con 1 Clic
Fai doppio clic su **`avvia_tutto.bat`**.  
Questo script:
1. Avvia il broker MQTT NanoMQ sulla porta `1883` e WebSockets sulla porta `8083`.
2. Mostra gli indirizzi IP locali del tuo PC.
3. Apre automaticamente la **Web Dashboard** nel tuo browser.

### 2. Carica il Firmware sull'ESP32-C3 (Senza IDE)
1. Collega la scheda ESP32-C3 alla porta USB del PC.
2. Verifica in `esp32_mqtt/esp32_mqtt.ino` che SSID, password Wi-Fi e `mqtt_server` siano corretti.
3. Fai doppio clic su **`carica_su_esp32.bat`**: la compilazione e il flashing avvengono in modo totalmente automatico!

> [!NOTE]
> Su ESP32-C3 (SuperMini / DevKit) il LED integrato si trova solitamente su **GPIO 8** ed è attivo **LOW**. Il codice gestisce automaticamente l'inversione logica.

### 3. Controlla e Monitora
Dalla **Web Dashboard** puoi:
- Premere la lampadina o i pulsanti **ACCENDI / SPEGNI / TOGGLE / LAMPEGGIA** per vedere il LED reagire all'istante (< 5 ms).
- Cliccare **TEST LATENZA (PING)** per verificare i millisecondi esatti di risposta della scheda.
- Consultare la memoria RAM libera (Heap) e l'indice di ricezione Wi-Fi (RSSI).

---

## 📡 Tabella Topic MQTT

| Topic | Direzione | Payload di Esempio | Descrizione |
|---|---|---|---|
| `riky_esp32/telemetry` | ESP32 ➔ Broker | `{"uptime":45,"rssi":-52,"heap":294120,"led":"ON"}` | Telemetria ogni 3 secondi |
| `riky_esp32/status` | ESP32 ➔ Broker | `{"status":"online","firmware":"2.1.0","led":"ON"}` | Stato dispositivo & LWT (`offline`) |
| `riky_esp32/commands` | Client ➔ ESP32 | `ON`, `OFF`, `TOGGLE`, `BLINK:3:150`, `STATUS` | Comandi immediati |
| `riky_esp32/ping` | Client ➔ ESP32 | `1730113829000` | Richiesta calcolo latenza |
| `riky_esp32/pong` | ESP32 ➔ Client | `{"pong":"1730113829000","esp_uptime_ms":45201}` | Risposta istantanea di rimbalzo |

---

## 🛠️ Risoluzione Problemi Comuni

- **Firewall di Windows blocca la porta 1883 o 8083**:
  Apri PowerShell come Amministratore ed esegui:
  ```powershell
  New-NetFirewallRule -DisplayName "MQTT Broker 1883" -Direction Inbound -LocalPort 1883 -Protocol TCP -Action Allow
  New-NetFirewallRule -DisplayName "MQTT WebSockets 8083" -Direction Inbound -LocalPort 8083 -Protocol TCP -Action Allow
  ```
- **Hotspot iPhone**:
  Ricordati di attivare l'opzione **"Ottimizza compatibilità"** nelle impostazioni dell'Hotspot personale su iOS (permette la connessione alle reti 2.4 GHz usate dall'ESP32).

---

## 💻 Licenza
Rilasciato per uso personale e di studio da Riccardo Curto.
Repository ufficiale: [GitHub ProgettoEsp32c3](https://github.com/curtoriccardo-dev/ProgettoEsp32c3)
