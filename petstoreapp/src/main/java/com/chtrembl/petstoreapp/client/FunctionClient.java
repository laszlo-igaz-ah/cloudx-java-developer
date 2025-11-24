package com.chtrembl.petstoreapp.client;

import com.chtrembl.petstoreapp.config.FeignConfig;
import com.chtrembl.petstoreapp.model.Order;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(
        name = "function-service",
        url = "ttps://function-app-cloudx-igazl.azurewebsites.net/api",
        configuration = FeignConfig.class
)
public interface FunctionClient {

    @PostMapping("/OrderItemReserver")
    void triggerOrderItemReserver(@RequestBody String orderJson);

}