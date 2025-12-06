package com.chtrembl.petstore.product.mapper;

import com.chtrembl.petstore.product.entity.CategoryEntity;
import com.chtrembl.petstore.product.entity.ProductEntity;
import com.chtrembl.petstore.product.entity.TagEntity;
import com.chtrembl.petstore.product.model.Category;
import com.chtrembl.petstore.product.model.Product;
import com.chtrembl.petstore.product.model.Tag;

import java.util.List;
import java.util.stream.Collectors;

public class ProductMapper {
    
    public static Product toModel(ProductEntity entity) {
        if (entity == null) {
            return null;
        }
        
        Product.ProductBuilder builder = Product.builder()
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
                builder.status(Product.Status.fromValue(entity.getStatus()));
            } catch (IllegalArgumentException e) {
                // If status doesn't match enum, set to null or handle error
                builder.status(null);
            }
        }
        
        // Map tags (now embedded directly in entity)
        if (entity.getTags() != null && !entity.getTags().isEmpty()) {
            List<Tag> tags = entity.getTags().stream()
                    .map(ProductMapper::toTagModel)
                    .collect(Collectors.toList());
            builder.tags(tags);
        }
        
        return builder.build();
    }
    
    public static List<Product> toModelList(List<ProductEntity> entities) {
        if (entities == null) {
            return List.of();
        }
        return entities.stream()
                .map(ProductMapper::toModel)
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

