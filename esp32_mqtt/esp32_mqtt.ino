#include <WiFi.h>
#include <PubSubClient.h>
#include <ESPmDNS.h>

// ==========================================
// CONFIGURAZIONE RETE E BROKER MQTT
// ==========================================
// Credenziali Wi-Fi (Modifica se necessario)
const char* ssid     = "iPhone di Riky";
const char* password = "A12345678";

// Broker MQTT Locale (IP del PC su cui gira NanoMQ)
const char* mqtt_server = "192.168.25.212"; 
const int   mqtt_port   = 1883;
const char* client_id   = "ESP32C3_Riky_UltraFast";

// Topic MQTT
const char* topic_status    = "riky_esp32/status";
const char* topic_commands  = "riky_esp32/commands";
const char* topic_telemetry = "riky_esp32/telemetry";
const char* topic_ping      = "riky_esp32/ping";
const char* topic_pong      = "riky_esp32/pong";

// Configurazione Hardware LED ESP32-C3
// Su quasi tutti i moduli ESP32-C3 (SuperMini / DevKit) il LED integrato e' sul GPIO 8 (attivo LOW)
#define LED_PIN 8
#define LED_ACTIVE_LOW true

// Client di rete
WiFiClient espClient;
PubSubClient client(espClient);

// Variabili di stato
bool currentLedState = false;
unsigned long lastMsg = 0;
unsigned long lastMqttRetry = 0;
unsigned long lastWifiRetry = 0;
int counter = 0;

// Macchina a stati per il lampeggio non-bloccante (Blink)
int  blinkRemaining = 0;
unsigned long blinkInterval = 200;
unsigned long lastBlinkToggle = 0;
bool blinkCurrentPhysical = false;

// ==========================================
// GESTIONE FISICA LED
// ==========================================
void applyLedHardware(bool on) {
  if (LED_ACTIVE_LOW) {
    digitalWrite(LED_PIN, on ? LOW : HIGH);
  } else {
    digitalWrite(LED_PIN, on ? HIGH : LOW);
  }
}

void setLed(bool on, bool publishUpdate = true) {
  currentLedState = on;
  blinkRemaining = 0; // Se c'era un lampeggio attivo, interrompilo
  applyLedHardware(currentLedState);

  if (publishUpdate && client.connected()) {
    char stat[64];
    snprintf(stat, sizeof(stat), "{\"led\":\"%s\",\"state\":%d}", on ? "ON" : "OFF", on ? 1 : 0);
    client.publish(topic_status, stat);
  }
}

void startBlink(int count, unsigned long intervalMs = 200) {
  blinkRemaining = count * 2; // Ogni lampeggio ha 2 transizioni (ON e OFF)
  blinkInterval = intervalMs;
  lastBlinkToggle = millis();
  blinkCurrentPhysical = true;
  applyLedHardware(blinkCurrentPhysical);
}

void publishFullStatus() {
  if (!client.connected()) return;
  char buf[192];
  snprintf(buf, sizeof(buf),
    "{\"status\":\"online\",\"firmware\":\"2.1.0-UltraFast\",\"led\":\"%s\",\"ip\":\"%s\",\"rssi\":%d,\"heap\":%lu}",
    currentLedState ? "ON" : "OFF",
    WiFi.localIP().toString().c_str(),
    WiFi.RSSI(),
    (unsigned long)ESP.getFreeHeap()
  );
  client.publish(topic_status, buf, true);
}

// ==========================================
// CALLBACK MQTT: ESECUZIONE SUB-MILLISECONDO
// ==========================================
void callback(char* topic, byte* payload, unsigned int length) {
  char msg[128];
  unsigned int len = (length < sizeof(msg) - 1) ? length : sizeof(msg) - 1;
  memcpy(msg, payload, len);
  msg[len] = '\0';

  // 1. GESTIONE TEST DI LATENZA PING / PONG
  if (strcmp(topic, topic_ping) == 0) {
    char pongBuf[128];
    snprintf(pongBuf, sizeof(pongBuf), "{\"pong\":\"%s\",\"esp_uptime_ms\":%lu}", msg, millis());
    client.publish(topic_pong, pongBuf);
    return;
  }

  // 2. GESTIONE COMANDI
  Serial.print("[MQTT Ricevuto] ");
  Serial.print(topic);
  Serial.print(" -> ");
  Serial.println(msg);

  // Parsing comandi semplici o JSON
  if (strcasecmp(msg, "ON") == 0 || strcmp(msg, "1") == 0 || strstr(msg, "\"ON\"") != NULL) {
    setLed(true);
    Serial.println("[LED] => ACCESO");
  } 
  else if (strcasecmp(msg, "OFF") == 0 || strcmp(msg, "0") == 0 || strstr(msg, "\"OFF\"") != NULL) {
    setLed(false);
    Serial.println("[LED] => SPENTO");
  } 
  else if (strcasecmp(msg, "TOGGLE") == 0 || strcasecmp(msg, "SWITCH") == 0) {
    setLed(!currentLedState);
    Serial.print("[LED] => COMMUTATO: ");
    Serial.println(currentLedState ? "ACCESO" : "SPENTO");
  } 
  else if (strncasecmp(msg, "BLINK", 5) == 0) {
    int blinks = 3;
    int interval = 200;
    // Supporto formato "BLINK:5:100" o "BLINK:5"
    if (strlen(msg) > 6 && msg[5] == ':') {
      sscanf(msg + 6, "%d:%d", &blinks, &interval);
      if (blinks <= 0) blinks = 3;
      if (interval < 50) interval = 50;
    }
    startBlink(blinks, interval);
    Serial.printf("[LED] => LAMPEGGIO avviato: %d volte (%d ms)\n", blinks, interval);
  } 
  else if (strcasecmp(msg, "STATUS") == 0) {
    publishFullStatus();
  } 
  else if (strcasecmp(msg, "REBOOT") == 0) {
    Serial.println("[SISTEMA] Riavvio richiesto via MQTT...");
    client.publish(topic_status, "{\"status\":\"rebooting\"}");
    delay(200);
    ESP.restart();
  }
}

