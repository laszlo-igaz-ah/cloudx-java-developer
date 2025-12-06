package com.chtrembl;

import java.util.*;

import com.azure.core.util.BinaryData;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.microsoft.azure.functions.annotation.*;
import com.microsoft.azure.functions.*;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Azure Functions with HTTP Trigger and EventHub Trigger.
 * This function processes orders from both HTTP requests and EventHub events.
 */
public class OrderItemReserverFunction {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    private static final String CONTAINER_NAME = "orders";

    /**
     * HTTP Trigger function that listens at endpoint "/api/OrderItemReserver"
     * Two ways to invoke it using "curl" command in bash:
     * 1. curl -d "HTTP Body" {your host}/api/OrderItemReserver
     * 2. curl -X POST -H "Content-Type: application/json" -d @order.json {your host}/api/OrderItemReserver
     */
    @FunctionName("OrderItemReserver")
    public HttpResponseMessage httpTrigger(
            @HttpTrigger(name = "req", methods = {HttpMethod.POST}, authLevel = AuthorizationLevel.FUNCTION) HttpRequestMessage<Optional<String>> request,
            final ExecutionContext context) {
        context.getLogger().info("HTTP Trigger: Processing order request");

        String body = request.getBody().orElse(null);
        if (body == null) {
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                    .body("Please pass an Order JSON in the request body")
                    .build();
        }

        try {
            Order order = OBJECT_MAPPER.readValue(body, Order.class);
            context.getLogger().info("HTTP Trigger: Received Order: " + order);

            String result = processOrder(order, body, context);
            return request.createResponseBuilder(HttpStatus.OK)
                    .body(result)
                    .build();
        } catch (Exception e) {
            context.getLogger().severe("HTTP Trigger: Failed to parse Order: " + e.getMessage());
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                    .body("Invalid Order JSON: " + e.getMessage())
                    .build();
        }
    }

    /**
     * EventHub Trigger function that processes orders from EventHub
     * The EventHub message should contain an Order JSON object
     */
    @FunctionName("OrderItemReserverEventHub")
    public void eventHubTrigger(
            @EventHubTrigger(name = "message",
                           eventHubName = "orders",
                           connection = "EventHubConnectionString")
            String message,
            final ExecutionContext context) {
        context.getLogger().info("EventHub Trigger: Processing order event");

        if (message == null || message.isEmpty()) {
            context.getLogger().warning("EventHub Trigger: Received empty message");
            return;
        }

        try {
            Order order = OBJECT_MAPPER.readValue(message, Order.class);
            context.getLogger().info("EventHub Trigger: Received Order: " + order);

            processOrder(order, message, context);
        } catch (Exception e) {
            context.getLogger().severe("EventHub Trigger: Failed to parse Order: " + e.getMessage());
            throw new RuntimeException("Failed to process EventHub message", e);
        }
    }

    /**
     * Shared logic for processing orders
     * Deserializes the Order object and saves it to Azure Blob Storage
     *
     * @param order The Order object to process
     * @param body The original JSON string to save
     * @param context The execution context for logging
     * @return A message indicating the result of the operation
     * @throws Exception if the operation fails
     */
    private String processOrder(Order order, String body, ExecutionContext context) throws Exception {
        if (order.id() == null || order.id().isEmpty()) {
            throw new IllegalArgumentException("Order ID is required");
        }

        String connectStr = System.getenv("AZURE_STORAGE_CONNECTION_STRING");
        if (connectStr == null || connectStr.isEmpty()) {
            context.getLogger().severe("Azure Storage connecton string is not seit.");
            throw new IllegalStateException("Azure Storage connection string is not set.");
        }

        String blobName = "order-" + order.id() + ".json";

        BlobServiceClient blobServiceClient = new BlobServiceClientBuilder()
                .connectionString(connectStr)
                .buildClient();
        BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(CONTAINER_NAME);

        if (!containerClient.exists()) {
            context.getLogger().info("Creating blob container: " + CONTAINER_NAME);
            containerClient.create();
        }

        BlobClient blobClient = containerClient.getBlobClient(blobName);
        blobClient.upload(BinaryData.fromString(body), true);

        String successMessage = "Order JSON saved to blob: " + blobName;
        context.getLogger().info(successMessage);
        return successMessage;
    }
}
