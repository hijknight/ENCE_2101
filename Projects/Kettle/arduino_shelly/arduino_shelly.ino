#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "Resident_Wireless";

const char* password = ")h$1a3b5";

const char* shellyIP = "10.6.121.87";

unsigned long lastCheck = 0;

void checkShelly() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected");
    return;
  }

  HTTPClient http;

  String url = "http://" + String(shellyIP) + "/rpc/Switch.GetStatus?id=0";

  http.begin(url);
  http.setTimeout(3000);

  int response = http.GET();

  if (response == 200) {
    Serial.println("Shelly response: ");
    Serial.println(http.getString());
  } else {
    Serial.print("HTTP Error: ");
    Serial.println(response);
  } 

  http.end();
  
}



bool setShelly(bool on) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected");
    return false;
  }

  HTTPClient http;

  String url = "http://" + String(shellyIP)
             + "/rpc/Switch.Set?id=0&on="
             + (on ? "true" : "false");

  http.begin(url);
  http.setTimeout(3000);

  int response = http.GET();
  bool success = (response == 200);

  Serial.print(on ? "ON request: " : "OFF request: ");
  Serial.println(response);

  http.end();
  return success;
}


void setup() {
  
  Serial.begin(115200);
  delay(1500);

  Serial.println("Connecting to WiFi...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  unsigned long start = millis();

  while (WiFi.status() != WL_CONNECTED && millis() - start < 50000) {
    delay(500);
    Serial.print(".");
  }


  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println("WiFi connected!");
    Serial.print("Nano IP: ");
    Serial.println(WiFi.localIP());


    checkShelly();
  } else {
    Serial.println();
    Serial.println("WiFi connection failed");
  }
}


void loop() {
  // First, explicitly request OFF.
  setShelly(false);
  delay(2000);

  // Turn on for 3 seconds.
  if (setShelly(true)) {
    delay(3000);
  }

  // Turn off again.
  setShelly(false);
  checkShelly();

  // Stop the test rather than repeating it.
  while (true) {
    delay(1000);
  }
}

