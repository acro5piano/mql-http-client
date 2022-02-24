// vim:set ft=cs :

#include "hash.mqh"
#include "json.mqh"

extern string EA_NAME = "RequestClient";
extern string SERVER_IP = "172.31.31.100";

string SendResquest(string httpType, string url, string bodyData = "", string headers = "", int timeout = 10000)
{
    uchar bodyDataCharArray[];
    uchar resultDataCharArray[];
    string resultHeader;

    ArrayResize(bodyDataCharArray, StringToCharArray(bodyData, bodyDataCharArray) - 1);

    int response = WebRequest(httpType, url, headers, timeout, bodyDataCharArray, resultDataCharArray, resultHeader);
    if(response != 200) {
        Print("Error when trying to call API: ", response);
        Print("Error code: ", GetLastError());
        Print("url: ", url);
        Print("body: ", bodyData);
        return "";
    }
    Print("API result:", response);

    return CharArrayToString(resultDataCharArray);
}

// Example code to send web requests to your own server, probably written in Python or something.
void OnTick() {
    string priceAsk = DoubleToStr(MarketInfo(0, MODE_ASK), 5);
    string priceBid = DoubleToStr(MarketInfo(0, MODE_BID), 5);
    string body = StringFormat("{ \"symbol\": \"%s\", \"ask\": %s, \"bid\": %s }", Symbol(), priceAsk, priceBid);
    string url = StringFormat("http://%s/trade", SERVER_IP);
    string response = SendResquest("POST", url, body, "Content-Type: application/json", 5000);

    JSONParser *parser = new JSONParser();
    JSONValue *jv = parser.parse(response);
    JSONObject *jo = jv;


    JSONArray *actions = jo.getArray("actions");      // Get Array
    JSONObject *action = actions.getObject("action"); // Get Object
    string type =  action.getString("string_field");  // Get String
    int magicNumber =  action.getInt("int_field");    // Get Number

    // Code goes on, auto trade with your own language?
}
