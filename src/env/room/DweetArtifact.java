package room;

import cartago.Artifact;
import cartago.OPERATION;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

    private static final String DWEET_URL = "https://dweet.io/dweet/for/";
    private static final HttpClient client = HttpClient.newHttpClient();

    void init() {
        System.out.println("Dweet artifact initialized");
    }

    @OPERATION
    void sendMessage(String message) {

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(DWEET_URL))
                .POST(HttpRequest.BodyPublishers.ofString(message))
                .build();

        try {
            HttpResponse response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                System.out.println("Message sent successfully");
            } else {
                System.out.println("Failed to send message");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
