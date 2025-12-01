package com.chtrembl.petstore.product.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Entity
@Table(name = "product_tag_connect")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(ProductTagEntity.ProductTagId.class)
public class ProductTagEntity {
    @Id
    @Column(name = "product_id")
    private Long productId;

    @Id
    @Column(name = "tag_id")
    private Long tagId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", insertable = false, updatable = false)
    private ProductEntity product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tag_id", insertable = false, updatable = false)
    private TagEntity tag;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProductTagId implements Serializable {
        private Long productId;
        private Long tagId;
    }
}