// ==========================================
// RICONNESSIONE NON BLOCCANTE CON LWT
// ==========================================
void ensureMqttConnected() {
  if (client.connected()) return;

  unsigned long now = millis();
  if (now - lastMqttRetry > 2000) { // Tentativo ogni 2 secondi senza bloccare
    lastMqttRetry = now;
    Serial.print("[MQTT] Connessione a ");
    Serial.print(mqtt_server);
    Serial.print("...");

    // LWT (Last Will and Testament): se l'ESP32 perde improvvisamente la connessione,
    // il broker pubblichera' in automatico questo messaggio!
    const char* will_topic = topic_status;
    const char* will_payload = "{\"status\":\"offline\",\"reason\":\"lwt_disconnect\"}";
    int will_qos = 1;
    bool will_retain = true;

    if (client.connect(client_id, will_topic, will_qos, will_retain, will_payload)) {
      Serial.println(" CONNESSO!");
      
      // Iscrizione ai topic di comando e ping
      client.subscribe(topic_commands, 1);
      client.subscribe(topic_ping, 0);

      // Notifica stato online
      publishFullStatus();
      Serial.println("[MQTT] Topic sottoscritti con successo.");
    } else {
      Serial.print(" Errore rc=");
      Serial.println(client.state());
    }
  }
}

// ==========================================
// SETUP
// ==========================================
void setup() {
  pinMode(LED_PIN, OUTPUT);
  setLed(false, false); // Spento all'avvio

  Serial.begin(115200);
  delay(300);
  Serial.println("\n==============================================");
  Serial.println("   ESP32-C3 Local MQTT System - UltraFast     ");
  Serial.println("   Version 2.1.0 - Zero Latency Engine       ");
  Serial.println("==============================================");

  // OTTIMIZZAZIONE WI-FI: disattivazione risparmio energetico
  // Garantisce latenza costante < 5ms sui socket TCP/IP
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.begin(ssid, password);

  Serial.print("[WiFi] Connessione a: ");
  Serial.println(ssid);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 25) {
    delay(250);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WiFi] Connesso con successo!");
    Serial.print("[WiFi] IP Assegnato: ");
    Serial.println(WiFi.localIP());

    // mDNS: Permette di accedere usando "esp32-riky.local"
    if (MDNS.begin("esp32-riky")) {
      Serial.println("[mDNS] Host attivo su: esp32-riky.local");
    }
  } else {
    Serial.println("\n[WiFi] In attesa di segnale... riconnessione attiva in background.");
  }

  // Configurazione buffer e parametri MQTT
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  client.setBufferSize(768);
  client.setKeepAlive(30);
}

// ==========================================
// LOOP PRINCIPALE
// ==========================================
void loop() {
  unsigned long now = millis();

  // 1. GESTIONE LAMPEGGIO NON-BLOCCANTE
  if (blinkRemaining > 0) {
    if (now - lastBlinkToggle >= blinkInterval) {
      lastBlinkToggle = now;
      blinkCurrentPhysical = !blinkCurrentPhysical;
      applyLedHardware(blinkCurrentPhysical);
      blinkRemaining--;
      if (blinkRemaining == 0) {
        // Ripristina stato logico originale al termine
        applyLedHardware(currentLedState);
      }
    }
  }

  // 2. GESTIONE WI-FI E MQTT
  if (WiFi.status() == WL_CONNECTED) {
    ensureMqttConnected();
    client.loop(); // Processamento pacchetti istantaneo

    // Invio telemetria periodica (ogni 3 secondi)
    if (client.connected() && (now - lastMsg >= 3000)) {
      lastMsg = now;
      char payload[160];
      snprintf(payload, sizeof(payload), 
        "{\"uptime\":%lu,\"count\":%d,\"rssi\":%d,\"heap\":%lu,\"led\":\"%s\",\"ip\":\"%s\"}", 
        now / 1000, 
        counter++, 
        WiFi.RSSI(), 
        (unsigned long)ESP.getFreeHeap(),
        currentLedState ? "ON" : "OFF",
        WiFi.localIP().toString().c_str()
      );
      client.publish(topic_telemetry, payload);
    }
  } else {
    // Riconnessione Wi-Fi non bloccante
    if (now - lastWifiRetry > 5000) {
      lastWifiRetry = now;
      Serial.println("[WiFi] Tentativo riconnessione Wi-Fi in corso...");
      WiFi.reconnect();
    }
  }
}
