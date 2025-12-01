package com.chtrembl.petstore.product.service;

import com.chtrembl.petstore.product.entity.ProductEntity;
import com.chtrembl.petstore.product.mapper.ProductMapper;
import com.chtrembl.petstore.product.model.Product;
import com.chtrembl.petstore.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    @Transactional(readOnly = true)
    public List<Product> findProductsByStatus(List<String> status) {
        log.info("Finding products with status: {}", status);

        List<ProductEntity> entities = productRepository.findByStatus(status);
        return ProductMapper.toModelList(entities);
    }

    @Transactional(readOnly = true)
    public Optional<Product> findProductById(Long productId) {
        log.info("Finding product with id: {}", productId);

        Optional<ProductEntity> entity = productRepository.findById(productId);
        return entity.map(ProductMapper::toModel);
    }

    @Transactional(readOnly = true)
    public List<Product> getAllProducts() {
        log.info("Getting all products");
        List<ProductEntity> entities = productRepository.findAll();
        return ProductMapper.toModelList(entities);
    }

    @Transactional(readOnly = true)
    public int getProductCount() {
        return (int) productRepository.count();
    }
}