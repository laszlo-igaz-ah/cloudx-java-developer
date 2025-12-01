package com.chtrembl.petstore.pet.mapper;

import com.chtrembl.petstore.pet.entity.CategoryEntity;
import com.chtrembl.petstore.pet.entity.PetEntity;
import com.chtrembl.petstore.pet.entity.TagEntity;
import com.chtrembl.petstore.pet.model.Category;
import com.chtrembl.petstore.pet.model.Pet;
import com.chtrembl.petstore.pet.model.Tag;

import java.util.List;
import java.util.stream.Collectors;

public class PetMapper {
    
    public static Pet toModel(PetEntity entity) {
        if (entity == null) {
            return null;
        }
        
        Pet.PetBuilder builder = Pet.builder()
                .id(entity.getId())
                .name(entity.getName())
                .photoURL(entity.getPhotoURL());
        
        // Map category
        if (entity.getCategory() != null) {
            builder.category(toCategoryModel(entity.getCategory()));
        }
        
        // Map status
        if (entity.getStatus() != null) {
            try {
                builder.status(Pet.Status.fromValue(entity.getStatus()));
            } catch (IllegalArgumentException e) {
                // If status doesn't match enum, set to null or handle error
                builder.status(null);
            }
        }
        
        // Map tags from petTags relationship
        if (entity.getPetTags() != null && !entity.getPetTags().isEmpty()) {
            List<Tag> tags = entity.getPetTags().stream()
                    .map(petTag -> petTag.getTag())
                    .filter(tag -> tag != null)
                    .map(PetMapper::toTagModel)
                    .collect(Collectors.toList());
            builder.tags(tags);
        }
        
        return builder.build();
    }
    
    public static List<Pet> toModelList(List<PetEntity> entities) {
        if (entities == null) {
            return List.of();
        }
        return entities.stream()
                .map(PetMapper::toModel)
                .collect(Collectors.toList());
    }
    
    private static Category toCategoryModel(CategoryEntity entity) {
        if (entity == null) {
            return null;
        }
        return Category.builder()
                .id(entity.getId())
                .name(entity.getName())
                .build();
    }
    
    private static Tag toTagModel(TagEntity entity) {
        if (entity == null) {
            return null;
        }
        return Tag.builder()
                .id(entity.getId())
                .name(entity.getName())
                .build();
    }
}

