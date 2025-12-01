package com.chtrembl.petstore.product.entity;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Container(containerName = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductEntity {
    @PartitionKey
    private String id;

    private String name;

    private CategoryEntity category;

    private String photoURL;

    private String status;

    @Builder.Default
    private List<TagEntity> tags = new ArrayList<>();
}

