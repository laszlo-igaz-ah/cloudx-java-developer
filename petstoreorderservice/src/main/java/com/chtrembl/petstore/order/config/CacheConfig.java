package com.chtrembl.petstore.order.config;

import com.azure.spring.data.cosmos.repository.config.EnableCosmosRepositories;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCosmosRepositories(basePackages = {"com.chtrembl.petstore.order.repository"})
@Slf4j
public class CacheConfig {
    // Azure Cosmos DB configuration is auto-configured by spring-cloud-azure-starter-cosmos
    // Properties are configured in application.yml under spring.cloud.azure.cosmos
}