package com.chtrembl.petstore.product.config;

import com.chtrembl.petstore.product.entity.CategoryEntity;
import com.chtrembl.petstore.product.entity.ProductEntity;
import com.chtrembl.petstore.product.entity.TagEntity;
import com.chtrembl.petstore.product.repository.ProductRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Component
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final ProductRepository productRepository;

    public DatabaseInitializer(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Override
    public void run(String... args) {
        log.info("Checking if Cosmos DB containers have data...");
        
        if (dataExists()) {
            log.info("Cosmos DB containers already have data. Skipping initialization.");
            return;
        }

        log.info("Cosmos DB containers are empty. Initializing data...");
        
        try {
            initializeData();
            log.info("Database initialization completed successfully.");
        } catch (Exception e) {
            log.error("Error initializing database: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to initialize database", e);
        }
    }

    private boolean dataExists() {
        try {
            return productRepository.count() > 0;
        } catch (Exception e) {
            log.debug("Error checking data existence: {}", e.getMessage());
            return false;
        }
    }

    private void initializeData() {
        // Initialize categories
        CategoryEntity dogToyCategory = CategoryEntity.builder().id("1").name("Dog Toy").build();
        CategoryEntity dogFoodCategory = CategoryEntity.builder().id("2").name("Dog Food").build();
        CategoryEntity catToyCategory = CategoryEntity.builder().id("3").name("Cat Toy").build();
        CategoryEntity catFoodCategory = CategoryEntity.builder().id("4").name("Cat Food").build();
        CategoryEntity fishToyCategory = CategoryEntity.builder().id("5").name("Fish Toy").build();
        CategoryEntity fishFoodCategory = CategoryEntity.builder().id("6").name("Fish Food").build();

        // Initialize tags
        TagEntity smallTag = TagEntity.builder().id("1").name("small").build();
        TagEntity largeTag = TagEntity.builder().id("2").name("large").build();

        // Initialize products with embedded categories and tags
        List<ProductEntity> products = new ArrayList<>();
        
        products.add(createProduct("1", "Ball", dogToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-toys/ball.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("2", "Ball Launcher", dogToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-toys/ball-launcher.jpg?raw=true", "available", Arrays.asList(largeTag)));
        products.add(createProduct("3", "Plush Lamb", dogToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-toys/plush-lamb.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("4", "Plush Moose", dogToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-toys/plush-moose.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("5", "Large Breed Dry Food", dogFoodCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-food/large-dog.jpg?raw=true", "available", Arrays.asList(largeTag)));
        products.add(createProduct("6", "Small Breed Dry Food", dogFoodCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-food/small-dog.jpg?raw=true", "available", Arrays.asList(smallTag)));
        products.add(createProduct("7", "Mouse", catToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-toys/mouse.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("8", "Scratcher", catToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-toys/scratcher.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("9", "All Sizes Cat Dry Food", catFoodCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-food/cat.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("10", "Mangrove Ornament", fishToyCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/fish-toys/mangrove.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));
        products.add(createProduct("11", "All Sizes Fish Food", fishFoodCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/fish-food/fish.jpg?raw=true", "available", Arrays.asList(smallTag, largeTag)));

        productRepository.saveAll(products);
        log.info("Initialized {} products", products.size());
    }

    private ProductEntity createProduct(String id, String name, CategoryEntity category, String photoURL, String status, List<TagEntity> tags) {
        return ProductEntity.builder()
                .id(id)
                .name(name)
                .category(category)
                .photoURL(photoURL)
                .status(status)
                .tags(new ArrayList<>(tags))
                .build();
    }
}

