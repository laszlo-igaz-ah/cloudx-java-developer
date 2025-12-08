package com.chtrembl.petstoreapp.service;

import com.azure.messaging.servicebus.ServiceBusMessage;
import com.azure.messaging.servicebus.ServiceBusSenderClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Service for sending events to Azure Service Bus.
 * Handles sending order and other event messages to configured Service Bus topics/queues.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ServiceBusEventSender {

    private final ServiceBusSenderClient serviceBusSenderClient;

    @Value("${petstore.servicebus.queue-name:orders}")
    private String queueName;

    /**
     * Sends an order event message to Azure Service Bus queue
     *
     * @param messageContent The JSON content to send (typically serialized Order object)
     */
    public void sendOrderEvent(String messageContent) {
        try {
            if (messageContent == null || messageContent.isEmpty()) {
                log.warn("Attempted to send empty message to Service Bus queue: {}", queueName);
                return;
            }

            log.info("Sending order event to Service Bus queue: {}", queueName);

            // Send the message to the Service Bus queue
            // ServiceBusTemplate handles the message creation and sending
            serviceBusSenderClient.sendMessage(new ServiceBusMessage(messageContent));

            log.info("Successfully sent order event to Service Bus queue: {}", queueName);

        } catch (Exception e) {
            log.error("Failed to send order event to Service Bus queue: {}", queueName, e);
            throw new RuntimeException("Failed to send message to Service Bus", e);
        }
    }
}

