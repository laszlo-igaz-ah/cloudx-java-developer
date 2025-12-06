package com.chtrembl.petstore.pet.repository;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.chtrembl.petstore.pet.entity.PetEntity;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PetRepository extends CosmosRepository<PetEntity, String> {
    List<PetEntity> findByStatusIn(List<String> statuses);
}

