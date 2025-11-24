package com.chtrembl;

import java.util.*;

import com.azure.core.util.BinaryData;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.microsoft.azure.functions.annotation.*;
import com.microsoft.azure.functions.*;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Azure Functions with HTTP Trigger.
 */
public class OrderItemReserverFunction {
    /**
     * This function listens at endpoint "/api/HttpTriggerJava". Two ways to invoke it using "curl" command in bash:
     * 1. curl -d "HTTP Body" {your host}/api/HttpTriggerJava
     * 2. curl {your host}/api/HttpTriggerJava?name=HTTP%20Query
     */
    @FunctionName("OrderItemReserver")
    public HttpResponseMessage run(
            @HttpTrigger(name = "req", methods = {HttpMethod.POST}, authLevel = AuthorizationLevel.FUNCTION) HttpRequestMessage<Optional<String>> request,
            final ExecutionContext context) {
        context.getLogger().info("Java HTTP trigger processed a request.");

        String body = request.getBody().orElse(null);
        if (body == null) {
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST).body("Please pass an Order JSON in the request body").build();
        }
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            Order order = objectMapper.readValue(body, Order.class);
            context.getLogger().info("Received Order: " + order);

            String connectStr = System.getenv("AZURE_STORAGE_CONNECTION_STRING");
            if (connectStr == null || connectStr.isEmpty()) {
                context.getLogger().severe("Azure Storage connection string is not set.");
                return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR).body("Azure Storage connection string is not set.").build();
            }
            String containerName = "orders";
            String blobName = "order-" + order.id() + ".json";

            BlobServiceClient blobServiceClient = new BlobServiceClientBuilder().connectionString(connectStr).buildClient();
            BlobContainerClient containerClient = blobServiceClient.getBlobContainerClient(containerName);
            if (!containerClient.exists()) {
                containerClient.create();
            }
            BlobClient blobClient = containerClient.getBlobClient(blobName);
            blobClient.upload(BinaryData.fromString(body));

            context.getLogger().info("Order JSON saved to blob: " + blobName);
            return request.createResponseBuilder(HttpStatus.OK).body("Order JSON saved to blob: " + blobName).build();
        } catch (Exception e) {
            context.getLogger().severe("Failed to parse Order: " + e.getMessage());
            return request.createResponseBuilder(HttpStatus.BAD_REQUEST).body("Invalid Order JSON: " + e.getMessage()).build();
        }
    }
}
