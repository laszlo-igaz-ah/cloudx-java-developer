package com.chtrembl.petstore.product.repository;

import com.chtrembl.petstore.product.entity.ProductEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<ProductEntity, Long> {
    @Query("SELECT DISTINCT p FROM ProductEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.productTags pt " +
           "LEFT JOIN FETCH pt.tag " +
           "WHERE p.status IN :statuses")
    List<ProductEntity> findByStatus(@Param("statuses") List<String> statuses);

    @Query("SELECT DISTINCT p FROM ProductEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.productTags pt " +
           "LEFT JOIN FETCH pt.tag " +
           "WHERE p.id = :id")
    Optional<ProductEntity> findById(@Param("id") Long id);

    @Query("SELECT DISTINCT p FROM ProductEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.productTags pt " +
           "LEFT JOIN FETCH pt.tag")
    List<ProductEntity> findAll();
}

