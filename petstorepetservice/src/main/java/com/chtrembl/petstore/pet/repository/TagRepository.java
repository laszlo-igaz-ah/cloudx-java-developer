package com.chtrembl.petstore.pet.repository;

import com.chtrembl.petstore.pet.entity.TagEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TagRepository extends JpaRepository<TagEntity, Long> {
}

