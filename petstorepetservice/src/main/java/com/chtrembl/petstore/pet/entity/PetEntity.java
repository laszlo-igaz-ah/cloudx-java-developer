package com.chtrembl.petstore.pet.entity;

import com.azure.spring.data.cosmos.core.mapping.Container;
import com.azure.spring.data.cosmos.core.mapping.PartitionKey;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Container(containerName = "pets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PetEntity {
    @PartitionKey
    private String id;

    private String name;

    private CategoryEntity category;

    private String photoURL;

    private String status;

    @Builder.Default
    private List<TagEntity> tags = new ArrayList<>();
}

