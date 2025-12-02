package com.chtrembl.petstore.pet.repository;

import com.chtrembl.petstore.pet.entity.PetEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PetRepository extends JpaRepository<PetEntity, Long> {
    @Query("SELECT DISTINCT p FROM PetEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.petTags pt " +
           "LEFT JOIN FETCH pt.tag " +
           "WHERE p.status IN :statuses")
    List<PetEntity> findByStatus(@Param("statuses") List<String> statuses);

    @Query("SELECT DISTINCT p FROM PetEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.petTags pt " +
           "LEFT JOIN FETCH pt.tag " +
           "WHERE p.id = :id")
    Optional<PetEntity> findById(@Param("id") Long id);

    @Query("SELECT DISTINCT p FROM PetEntity p " +
           "LEFT JOIN FETCH p.category " +
           "LEFT JOIN FETCH p.petTags pt " +
           "LEFT JOIN FETCH pt.tag")
    List<PetEntity> findAll();
}

