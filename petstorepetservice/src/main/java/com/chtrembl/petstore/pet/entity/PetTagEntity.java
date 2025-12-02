package com.chtrembl.petstore.pet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Entity
@Table(name = "pet_tag_connect")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(PetTagEntity.PetTagId.class)
public class PetTagEntity {
    @Id
    @Column(name = "pet_id")
    private Long petId;

    @Id
    @Column(name = "tag_id")
    private Long tagId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pet_id", insertable = false, updatable = false)
    private PetEntity pet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tag_id", insertable = false, updatable = false)
    private TagEntity tag;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PetTagId implements Serializable {
        private Long petId;
        private Long tagId;
    }
}

