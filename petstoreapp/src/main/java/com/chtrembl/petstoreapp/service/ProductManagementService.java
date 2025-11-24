package com.chtrembl.petstoreapp.service;

import com.chtrembl.petstoreapp.client.ProductServiceClient;
import com.chtrembl.petstoreapp.exception.ProductServiceException;
import com.chtrembl.petstoreapp.model.ContainerEnvironment;
import com.chtrembl.petstoreapp.model.Product;
import com.chtrembl.petstoreapp.model.Tag;
import com.chtrembl.petstoreapp.model.User;
import feign.FeignException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import static com.chtrembl.petstoreapp.config.Constants.CATEGORY;
import static com.chtrembl.petstoreapp.config.Constants.OPERATION;
import static com.chtrembl.petstoreapp.config.Constants.REQUEST_ID;
import static com.chtrembl.petstoreapp.config.Constants.TRACE_ID;
import static com.chtrembl.petstoreapp.model.Status.AVAILABLE;
import static com.microsoft.applicationinsights.telemetry.SeverityLevel.Information;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductManagementService {

    private final User sessionUser;
    private final ContainerEnvironment containerEnvironment;
    private final ProductServiceClient productServiceClient;

    public Collection<Product> getProductsByCategory(String category, List<Tag> tags) {
        List<Product> products;

        MDC.put(OPERATION, "getProducts");
        MDC.put(CATEGORY, category);

        String requestId = MDC.get(REQUEST_ID);
        String traceId = MDC.get(TRACE_ID);

        log.info("Starting product retrieval operation [RequestID: {}, TraceID: {}, Category: {}]",
                requestId, traceId, category);

        if (Math.random() < 0.5) { // 10% chance
            log.error("Random exception triggered [RequestID: {}, TraceID: {}]", requestId, traceId);
            throw new RuntimeException("Cannot go further");
        }

        try {
            this.sessionUser.getTelemetryClient().trackEvent(
                    String.format("PetStoreApp user %s is requesting to retrieve products from the ProductService",
                            this.sessionUser.getName()),
                    this.sessionUser.getCustomEventProperties(), null);

            products = productServiceClient.getProductsByStatus(AVAILABLE.getValue());
            this.sessionUser.setProducts(products);

            // Custom Event: Product retrieval successful with metrics
            this.sessionUser.getTelemetryClient().trackEvent(
                    "ProductRetrievalSuccess",
                    createEventProperties(category, tags, requestId, traceId, products.size()),
                    createEventMetrics(products.size())
            );

            if (tags.stream().anyMatch(t -> t.getName().equals("large"))) {
                products = products.stream()
                        .filter(product -> category.equals(product.getCategory().getName())
                                && product.getTags().toString().contains("large"))
                        .toList();
            } else {
                products = products.stream()
                        .filter(product -> category.equals(product.getCategory().getName())
                                && product.getTags().toString().contains("small"))
                        .toList();
            }

            log.info("Successfully retrieved {} products for category {} with tags {} [RequestID: {}, TraceID: {}]",
                    products.size(), category, tags, requestId, traceId);

            // Custom Event: Products filtered and returned to user
            this.sessionUser.getTelemetryClient().trackEvent(
                    "ProductsFilteredByCategory",
                    createFilteredEventProperties(category, tags, requestId, traceId, products.size()),
                    createEventMetrics(products.size())
            );

            // Custom Metric: Track the number of products returned to the user
            int returnedProductCount = products.size();

            // Use trackTrace for Application Insights
            String traceMessage = String.format(
                    "Returning %d products to user %s [RequestID: %s, TraceID: %s, Category: %s, Tags: %s]",
                    returnedProductCount, this.sessionUser.getName(), requestId, traceId, category, tags);

            this.sessionUser.getTelemetryClient().trackTrace(
                    traceMessage,
                    Information,
                    createMetricProperties(category, tags, requestId, traceId)
            );

            this.sessionUser.getTelemetryClient().trackMetric("ProductsReturnedToUser", returnedProductCount);

            return products;
        } catch (FeignException fe) {
            log.error("Feign error retrieving products [RequestID: {}, TraceID: {}, Category: {}, HTTP: {}, Message: {}]",
                    requestId, traceId, category, fe.status(), fe.getMessage(), fe);

            // Custom Event: Track exception details
            this.sessionUser.getTelemetryClient().trackException(fe);

            // Custom Event: Product retrieval failed
            this.sessionUser.getTelemetryClient().trackEvent(
                    "ProductRetrievalFailed",
                    createErrorEventProperties(category, tags, requestId, traceId, fe.status(), fe.getMessage()),
                    null
            );

            this.sessionUser.getTelemetryClient().trackEvent(
                    String.format("PetStoreApp %s received Feign error %s (HTTP %d), container host: %s",
                            this.sessionUser.getName(),
                            fe.getMessage(),
                            fe.status(),
                            this.containerEnvironment.getContainerHostName())
            );
            log.error("Failed to retrieve products from ProductService via Feign client", fe);
            throw new ProductServiceException("Unable to retrieve products from product service", fe);
        } finally {
            MDC.remove(OPERATION);
            MDC.remove(CATEGORY);
        }
    }

    private Map<String, String> createEventProperties(String category, List<Tag> tags,
                                                                  String requestId, String traceId,
                                                                  int productCount) {
        Map<String, String> properties = new java.util.HashMap<>();
        properties.put("category", category);
        properties.put("tags", tags.toString());
        properties.put("requestId", requestId);
        properties.put("traceId", traceId);
        properties.put("productCount", String.valueOf(productCount));
        properties.put("userName", this.sessionUser.getName());
        properties.put("containerHost", this.containerEnvironment.getContainerHostName());
        return properties;
    }

    private Map<String, String> createFilteredEventProperties(String category, List<Tag> tags,
                                                                         String requestId, String traceId,
                                                                         int filteredCount) {
        Map<String, String> properties = new java.util.HashMap<>();
        properties.put("category", category);
        properties.put("tags", tags.toString());
        properties.put("requestId", requestId);
        properties.put("traceId", traceId);
        properties.put("filteredProductCount", String.valueOf(filteredCount));
        properties.put("userName", this.sessionUser.getName());
        properties.put("containerHost", this.containerEnvironment.getContainerHostName());
        return properties;
    }

    private Map<String, String> createErrorEventProperties(String category, List<Tag> tags,
                                                                      String requestId, String traceId,
                                                                      int httpStatus, String errorMessage) {
        Map<String, String> properties = new java.util.HashMap<>();
        properties.put("category", category);
        properties.put("tags", tags.toString());
        properties.put("requestId", requestId);
        properties.put("traceId", traceId);
        properties.put("httpStatus", String.valueOf(httpStatus));
        properties.put("errorMessage", errorMessage);
        properties.put("userName", this.sessionUser.getName());
        properties.put("containerHost", this.containerEnvironment.getContainerHostName());
        return properties;
    }

    private Map<String, Double> createEventMetrics(int count) {
        Map<String, Double> metrics = new java.util.HashMap<>();
        metrics.put("productCount", (double) count);
        return metrics;
    }

    private Map<String, String> createMetricProperties(String category, List<Tag> tags,
                                                        String requestId, String traceId) {
        Map<String, String> properties = new java.util.HashMap<>();
        properties.put("category", category);
        properties.put("tags", tags.toString());
        properties.put("requestId", requestId);
        properties.put("traceId", traceId);
        properties.put("userName", this.sessionUser.getName());
        properties.put("containerHost", this.containerEnvironment.getContainerHostName());
        return properties;
    }
}
