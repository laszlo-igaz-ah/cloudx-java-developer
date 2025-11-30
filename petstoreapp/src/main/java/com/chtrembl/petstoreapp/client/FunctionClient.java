package com.chtrembl.petstoreapp.client;

import com.chtrembl.petstoreapp.config.FeignConfig;
import com.chtrembl.petstoreapp.model.Order;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(
        name = "function-service",
        url = "${petstore.function.order-item-reserver.url}",
        configuration = FeignConfig.class
)
public interface FunctionClient {

    @PostMapping(value = "/OrderItemReserver")
    void triggerOrderItemReserver(
            @RequestBody String orderJson,
            @RequestParam("code") String functionKey
    );

}