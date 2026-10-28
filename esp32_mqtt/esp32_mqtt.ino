#include <WiFi.h>
#include <PubSubClient.h>

// ==========================================
// CONFIGURAZIONE RETE E BROKER MQTT
// ==========================================
// Wi-Fi Config
const char* ssid = "iPhone di Riky";
const char* password = "A12345678";

// MQTT Broker Locale (IP del PC con NanoMQ)
const char* mqtt_server = "192.168.25.212"; 
const int mqtt_port = 1883;
const char* client_id = "ESP32C3_Riky_UltraFast";

// Topics
const char* topic_status    = "riky_esp32/status";
const char* topic_commands  = "riky_esp32/commands";
const char* topic_telemetry = "riky_esp32/telemetry";

// LED ESP32-C3 (GPIO 8 attivo LOW)
#define LED_PIN 8

WiFiClient espClient;
PubSubClient client(espClient);

unsigned long lastMsg = 0;
unsigned long lastMqttRetry = 0;
int counter = 0;

// ==========================================
// CALLBACK: ESECUZIONE ISTANTANEA COMANDI
// ==========================================
void callback(char* topic, byte* payload, unsigned int length) {
  char msg[64];
  unsigned int len = (length < sizeof(msg) - 1) ? length : sizeof(msg) - 1;
  memcpy(msg, payload, len);
  msg[len] = '\0';

  Serial.print("[MQTT Ricevuto] ");
  Serial.print(topic);
  Serial.print(" -> ");
  Serial.println(msg);

  // Risposta a latenza zero
  if (strcasecmp(msg, "ON") == 0 || strcmp(msg, "1") == 0) {
    digitalWrite(LED_PIN, LOW); // LED Acceso (attivo LOW)
    client.publish(topic_status, "{\"led\":\"ON\"}");
    Serial.println("[LED] => ACCESO");
  } else if (strcasecmp(msg, "OFF") == 0 || strcmp(msg, "0") == 0) {
    digitalWrite(LED_PIN, HIGH); // LED Spento
    client.publish(topic_status, "{\"led\":\"OFF\"}");
    Serial.println("[LED] => SPENTO");
  }
}

// ==========================================
// RICONNESSIONE NON BLOCCANTE (ZERO FREEZE)
// ==========================================
void ensureMqttConnected() {
  if (client.connected()) return;

  unsigned long now = millis();
  if (now - lastMqttRetry > 2000) { // Riprova ogni 2 secondi senza bloccare il loop
    lastMqttRetry = now;
    Serial.print("[MQTT] Connessione a ");
    Serial.print(mqtt_server);
    Serial.print("...");

    if (client.connect(client_id)) {
      Serial.println(" CONNESSO!");
      client.publish(topic_status, "{\"status\":\"online\"}", true);
      client.subscribe(topic_commands, 1);
      Serial.print("[MQTT] In ascolto su: ");
      Serial.println(topic_commands);
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
  digitalWrite(LED_PIN, HIGH); // Spento inizialmente

  Serial.begin(115200);
  delay(500);
  Serial.println("\n======================================");
  Serial.println("  ESP32-C3 MQTT Client - UltraFast    ");
  Serial.println("======================================");

  // OTTIMIZZAZIONE LATENZA: disattiva il risparmio energetico Wi-Fi
  // Riduce la latenza da ~500ms a meno di 5ms!
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.begin(ssid, password);

  Serial.print("[WiFi] Connessione a: ");
  Serial.println(ssid);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 25) {
    delay(300);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WiFi] Connesso con successo!");
    Serial.print("[WiFi] IP ESP32: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WiFi] In attesa di segnale... continuera' in background.");
  }

  // Ottimizzazione MQTT buffer e KeepAlive
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  client.setBufferSize(512);
  client.setKeepAlive(60);
}

// ==========================================
// LOOP PRINCIPALE
// ==========================================
void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    ensureMqttConnected();
    client.loop(); // Elabora pacchetti MQTT all'istante

    // Invia telemetria ogni 3 secondi senza bloccare
    unsigned long now = millis();
    if (client.connected() && (now - lastMsg >= 3000)) {
      lastMsg = now;
      char payload[96];
      snprintf(payload, sizeof(payload), 
        "{\"uptime\":%lu,\"count\":%d,\"rssi\":%d,\"ip\":\"%s\"}", 
        now / 1000, counter++, WiFi.RSSI(), WiFi.localIP().toString().c_str());
      client.publish(topic_telemetry, payload);
    }
  } else {
    // Riconnessione Wi-Fi non bloccante
    static unsigned long lastWifiRetry = 0;
    if (millis() - lastWifiRetry > 5000) {
      lastWifiRetry = millis();
      Serial.println("[WiFi] Tentativo riconnessione Wi-Fi...");
      WiFi.reconnect();
    }
  }
}
