package com.chtrembl.petstore.order.service;

import com.chtrembl.petstore.order.model.Order;
import com.chtrembl.petstore.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor
public class CacheService {

    private final OrderRepository orderRepository;

    /**
     * Saves an order to Cosmos DB
     *
     * @param order the order to save
     * @return the saved order
     */
    public Order saveOrder(Order order) {
        log.info("Saving order to Cosmos DB: {}", order.getId());
        try {
            return orderRepository.save(order);
        } catch (Exception e) {
            log.error("Failed to save order: {}", order.getId(), e);
            throw new RuntimeException("Failed to persist order to Cosmos DB", e);
        }
    }

    /**
     * Retrieves an order from Cosmos DB by ID
     *
     * @param orderId the order ID
     * @return Optional containing the order if found
     */
    public Optional<Order> getOrder(String orderId) {
        log.info("Retrieving order from Cosmos DB: {}", orderId);
        try {
            return orderRepository.findById(orderId);
        } catch (Exception e) {
            log.error("Failed to retrieve order: {}", orderId, e);
            return Optional.empty();
        }
    }

    /**
     * Checks if an order exists in Cosmos DB
     *
     * @param orderId the order ID
     * @return true if order exists, false otherwise
     */
    public boolean orderExists(String orderId) {
        log.debug("Checking if order exists: {}", orderId);
        try {
            return orderRepository.existsById(orderId);
        } catch (Exception e) {
            log.warn("Failed to check if order exists: {}", orderId, e);
            return false;
        }
    }

    /**
     * Deletes an order from Cosmos DB
     *
     * @param orderId the order ID to delete
     */
    public void deleteOrder(String orderId) {
        log.info("Deleting order from Cosmos DB: {}", orderId);
        try {
            orderRepository.deleteById(orderId);
        } catch (Exception e) {
            log.error("Failed to delete order: {}", orderId, e);
            throw new RuntimeException("Failed to delete order from Cosmos DB", e);
        }
    }

    /**
     * Gets the count of orders in Cosmos DB
     *
     * @return the number of orders
     */
    public long getOrdersCount() {
        try {
            long count = orderRepository.count();
            log.debug("Total orders in Cosmos DB: {}", count);
            return count;
        } catch (Exception e) {
            log.warn("Failed to get orders count: {}", e.getMessage());
            return 0;
        }
    }
}