package com.chtrembl.petstore.pet.config;

import com.chtrembl.petstore.pet.entity.CategoryEntity;
import com.chtrembl.petstore.pet.entity.PetEntity;
import com.chtrembl.petstore.pet.entity.TagEntity;
import com.chtrembl.petstore.pet.repository.PetRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Component
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final PetRepository petRepository;

    public DatabaseInitializer(PetRepository petRepository) {
        this.petRepository = petRepository;
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
            return petRepository.count() > 0;
        } catch (Exception e) {
            log.debug("Error checking data existence: {}", e.getMessage());
            return false;
        }
    }

    private void initializeData() {
        // Initialize categories
        CategoryEntity dogCategory = CategoryEntity.builder().id("1").name("Dog").build();
        CategoryEntity catCategory = CategoryEntity.builder().id("2").name("Cat").build();
        CategoryEntity fishCategory = CategoryEntity.builder().id("3").name("Fish").build();

        // Initialize tags
        TagEntity doggieTag = TagEntity.builder().id("1").name("doggie").build();
        TagEntity largeTag = TagEntity.builder().id("2").name("large").build();
        TagEntity smallTag = TagEntity.builder().id("3").name("small").build();
        TagEntity kittieTag = TagEntity.builder().id("4").name("kittie").build();
        TagEntity fishyTag = TagEntity.builder().id("5").name("fishy").build();

        // Initialize pets with embedded categories and tags
        List<PetEntity> pets = new ArrayList<>();
        
        // Dogs
        pets.add(createPet("1", "Afador", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/afador.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("2", "American Bulldog", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/american-bulldog.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("3", "Australian Retriever", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/australian-retriever.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("4", "Australian Shepherd", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/australian-shepherd.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("5", "Basset Hound", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/basset-hound.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("6", "Beagle", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/beagle.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("7", "Border Terrier", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/border-terrier.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("8", "Boston Terrier", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/boston-terrier.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("9", "Bulldog", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/bulldog.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("10", "Bullmastiff", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/bullmastiff.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("11", "Chihuahua", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/chihuahua.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("12", "Cocker Spaniel", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/cocker-spaniel.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("13", "German Sheperd", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/german-shepherd.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("14", "Labrador Retriever", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/labrador-retriever.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("15", "Pomeranian", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/pomeranian.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("16", "Pug", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/pug.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("17", "Rottweiler", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/rottweiler.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("18", "Shetland Sheepdog", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/shetland-sheepdog.jpg?raw=true", "available", Arrays.asList(doggieTag, largeTag)));
        pets.add(createPet("19", "Shih Tzu", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/shih-tzu.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        pets.add(createPet("20", "Toy Fox Terrier", dogCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/dog-breeds/toy-fox-terrier.jpg?raw=true", "available", Arrays.asList(doggieTag, smallTag)));
        
        // Cats
        pets.add(createPet("21", "Abyssinian", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/abyssinian.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("22", "American Bobtail", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/american-bobtail.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("23", "American Shorthair", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/american-shorthair.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("24", "Balinese", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/balinese.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("25", "Birman", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/birman.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("26", "Bombay", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/bombay.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("27", "British Shorthair", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/british-shorthair.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("28", "Burmilla", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/burmilla.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("29", "Chartreux", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/chartreux.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        pets.add(createPet("30", "Cornish Rex", catCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/cat-breeds/cornish-rex.jpg?raw=true", "available", Arrays.asList(smallTag, kittieTag)));
        
        // Fish
        pets.add(createPet("31", "Goldfish", fishCategory, "https://raw.githubusercontent.com/chtrembl/staticcontent/master/fish-breeds/goldfish.jpg?raw=true", "available", Arrays.asList(smallTag, fishyTag)));

        petRepository.saveAll(pets);
        log.info("Initialized {} pets", pets.size());
    }

    private PetEntity createPet(String id, String name, CategoryEntity category, String photoURL, String status, List<TagEntity> tags) {
        return PetEntity.builder()
                .id(id)
                .name(name)
                .category(category)
                .photoURL(photoURL)
                .status(status)
                .tags(new ArrayList<>(tags))
                .build();
    }
}

