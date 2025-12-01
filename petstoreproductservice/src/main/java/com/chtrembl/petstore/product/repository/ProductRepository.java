package com.chtrembl.petstore.product.repository;

import com.azure.spring.data.cosmos.repository.CosmosRepository;
import com.chtrembl.petstore.product.entity.ProductEntity;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends CosmosRepository<ProductEntity, String> {
    List<ProductEntity> findByStatusIn(List<String> statuses);
}

